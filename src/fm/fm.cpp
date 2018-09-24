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
#include "fmh.h"
#include "utils.h"
#include "tagging.h"

#include <QFlags>
#include <QDateTime>
#include <QFileInfo>
#include <QDesktopServices>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#endif

FM::FM(QObject *parent) : FMDB(parent)
{
    this->watcher = new QFileSystemWatcher(this);
    connect(watcher, &QFileSystemWatcher::directoryChanged, [this](const QString &path)
    {
        qDebug()<< " path modified"+path;
        emit pathModified(path);

    });

    this->tag = Tagging::getInstance("MAUIFM","1.0", "org.kde.maui","MauiKit File Manager");
}

FM::~FM()
{

}

QVariantList FM::packItems(const QStringList &items, const QString &type)
{
    QVariantList data;

    for(auto path : items)
        if(UTIL::fileExists(path))
            data << getDirInfo(path, type);

    return data;
}

QVariantList FM::get(const QString &queryTxt)
{
    QVariantList mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            QVariantMap data;
            for(auto key : FMH::MODEL_NAME.keys())
                if(query.record().indexOf(FMH::MODEL_NAME[key]) > -1)
                    data[FMH::MODEL_NAME[key]] = query.value(FMH::MODEL_NAME[key]).toString();

            mapList<< data;

        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;

}

void FM::watchPath(const QString &path)
{
    if(!watcher->directories().isEmpty())
        watcher->removePaths(watcher->directories());
    watcher->addPath(path);
}

QVariantList FM::getPathContent(const QString &path, const bool &onlyDirs, const QStringList &filters)
{
    QVariantList content;
    if (QFileInfo(path).isDir())
    {
        QDir::Filters dirFilter;

        auto conf = dirConf(path+"/.directory");

        dirFilter = ( onlyDirs ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot :
                                 QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);
        if(!conf.isEmpty())
        {
            auto hidden = conf[FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN]].toBool();
            if(hidden)
                dirFilter = dirFilter | QDir::Hidden | QDir::System;
        }

        QDirIterator it (path, filters,  dirFilter, QDirIterator::NoIteratorFlags);
        while (it.hasNext())
        {
            auto url = it.next();
            QFileInfo file(url);
            auto item = QVariantMap {
            {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], FMH::getIconName(url)},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::MIME], FMH::getMime(url)},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], file.fileName()},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], url},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::THUMBNAIL], url},

        };

        content << item;
        emit this->itemReady(item);
    }
}
return content;
}

QVariantList FM::getDefaultPaths()
{
    QVariantList res;
    res << packItems(FMH::defaultPaths, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::PLACES]);
    return res;
}

QVariantList FM::getDevices()
{
    QVariantList drives;

#if defined(Q_OS_ANDROID)
    drives << packItems({MAUIAndroid::sdDir()}, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::DRIVES]);
#endif

    auto devices = QStorageInfo::mountedVolumes();
    for(auto device : devices)
    {
        if(device.isValid() && !device.isReadOnly())
        {
            QVariantMap drive =
            {
                {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], "drive-harddisk"},
                {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], device.displayName()},
                {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], device.rootPath()},
                {FMH::MODEL_NAME[FMH::MODEL_KEY::TYPE], FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::DRIVES]}
            };

            drives << drive;
        }
    }

    //    for(auto device : QDir::drives())
    //    {
    //        QVariantMap drive =
    //        {
    //            {"iconName", "drive-harddisk"},
    //            {"label", device.baseName()},
    //            {"path", device.absoluteFilePath()},
    //            {"type", "Drives"}
    //        };

    //        drives << drive;
    //    }

    return drives;
}

QVariantList FM::getTags(const int &limit)
{
    QVariantList data;
    qDebug()<< "getting TAGS";
    if(this->tag)
    {
        for(auto tag : this->tag->getUrlsTags(false))
        {
            qDebug()<< "TAG << "<< tag;
            auto label = tag.toMap().value(TAG::KEYMAP[TAG::KEY::TAG]).toString();
            data << QVariantMap
            {
            {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], label},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], "tag"},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], label},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::TYPE],  FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::TAGS]}
        };
    }
}

return data;
}

QVariantList FM::getBookmarks()
{
    QStringList bookmarks;
    for(auto bookmark : this->get("select * from bookmarks"))
        bookmarks << bookmark.toMap().value(FMH::MODEL_NAME[FMH::MODEL_KEY::PATH]).toString();

    return packItems(bookmarks, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::BOOKMARKS]);
}

QVariantList FM::getTagContent(const QString &tag)
{
    QVariantList content;

    for(auto data : this->tag->getUrls(tag, false))
    {
        auto url = data.toMap().value(TAG::KEYMAP[TAG::KEY::URL]).toString();
        QFileInfo file(url);

        auto item = QVariantMap
        {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::MIME], FMH::getMime(url)},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::THUMBNAIL], url},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], FMH::getIconName(url)},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], file.isDir() ? file.baseName() :
                                                                file.fileName()},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], url}
        };
        content << item;
        emit this->itemReady(item);
    }

    return content;
}

QVariantMap FM::getDirInfo(const QString &path, const QString &type)
{
    return FMH::getDirInfo(path, type);
}

bool FM::isDefaultPath(const QString &path)
{
    return FMH::defaultPaths.contains(path);
}

QString FM::parentDir(const QString &path)
{
    auto dir = QDir(path);
    dir.cdUp();
    return dir.absolutePath();
}

bool FM::isDir(const QString &path)
{
    return QFileInfo(path).isDir();

}

bool FM::bookmark(const QString &path)
{
    QFileInfo file (path);

    QVariantMap bookmark_map {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], path},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], file.baseName()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::DATE], QDateTime::currentDateTime()}
    };

    qDebug()<< bookmark_map;
    return this->insert(FMH::TABLEMAP[FMH::TABLE::BOOKMARKS], bookmark_map);
}

bool FM::fileExists(const QString &path)
{
    return FMH::fileExists(path);
}

void FM::saveSettings(const QString &key, const QVariant &value, const QString &group)
{
    UTIL::saveSettings(key, value, group);
}

QVariant FM::loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
{
    return UTIL::loadSettings(key, group, defaultValue);
}

QString FM::homePath()
{
    return FMH::HomePath;
}

bool FM::copy(const QStringList &paths, const QString &where)
{
    for(auto path : paths)
    {
        if(QFileInfo(path).isDir())
        {
            auto state = copyPath(path, where+"/"+QFileInfo(path).fileName(), false);
            if(!state) return false;

        }else
        {
            QFile file(path);
            qDebug()<< paths << "is a file";

            auto state = file.copy(where+"/"+QFileInfo(path).fileName());
            if(!state) return false;
        }
    }

    return true;
}

bool FM::copyPath(QString sourceDir, QString destinationDir, bool overWriteDirectory)
{
    QDir originDirectory(sourceDir);

    if (! originDirectory.exists())
    {
        return false;
    }

    QDir destinationDirectory(destinationDir);

    if(destinationDirectory.exists() && !overWriteDirectory)
    {
        return false;
    }
    else if(destinationDirectory.exists() && overWriteDirectory)
    {
        destinationDirectory.removeRecursively();
    }

    originDirectory.mkpath(destinationDir);

    foreach (QString directoryName, originDirectory.entryList(QDir::Dirs | \
                                                              QDir::NoDotAndDotDot))
    {
        QString destinationPath = destinationDir + "/" + directoryName;
        originDirectory.mkpath(destinationPath);
        copyPath(sourceDir + "/" + directoryName, destinationPath, overWriteDirectory);
    }

    foreach (QString fileName, originDirectory.entryList(QDir::Files))
    {
        QFile::copy(sourceDir + "/" + fileName, destinationDir + "/" + fileName);
    }

    /*! Possible race-condition mitigation? */
    QDir finalDestination(destinationDir);
    finalDestination.refresh();

    if(finalDestination.exists())
    {
        return true;
    }

    return false;
}

bool FM::cut(const QStringList &paths, const QString &where)
{
    for(auto path : paths)
    {
        QFile file(path);
        auto state = file.rename(where+"/"+QFileInfo(path).fileName());
        if(!state) return false;
    }

    return true;
}

bool FM::remove(const QString &path)
{
    if(QFileInfo(path).isDir())
        return removeDir(path);
    else return QFile(path).remove();
}

bool FM::removeDir(const QString &path)
{
    bool result = true;
    QDir dir(path);

    if (dir.exists(path))
    {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst))
        {
            if (info.isDir())
            {
                result = removeDir(info.absoluteFilePath());
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
        result = dir.rmdir(path);
    }

    return result;
}

bool FM::rename(const QString &path, const QString &name)
{
    QFile file(path);
    auto url = QFileInfo(path).dir().absolutePath();
        qDebug()<< "RENAME FILE TO:" << path << name << url;

    return file.rename(url+"/"+name);
}

bool FM::createDir(const QString &path, const QString &name)
{
    return QDir(path).mkdir(name);
}

bool FM::createFile(const QString &path, const QString &name)
{
    QFile file(path + "/" + name);

    if(file.open(QIODevice::ReadWrite))
    {
        file.close();
        return true;
    }

    return false;
}

bool FM::openUrl(const QString &url)
{
        return QDesktopServices::openUrl(QUrl::fromUserInput(url));
}

QVariantMap FM::dirConf(const QString &path)
{
    return FMH::dirConf(path);
}

void FM::setDirConf(const QString &path, const QString &group, const QString &key, const QString &value)
{
    FMH::setDirConf(path, group, key, value);
}

