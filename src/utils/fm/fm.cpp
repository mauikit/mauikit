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

#ifdef COMPONENT_TAGGING
#include "tagging.h"
#endif

#ifdef COMPONENT_SYNCING
#include "syncing.h"
#endif

#include <QDateTime>
#include <QFileInfo>
#include <QLocale>
#include <QRegularExpression>
#include <QUrl>

#if defined(Q_OS_ANDROID)
#include "platforms/android/mauiandroid.h"
#elif defined Q_OS_LINUX
#include "platforms/linux/mauilinux.h"
#include <KCoreDirLister>
#include <KFileItem>
#include <KFilePlacesModel>
#include <KIO/CopyJob>
#include <KIO/DeleteJob>
#include <KIO/MkdirJob>
#include <KIO/SimpleJob>
#include <QIcon>
#endif

#if defined(Q_OS_ANDROID) || defined(Q_OS_WIN) || defined(Q_OS_MACOS)
#include "fileloader.h"

#include <QFileSystemWatcher>

QDirLister::QDirLister(QObject *parent)
    : QObject(parent)
    , m_loader(new FMH::FileLoader)
    , m_watcher(new QFileSystemWatcher(this))
{
    m_loader->setBatchCount(20);
    m_loader->informer = &FMH::getFileInfoModel;
    connect(m_loader, &FMH::FileLoader::itemsReady, [this](FMH::MODEL_LIST items, QList<QUrl> urls)
    {
        emit this->itemsReady(items, urls.first());
    });

    connect(m_loader, &FMH::FileLoader::itemReady, [this](FMH::MODEL item, QList<QUrl> urls)
    {
        this->m_list << item;
        this->m_watcher->addPath(QUrl(item[FMH::MODEL_KEY::URL]).toLocalFile());
        emit this->itemReady(item, urls.first());
    });

    connect(m_loader, &FMH::FileLoader::finished, [this](FMH::MODEL_LIST, QList<QUrl> urls)
    {
        emit this->completed(urls.first());
    });

    connect(this->m_watcher, &QFileSystemWatcher::directoryChanged, [&](const QString &path) {
        if(path == this->m_url.toLocalFile())
        {
            this->reviewChanges();
        }
    });

    connect(this->m_watcher, &QFileSystemWatcher::fileChanged, [&](const QString &path) {

        const auto fileUrl = QUrl::fromLocalFile(path);
        if(this->includes(fileUrl))
        {
            if(FMH::fileExists(fileUrl))
            {
                emit this->refreshItems({{this->m_list.at(this->indexOf(FMH::MODEL_KEY::URL, fileUrl.toString())), FMH::getFileInfoModel(fileUrl)}}, this->m_url);
            }
        }
    });
}

void QDirLister::reviewChanges()
{
    if(this->m_checking)
        return;

    this->m_checking = true;
    auto checkLoader = new FMH::FileLoader;
    checkLoader->informer = &FMH::getFileInfoModel;

    qDebug( ) << "Doign the check" << m_checking;

    FMH::MODEL_LIST removedItems;
    for(const auto &item : this->m_list)
    {
        const auto fileUrl = QUrl(item[FMH::MODEL_KEY::URL]);
        if(!FMH::fileExists(fileUrl))
        {
            removedItems << item;
            qDebug() << "FILE PATH CHANGED REMOVED" << fileUrl;
            const auto index = this->indexOf(FMH::MODEL_KEY::URL, fileUrl.toString());
            this->m_list.remove(index);
            this->m_watcher->removePath(fileUrl.toLocalFile());
        }
    }

    if(!removedItems.isEmpty())
        emit this->itemsDeleted(removedItems, this->m_url);

    connect(checkLoader, &FMH::FileLoader::itemsReady, [=](FMH::MODEL_LIST items, QList<QUrl> urls)
    {
        if(urls.first() == this->m_url)
        {
            FMH::MODEL_LIST newItems;
            for(const auto &item : items)
            {
                const auto fileUrl = QUrl(item[FMH::MODEL_KEY::URL]);
                if(!this->includes(fileUrl))
                {
                    newItems << item;

                    this->m_list << item;
                    this->m_watcher->addPath(fileUrl.toLocalFile());
                }
            }

            if(!newItems.isEmpty())
                emit this->itemsAdded(newItems, this->m_url);
        }

        checkLoader->deleteLater();
        this->m_checking = false;

    });

    connect(checkLoader, &FMH::FileLoader::finished, [=](FMH::MODEL_LIST, QList<QUrl>)
    {
        checkLoader->deleteLater();
        this->m_checking = false;
    });

    QDir::Filters dirFilter = (m_dirOnly ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot : QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);

    if (m_showDotFiles)
        dirFilter = dirFilter | QDir::Hidden | QDir::System;

    checkLoader->requestPath({this->m_url}, false, m_nameFilters.isEmpty() ? QStringList() : m_nameFilters.split(" "), dirFilter);
}

bool QDirLister::includes(const QUrl &url)
{
    return this->indexOf(FMH::MODEL_KEY::URL, url.toString()) >= 0;
}

int QDirLister::indexOf(const FMH::MODEL_KEY &key, const QString &value) const
{
    const auto it = std::find_if(this->m_list.constBegin(), this->m_list.constEnd(), [&](const FMH::MODEL &item) -> bool { return item[key] == value; });

    if (it != this->m_list.constEnd())
        return std::distance(this->m_list.constBegin(), it);
    else
        return -1;
}

bool QDirLister::openUrl(QUrl url)
{
//    if(this->m_url == url)
//        return false;

    this->m_url = url;
    this->m_watcher->removePaths(QStringList() << this->m_watcher->directories() << this->m_watcher->files());

    if (FMStatic::isDir(this->m_url)) {

        this->m_watcher->addPath(this->m_url.toLocalFile());

        QDir::Filters dirFilter = (m_dirOnly ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot : QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);

        if (m_showDotFiles)
            dirFilter = dirFilter | QDir::Hidden | QDir::System;

        m_loader->requestPath({this->m_url}, false, m_nameFilters.isEmpty() ? QStringList() : m_nameFilters.split(" "), dirFilter);

    } else
        return false;

    return true;
}

void QDirLister::setDirOnlyMode(bool value)
{
    m_dirOnly = value;
}

void QDirLister::setShowingDotFiles(bool value)
{
    m_showDotFiles = value;
}

void QDirLister::setNameFilter(QString filters)
{
    m_nameFilters = filters;
}
#endif

FM::FM(QObject *parent)
    : QObject(parent)
#ifdef COMPONENT_SYNCING
    , sync(new Syncing(this))
#endif
#ifdef COMPONENT_TAGGING
    , tag(Tagging::getInstance())
#endif
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    , dirLister(new KCoreDirLister(this))
#else
    , dirLister(new QDirLister)
#endif
{
#ifdef Q_OS_ANDROID
    MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"});
#endif

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    this->dirLister->setAutoUpdate(true);

    const static auto packItems = [](const KFileItemList &items) -> FMH::MODEL_LIST {
        return std::accumulate(items.constBegin(), items.constEnd(), FMH::MODEL_LIST(), [](FMH::MODEL_LIST &res, const KFileItem &item) -> FMH::MODEL_LIST {
            res << FMH::getFileInfo(item);
            return res;
        });
    };

    connect(dirLister, static_cast<void (KCoreDirLister::*)(const QUrl &)>(&KCoreDirLister::completed), this, [&](QUrl url) {
        qDebug() << "PATH CONTENT READY" << url;
        emit this->pathContentReady(url);
    });

    connect(dirLister, static_cast<void (KCoreDirLister::*)(const QUrl &, const KFileItemList &items)>(&KCoreDirLister::itemsAdded), this, [&](QUrl dirUrl, KFileItemList items) {
        qDebug() << "MORE ITEMS WERE ADDED";
        emit this->pathContentItemsReady({dirUrl, packItems(items)});
    });

    // 			connect(dirLister, static_cast<void (KCoreDirLister::*)(const KFileItemList &items)>(&KCoreDirLister::newItems), [&](KFileItemList items)
    //             {
    //                 qDebug()<< "MORE NEW ITEMS WERE ADDED";
    // 				for(const auto &item : items)
    // 					qDebug()<< "MORE <<" << item.url();
    //
    //                 emit this->pathContentChanged(dirLister->url());
    //             });

    connect(dirLister, static_cast<void (KCoreDirLister::*)(const KFileItemList &items)>(&KCoreDirLister::itemsDeleted), this, [&](KFileItemList items) {
        qDebug() << "ITEMS WERE DELETED";
        emit this->pathContentItemsRemoved({dirLister->url(), packItems(items)});
    });

    connect(dirLister, static_cast<void (KCoreDirLister::*)(const QList<QPair<KFileItem, KFileItem>> &items)>(&KCoreDirLister::refreshItems), this, [&](QList<QPair<KFileItem, KFileItem>> items) {
        qDebug() << "ITEMS WERE REFRESHED";

        const auto res = std::accumulate(
            items.constBegin(), items.constEnd(), QVector<QPair<FMH::MODEL, FMH::MODEL>>(), [](QVector<QPair<FMH::MODEL, FMH::MODEL>> &list, const QPair<KFileItem, KFileItem> &pair) -> QVector<QPair<FMH::MODEL, FMH::MODEL>> {
                list << QPair<FMH::MODEL, FMH::MODEL> {FMH::getFileInfo(pair.first), FMH::getFileInfo(pair.second)};
                return list;
            });

        emit this->pathContentItemsChanged(res);
    });
#else
    connect(dirLister, &QDirLister::itemsReady, this, [&](FMH::MODEL_LIST items, QUrl url) { emit this->pathContentItemsReady({url, items}); });

    connect(dirLister, &QDirLister::completed, this, [&](QUrl url) { emit this->pathContentReady(url);});

    connect(dirLister, &QDirLister::refreshItems, this, [&](QVector<QPair<FMH::MODEL, FMH::MODEL>> items, QUrl) {
        qDebug() << "ITEMS WERE REFRESHED";
        emit this->pathContentItemsChanged(items);
    });

    connect(dirLister, &QDirLister::itemsAdded, this, [&](FMH::MODEL_LIST items, QUrl url) {
        qDebug() << "MORE ITEMS WERE ADDED";
        emit this->pathContentItemsReady({url, items});
    });

    connect(dirLister, &QDirLister::itemsDeleted, this, [&](FMH::MODEL_LIST items, QUrl url) {
        qDebug() << "ITEMS WERE DELETED";
        emit this->pathContentItemsRemoved({url, items});
    });

#endif

#ifdef COMPONENT_SYNCING
    connect(this->sync, &Syncing::listReady, [this](const FMH::MODEL_LIST &list, const QUrl &url) { emit this->cloudServerContentReady(list, url); });

    connect(this->sync, &Syncing::itemReady, [this](const FMH::MODEL &item, const QUrl &url, const Syncing::SIGNAL_TYPE &signalType) {
        switch (signalType) {
        case Syncing::SIGNAL_TYPE::OPEN:
            FMStatic::openUrl(item[FMH::MODEL_KEY::PATH]);
            break;

        case Syncing::SIGNAL_TYPE::DOWNLOAD:
            emit this->cloudItemReady(item, url);
            break;

        case Syncing::SIGNAL_TYPE::COPY: {
            QVariantMap data;
            for (auto key : item.keys())
                data.insert(FMH::MODEL_NAME[key], item[key]);

            //                         this->copy(QVariantList {data}, this->sync->getCopyTo());
            break;
        }
        default:
            return;
        }
    });

    connect(this->sync, &Syncing::error, [this](const QString &message) { emit this->warningMessage(message); });

    connect(this->sync, &Syncing::progress, [this](const int &percent) { emit this->loadProgress(percent); });

    connect(this->sync, &Syncing::dirCreated, [this](const FMH::MODEL &dir, const QUrl &url) { emit this->newItem(dir, url); });

    connect(this->sync, &Syncing::uploadReady, [this](const FMH::MODEL &item, const QUrl &url) { emit this->newItem(item, url); });
#endif
}

void FM::getPathContent(const QUrl &path, const bool &hidden, const bool &onlyDirs, const QStringList &filters, const QDirIterator::IteratorFlags &iteratorFlags)
{
    qDebug() << "Getting async path contents";
    Q_UNUSED(iteratorFlags)
    this->dirLister->setShowingDotFiles(hidden);
    this->dirLister->setDirOnlyMode(onlyDirs);
    this->dirLister->setNameFilter(filters.join(" "));

    if (this->dirLister->openUrl(path))
        qDebug() << "GETTING PATH CONTENT" << path;
}

FMH::MODEL_LIST FM::getAppsPath()
{
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS // for android, windows and mac use this for now

    return FMH::MODEL_LIST();
#else

    return FMH::MODEL_LIST {FMH::MODEL {{FMH::MODEL_KEY::ICON, "system-run"},
                                        {FMH::MODEL_KEY::LABEL, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::APPS_PATH]},
                                        {FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::APPS_PATH]},
                                        {FMH::MODEL_KEY::TYPE, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]}}};
#endif
}

bool FM::getCloudServerContent(const QUrl &path, const QStringList &filters, const int &depth)
{
#ifdef COMPONENT_SYNCING
    const auto __list = path.toString().replace("cloud:///", "/").split("/");

    if (__list.isEmpty() || __list.size() < 2) {
        qWarning() << "Could not parse username to get cloud server content";
        return false;
    }

    auto user = __list[1];
    //        auto data = this->get(QString("select * from clouds where user = '%1'").arg(user));
    QVariantList data;
    if (data.isEmpty())
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
    for (const auto &key : item.keys())
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
    Q_UNUSED(server)
    return FMH::CloudCachePath + "opendesktop/" + user;
}

QString FM::resolveLocalCloudPath(const QString &path)
{
#ifdef COMPONENT_SYNCING
    return QString(path).replace(FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH] + this->sync->getUser(), "");
#else
    return QString();
#endif
}

bool FM::cut(const QList<QUrl> &urls, const QUrl &where)
{
    return FMStatic::cut(urls, where);
}

bool FM::copy(const QList<QUrl> &urls, const QUrl &where)
{
    // 	QStringList cloudPaths;

    return FMStatic::copy(urls, where);

#ifdef COMPONENT_SYNCING
    // 	if(!cloudPaths.isEmpty())
    // 	{
    // 		qDebug()<<"UPLOAD QUEUE" << cloudPaths;
    // 		const auto firstPath = cloudPaths.takeLast();
    // 		this->sync->setUploadQueue(cloudPaths);
    //
    // 		if(where.toString().split("/").last().contains("."))
    // 		{
    // 			QStringList whereList = where.toString().split("/");
    // 			whereList.removeLast();
    // 			auto whereDir = whereList.join("/");
    // 			qDebug()<< "Trying ot copy to cloud" << where << whereDir;
    //
    // 			this->sync->upload(this->resolveLocalCloudPath(whereDir), firstPath);
    // 		} else
    // 			this->sync->upload(this->resolveLocalCloudPath(where.toString()), firstPath);
    // 	}
#endif
}
