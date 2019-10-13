/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "fm.h"
#include "utils.h"

#ifdef COMPONENT_TAGGING
#include "tagging.h"
#endif

#ifdef COMPONENT_SYNCING
#include "syncing.h"
#endif

#include <QObject>

#include <QFlags>
#include <QDateTime>
#include <QFileInfo>
#include <QDesktopServices>
#include <QUrl>
#include <QLocale>
#include <QRegularExpression>

#include <QtConcurrent>
#include <QtConcurrent/QtConcurrentRun>
#include <QFuture>
#include <QThread>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#else
#include "mauikde.h"
#include <KFilePlacesModel>
#include <KIO/CopyJob>
#include <KIO/SimpleJob>
#include <KIO/MkdirJob>
#include <KIO/DeleteJob>
#include <KIO/EmptyTrashJob>
#include <KCoreDirLister>
#include <KFileItem>
#include <KRun>
#include <QIcon>
#endif


FM::FM(QObject *parent) : QObject(parent)
  #ifdef COMPONENT_SYNCING
  ,sync(new Syncing(this))
  #endif
  #ifdef COMPONENT_TAGGING
  ,tag(Tagging::getInstance())
  #endif
  #if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
  ,dirLister(new KCoreDirLister(this))
  #endif
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    this->dirLister->setAutoUpdate(true);
    connect(dirLister, static_cast<void (KCoreDirLister::*)(const QUrl&)>(&KCoreDirLister::completed), [&](QUrl url)
    {
        qDebug()<< "PATH CONTENT READY" << url;

        FMH::PATH_CONTENT res;
        FMH::MODEL_LIST content;
        for(const auto &kfile : dirLister->items())
        {
            qDebug() << kfile.url() << kfile.name() << kfile.isDir();
            content << FMH::MODEL{ {FMH::MODEL_KEY::LABEL, kfile.name()},
            {FMH::MODEL_KEY::NAME, kfile.name()},
            {FMH::MODEL_KEY::DATE, kfile.time(KFileItem::FileTimes::CreationTime).toString(Qt::TextDate)},
            {FMH::MODEL_KEY::MODIFIED, kfile.time(KFileItem::FileTimes::ModificationTime).toString(Qt::TextDate)},
            {FMH::MODEL_KEY::LAST_READ, kfile.time(KFileItem::FileTimes::AccessTime).toString(Qt::TextDate)},
            {FMH::MODEL_KEY::PATH, kfile.mostLocalUrl().toString()},
            {FMH::MODEL_KEY::THUMBNAIL, kfile.localPath()},
            {FMH::MODEL_KEY::SYMLINK, kfile.linkDest()},
            {FMH::MODEL_KEY::IS_SYMLINK, QVariant(kfile.isLink()).toString()},
            {FMH::MODEL_KEY::HIDDEN, QVariant(kfile.isHidden()).toString()},
            {FMH::MODEL_KEY::IS_DIR, QVariant(kfile.isDir()).toString()},
            {FMH::MODEL_KEY::IS_FILE, QVariant(kfile.isFile()).toString()},
            {FMH::MODEL_KEY::WRITABLE, QVariant(kfile.isWritable()).toString()},
            {FMH::MODEL_KEY::READABLE, QVariant(kfile.isReadable()).toString()},
            {FMH::MODEL_KEY::EXECUTABLE, QVariant(kfile.isDesktopFile()).toString()},
            {FMH::MODEL_KEY::MIME, kfile.mimetype()},
            {FMH::MODEL_KEY::GROUP, kfile.group()},
            {FMH::MODEL_KEY::ICON, kfile.iconName()},
            {FMH::MODEL_KEY::SIZE, QString::number(kfile.size())},
            {FMH::MODEL_KEY::THUMBNAIL, kfile.mostLocalUrl().toString()},
            {FMH::MODEL_KEY::OWNER, kfile.user()},
            {FMH::MODEL_KEY::COUNT, kfile.isLocalFile() && kfile.isDir() ?  QString::number(QDir(kfile.localPath()).count() - 2) : "0"}
        };
        }

                       res.path = url;
                       res.content = content;

                       emit this->pathContentReady(res);
        });

            connect(dirLister, static_cast<void (KCoreDirLister::*)(const QUrl&, const KFileItemList &items)>(&KCoreDirLister::itemsAdded), [&]()
            {
                qDebug()<< "MORE ITEMS WERE ADDED";
                emit this->pathContentChanged(dirLister->url());
            });

            connect(dirLister, static_cast<void (KCoreDirLister::*)(const KFileItemList &items)>(&KCoreDirLister::newItems), [&]()
            {
                qDebug()<< "MORE NEW ITEMS WERE ADDED";
                emit this->pathContentChanged(dirLister->url());
            });

            connect(dirLister, static_cast<void (KCoreDirLister::*)(const KFileItemList &items)>(&KCoreDirLister::itemsDeleted), [&]()
            {
                qDebug()<< "ITEMS WERE DELETED";
                dirLister->updateDirectory(dirLister->url());
                // 		emit this->pathContentChanged(dirLister->url());	// changes when dleted items are not that important?
            });

            connect(dirLister, static_cast<void (KCoreDirLister::*)(const QList< QPair< KFileItem, KFileItem > > &items)>(&KCoreDirLister::refreshItems), [&]()
            {
                qDebug()<< "ITEMS WERE REFRESHED";
                dirLister->updateDirectory(dirLister->url());
                emit this->pathContentChanged(dirLister->url());

            });
#endif


#ifdef COMPONENT_SYNCING
            connect(this->sync, &Syncing::listReady, [this](const FMH::MODEL_LIST &list, const QUrl &url)
            {
                emit this->cloudServerContentReady(list, url);
            });

            connect(this->sync, &Syncing::itemReady, [this](const FMH::MODEL &item, const QUrl &url, const Syncing::SIGNAL_TYPE &signalType)
            {
                switch(signalType)
                {
                    case Syncing::SIGNAL_TYPE::OPEN:
                        FM_STATIC::openUrl(item[FMH::MODEL_KEY::PATH]);
                        break;

                    case Syncing::SIGNAL_TYPE::DOWNLOAD:
                        emit this->cloudItemReady(item, url);
                        break;

                    case Syncing::SIGNAL_TYPE::COPY:
                    {
                        QVariantMap data;
                        for(auto key : item.keys())
                            data.insert(FMH::MODEL_NAME[key], item[key]);

                        this->copy(QVariantList {data}, this->sync->getCopyTo());
                        break;
                    }
                    default: return;
                }
            });

            connect(this->sync, &Syncing::error, [this](const QString &message)
            {
                emit this->warningMessage(message);
            });

            connect(this->sync, &Syncing::progress, [this](const int &percent)
            {
                emit this->loadProgress(percent);
            });

            connect(this->sync, &Syncing::dirCreated, [this](const FMH::MODEL &dir, const QUrl &url)
            {
                emit this->newItem(dir, url);
            });

            connect(this->sync, &Syncing::uploadReady, [this](const FMH::MODEL &item, const QUrl &url)
            {
                emit this->newItem(item, url);
            });
#endif
        }

        FM::~FM() {}

        FMH::MODEL_LIST FM_STATIC::packItems(const QStringList &items, const QString &type)
        {
            FMH::MODEL_LIST data;

            for(const auto &path : items)
            {
                if(QUrl(path).isLocalFile() && !FMH::fileExists(path))
                    continue;

                auto model = FMH::getFileInfoModel(path);
                model.insert(FMH::MODEL_KEY::TYPE, type);
                data << model;

            }

            return data;
        }

        void FM::getPathContent(const QUrl& path, const bool &hidden, const bool &onlyDirs, const QStringList& filters, const QDirIterator::IteratorFlags &iteratorFlags)
        {
            qDebug()<< "Getting async path contents";

#ifdef Q_OS_ANDROID
            QFutureWatcher<FMH::PATH_CONTENT> *watcher = new QFutureWatcher<FMH::PATH_CONTENT>;
            connect(watcher, &QFutureWatcher<FMH::PATH_CONTENT>::finished, [this, watcher = std::move(watcher)]()
            {
                emit this->pathContentReady(watcher->future().result());
                watcher->deleteLater();
            });

            QFuture<FMH::PATH_CONTENT> t1 = QtConcurrent::run([=]() -> FMH::PATH_CONTENT
            {
                FMH::PATH_CONTENT res;
                res.path = path;

                FMH::MODEL_LIST content;

                if (FM_STATIC::isDir(path))
                {
                    QDir::Filters dirFilter;

                    dirFilter = (onlyDirs ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot :
                                            QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);

                    if(hidden)
                        dirFilter = dirFilter | QDir::Hidden | QDir::System;

                    QDirIterator it (path.toLocalFile(), filters, dirFilter, iteratorFlags);
                    while (it.hasNext())
                        content << FMH::getFileInfoModel(QUrl::fromLocalFile(it.next()));
                }

                res.content = content;
                return res;
            });
            watcher->setFuture(t1);
#else

            this->dirLister->setShowingDotFiles(hidden);
            this->dirLister->setDirOnlyMode(onlyDirs);
            this->dirLister->setNameFilter(filters.join(" "));

            // 	if(this->dirLister->url() == path)
            // 	{
            // 		this->dirLister->emitChanges();
            // 		return;
            // 	}

            if(this->dirLister->openUrl(path))
                qDebug()<< "GETTING PATH CONTENT" << path;

#endif

        }

        FMH::MODEL_LIST FM_STATIC::getDefaultPaths()
        {
            return FM_STATIC::packItems(FMH::defaultPaths, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]);
        }

        FMH::MODEL_LIST FM::getAppsPath()
        {
#ifdef Q_OS_ANDROID
            return FMH::MODEL_LIST();
#endif

            return FMH::MODEL_LIST
            {
                FMH::MODEL
                {
                    {FMH::MODEL_KEY::ICON, "system-run"},
                    {FMH::MODEL_KEY::LABEL, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::APPS_PATH]},
                    {FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::APPS_PATH]},
                    {FMH::MODEL_KEY::TYPE, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]}
                }
            };
        }

        FMH::MODEL_LIST FM_STATIC::search(const QString& query, const QUrl &path, const bool &hidden, const bool &onlyDirs, const QStringList &filters)
        {
            FMH::MODEL_LIST content;

            if(!path.isLocalFile())
            {
                qWarning() << "URL recived is not a local file. FM::search" << path;
                return content;
            }

            if (FM_STATIC::isDir(path))
            {
                QDir::Filters dirFilter;

                dirFilter = (onlyDirs ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot :
                                        QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);

                if(hidden)
                    dirFilter = dirFilter | QDir::Hidden | QDir::System;

                QDirIterator it (path.toLocalFile(), filters, dirFilter, QDirIterator::Subdirectories);
                while (it.hasNext())
                {
                    auto url = it.next();
                    auto info = it.fileInfo();
                    if(info.completeBaseName().contains(query, Qt::CaseInsensitive))
                    {
                        content << FMH::getFileInfoModel(QUrl::fromLocalFile(url));
                    }
                }
            }else
                qWarning() << "Search path does not exists" << path;

            qDebug()<< content;
            return content;
        }

        FMH::MODEL_LIST FM_STATIC::getDevices()
        {
            FMH::MODEL_LIST drives;

#if defined(Q_OS_ANDROID)
            drives << packItems(MAUIAndroid::sdDirs(), FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::DRIVES_PATH]);
            return drives;
#endif

            return drives;
        }

        FMH::MODEL_LIST FM::getTags(const int &limit)
        {
            Q_UNUSED(limit);
            FMH::MODEL_LIST data;
#ifdef COMPONENT_TAGGING
            if(this->tag)
            {
                for(const auto &tag : this->tag->getUrlsTags(false))
                {
                    qDebug()<< "TAG << "<< tag;
                    const auto label = tag.toMap().value(TAG::KEYMAP[TAG::KEYS::TAG]).toString();
                    data << FMH::MODEL
                    {
                    {FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::TAGS_PATH]+label},
                    {FMH::MODEL_KEY::ICON, "tag"},
                    {FMH::MODEL_KEY::LABEL, label},
                    {FMH::MODEL_KEY::TYPE,  FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::TAGS_PATH]}
                };
            }
        }
#endif

        return data;
    }

    bool FM::getCloudServerContent(const QUrl &path, const QStringList &filters, const int &depth)
    {
#ifdef COMPONENT_SYNCING
        const auto __list = path.toString().replace("cloud:///", "/").split("/");

        if(__list.isEmpty() || __list.size() < 2)
        {
            qWarning()<< "Could not parse username to get cloud server content";
            return false;
        }

        auto user = __list[1];
        auto data = this->get(QString("select * from clouds where user = '%1'").arg(user));

        if(data.isEmpty())
            return false;

        auto map = data.first().toMap();

        user = map[FMH::MODEL_NAME[FMH::MODEL_KEY::USER]].toString();
        auto server = map[FMH::MODEL_NAME[FMH::MODEL_KEY::SERVER]].toString();
        auto password = map[FMH::MODEL_NAME[FMH::MODEL_KEY::PASSWORD]].toString();
        this->sync->setCredentials(server, user, password);

        this->sync->listContent(path, filters, depth);
        return true;
#else
        return false;
#endif
    }

void FM::createCloudDir(const QString &path, const QString &name)
{
#ifdef COMPONENT_SYNCING
    this->sync->createDir(path, name);
#endif
}

void FM::openCloudItem(const QVariantMap &item)
{
#ifdef COMPONENT_SYNCING
    FMH::MODEL data;
    for(const auto &key : item.keys())
        data.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

    this->sync->resolveFile(data, Syncing::SIGNAL_TYPE::OPEN);
#endif
}

void FM::getCloudItem(const QVariantMap &item)
{	
#ifdef COMPONENT_SYNCING
    this->sync->resolveFile(FMH::toModel(item), Syncing::SIGNAL_TYPE::DOWNLOAD);
#endif
}

QString FM::resolveUserCloudCachePath(const QString &server, const QString &user)
{
    return FMH::CloudCachePath+"opendesktop/"+user;
}

QString FM::resolveLocalCloudPath(const QString& path)
{
#ifdef COMPONENT_SYNCING
    return QString(path).replace(FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]+this->sync->getUser(), "");
#else
    return QString();
#endif
}

FMH::MODEL_LIST FM::getTagContent(const QString &tag)
{
    FMH::MODEL_LIST content;
#ifdef COMPONENT_TAGGING
    for(const auto &data : this->tag->getUrls(tag, false))
    {
        const auto url = QUrl(data.toMap()[TAG::KEYMAP[TAG::KEYS::URL]].toString());
        if(url.isLocalFile() && !FMH::fileExists(url))
            continue;

        content << FMH::getFileInfoModel(url);
    }
#endif
    return content;
}

bool FM::addTagToUrl(const QString tag, const QUrl& url)
{
#ifdef COMPONENT_TAGGING
    return this->tag->tagUrl(url.toString(), tag);
#endif
}

QVariantMap FM_STATIC::getDirInfo(const QUrl &path, const QString &type)
{
    return FMH::getDirInfo(path, type);
}

QVariantMap FM_STATIC::getFileInfo(const QUrl &path)
{
    return FMH::getFileInfo(path);
}

bool FM_STATIC::isDefaultPath(const QString &path)
{
    return FMH::defaultPaths.contains(path);
}

QUrl FM_STATIC::parentDir(const QUrl &path)
{
    if(!path.isLocalFile())
    {
        qWarning() << "URL recived is not a local file, FM::parentDir" << path;
        return path;
    }

    QDir dir(path.toLocalFile());
    dir.cdUp();
    return QUrl::fromLocalFile(dir.absolutePath());
}

bool FM_STATIC::isDir(const QUrl &path)
{
    if(!path.isLocalFile())
    {
        qWarning() << "URL recived is not a local file. FM::isDir" << path;
        return false;
    }

    QFileInfo file(path.toLocalFile());
    return file.isDir();
}

bool FM_STATIC::isApp(const QString& path)
{
    return /*QFileInfo(path).isExecutable() ||*/ path.endsWith(".desktop");
}

bool FM_STATIC::isCloud(const QUrl &path)
{
    return path.scheme() == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::CLOUD_PATH];
}

bool FM_STATIC::fileExists(const QUrl &path)
{
    return FMH::fileExists(path);
}

QString FM_STATIC::fileDir(const QUrl& path) // the directory path of the file
{	
    QString res = path.toString();
    if(path.isLocalFile())
    {
        const QFileInfo file(path.toLocalFile());
        if(file.isDir())
            res = path.toString();
        else
            res = QUrl::fromLocalFile(file.dir().absolutePath()).toString();
    }else
        qWarning()<< "The path is not a local one. FM::fileDir";

    return res;
}

void FM_STATIC::saveSettings(const QString &key, const QVariant &value, const QString &group)
{
    UTIL::saveSettings(key, value, group);
}

QVariant FM_STATIC::loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
{
    return UTIL::loadSettings(key, group, defaultValue);
}

QString FM_STATIC::formatSize(const int &size)
{
    QLocale locale;
    return locale.formattedDataSize(size);
}

QString FM_STATIC::formatDate(const QString &dateStr, const QString &format, const QString &initFormat)
{
    QDateTime date;
    if( initFormat.isEmpty() )
        date = QDateTime::fromString(dateStr, Qt::TextDate);
    else
        date = QDateTime::fromString(dateStr, initFormat);
    return date.toString(format);
}

QString FM_STATIC::homePath()
{
    return FMH::HomePath;
}

bool FM::cut(const QVariantList &data, const QUrl &where)
{	
    FMH::MODEL_LIST items;

    for(const auto &k : data)
        items << FMH::toModel(k.toMap());

    for(const auto &item : items)
    {
        const auto path = QUrl::fromUserInput(item[FMH::MODEL_KEY::PATH]);

        if(FM_STATIC::isCloud(path.toString()))
        {
#ifdef COMPONENT_SYNCING
            this->sync->setCopyTo(where.toString());
            this->sync->resolveFile(item, Syncing::SIGNAL_TYPE::COPY);
#endif

        }else
        {
#ifdef Q_OS_ANDROID
            QFile file(path.toLocalFile());
            file.rename(where.toString()+"/"+QFileInfo(path.toLocalFile()).fileName());
#else
            auto job = KIO::move(path, QUrl(where.toString()+"/"+FMH::getFileInfoModel(path)[FMH::MODEL_KEY::LABEL]));
            job->start();
#endif
        }
    }

    return true;
}

bool FM::copy(const QVariantList &data, const QUrl &where)
{
    qDebug() << "TRYING TO COPY" << data << where;

    FMH::MODEL_LIST items;
    for(const auto &k : data)
        items << FMH::toModel(k.toMap());


    QStringList cloudPaths;
    for(const auto &item : items)
    {
        const auto path = QUrl::fromUserInput(item[FMH::MODEL_KEY::PATH]);
        if(FM_STATIC::isDir(path))
        {
            FM_STATIC::copyPath(path, where.toString()+"/"+QFileInfo(path.toLocalFile()).fileName(), false);

        }else if(FM_STATIC::isCloud(path))
        {
#ifdef COMPONENT_SYNCING
            this->sync->setCopyTo(where.toString());
            this->sync->resolveFile(item, Syncing::SIGNAL_TYPE::COPY);
#endif
        }else
        {
            if(FM_STATIC::isCloud(where))
                cloudPaths << path.toString();
            else
                FM_STATIC::copyPath(path, where.toString()+"/"+FMH::getFileInfoModel(path)[FMH::MODEL_KEY::LABEL], false);
        }
    }

#ifdef COMPONENT_SYNCING
    if(!cloudPaths.isEmpty())
    {
        qDebug()<<"UPLOAD QUEUE" << cloudPaths;
        const auto firstPath = cloudPaths.takeLast();
        this->sync->setUploadQueue(cloudPaths);

        if(where.toString().split("/").last().contains("."))
        {
            QStringList whereList = where.toString().split("/");
            whereList.removeLast();
            auto whereDir = whereList.join("/");
            qDebug()<< "Trying ot copy to cloud" << where << whereDir;

            this->sync->upload(this->resolveLocalCloudPath(whereDir), firstPath);
        } else
            this->sync->upload(this->resolveLocalCloudPath(where.toString()), firstPath);
    }
#endif

    return true;
}

bool FM_STATIC::copyPath(QUrl sourceDir, QUrl destinationDir, bool overWriteDirectory)
{
#ifdef Q_OS_ANDROID
    QFileInfo fileInfo(sourceDir.toLocalFile());
    if(fileInfo.isFile())
        QFile::copy(sourceDir.toLocalFile(), destinationDir.toLocalFile());

    QDir originDirectory(sourceDir.toLocalFile());

    if (!originDirectory.exists())
        return false;

    QDir destinationDirectory(destinationDir.toLocalFile());

    if(destinationDirectory.exists() && !overWriteDirectory)
        return false;
    else if(destinationDirectory.exists() && overWriteDirectory)
        destinationDirectory.removeRecursively();

    originDirectory.mkpath(destinationDir.toLocalFile());

    foreach(QString directoryName, originDirectory.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
        QString destinationPath = destinationDir.toLocalFile() + "/" + directoryName;
        originDirectory.mkpath(destinationPath);
        copyPath(sourceDir.toLocalFile() + "/" + directoryName, destinationPath, overWriteDirectory);
    }

    foreach (QString fileName, originDirectory.entryList(QDir::Files))
    {
        QFile::copy(sourceDir.toLocalFile() + "/" + fileName, destinationDir.toLocalFile() + "/" + fileName);
    }

    /*! Possible race-condition mitigation? */
    QDir finalDestination(destinationDir.toLocalFile());
    finalDestination.refresh();

    if(finalDestination.exists())
        return true;

    return false;
#else
    qDebug()<< "TRYING TO COPY" << sourceDir<< destinationDir;
    auto job = KIO::copy(sourceDir, destinationDir);
    job->start();
    return true;
#endif
}

bool FM_STATIC::removeFile(const QUrl &path)
{
    if(!path.isLocalFile())
        qWarning() << "URL recived is not a local file, FM::removeFile" << path;

    qDebug()<< "TRYING TO REMOVE FILE: " << path;

#ifdef Q_OS_ANDROID
    if(QFileInfo(path.toLocalFile()).isDir())
        return FM_STATIC::removeDir(path);
    else return QFile(path.toLocalFile()).remove();
#else
    auto job = KIO::del(path);
    job->start();
    return true;
#endif
}

void FM_STATIC::moveToTrash(const QUrl &path)
{
    if(!path.isLocalFile())
        qWarning() << "URL recived is not a local file, FM::moveToTrash" << path;

#ifdef Q_OS_ANDROID
#else
    auto job = KIO::trash(path);
    job->start();
#endif
}

void FM_STATIC::emptyTrash()
{
#ifdef Q_OS_ANDROID
#else
    auto job = KIO::emptyTrash();
    job->start();
#endif
}

bool FM_STATIC::removeDir(const QUrl &path)
{
    bool result = true;
    QDir dir(path.toLocalFile());
    qDebug()<< "TRYING TO REMOVE DIR" << path << path.toLocalFile();
    if (dir.exists())
    {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst))
        {
            if (info.isDir())
            {
                result = removeDir(QUrl::fromLocalFile(info.absoluteFilePath()));
            }
            else
            {
                result = QFile::remove(info.absoluteFilePath());
            }

            if (!result)
            {
                return result;
            }
        }
        result = dir.rmdir(path.toLocalFile());
    }

    return result;
}

bool FM_STATIC::rename(const QUrl &path, const QString &name)
{
    QFile file(path.toLocalFile());
    const auto url = QFileInfo(path.toLocalFile()).dir().absolutePath();
    return file.rename(url+"/"+name);
}

bool FM_STATIC::createDir(const QUrl &path, const QString &name)
{
#ifdef Q_OS_ANDROID
    QFileInfo dd(path.toLocalFile());
    return QDir(path.toLocalFile()).mkdir(name);
#else
    const auto _path = QUrl(path.toString() + "/" + name);
    auto job = KIO::mkdir(_path);
    job->start();
    return true;
#endif
}

bool FM_STATIC::createFile(const QUrl &path, const QString &name)
{
    QFile file(path.toLocalFile() + "/" + name);

    if(file.open(QIODevice::ReadWrite))
    {
        file.close();
        return true;
    }

    return false;
}

bool FM_STATIC::createSymlink(const QUrl &path, const QUrl &where)
{
#ifdef Q_OS_ANDROID
    return QFile::link(path.toLocalFile(), where.toLocalFile() + "/" + QFileInfo(path.toLocalFile()).fileName());
#else
    const auto job = KIO::link({path}, where);
    job->start();
    return true;
#endif
}

bool FM_STATIC::openUrl(const QUrl &url)
{
#ifdef Q_OS_ANDROID
    MAUIAndroid::openUrl(url.toString());
    return true;
#else    
    //     return QDesktopServices::openUrl(QUrl::fromUserInput(url));
    return KRun::runUrl(url, FMH::getFileInfoModel(url)[FMH::MODEL_KEY::MIME], nullptr, false, KRun::RunFlag::DeleteTemporaryFiles);
#endif
}

void FM_STATIC::openLocation(const QStringList &urls)
{
    for(const auto &url : urls)
        QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(url).dir().absolutePath()));
}

QVariantMap FM_STATIC::dirConf(const QUrl &path)
{
    return FMH::dirConf(path);
}

void FM_STATIC::setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value)
{
    FMH::setDirConf(path, group, key, value);
}

