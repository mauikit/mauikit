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

#include <QObject>

#include <QFlags>
#include <QDateTime>
#include <QFileInfo>
#include <QUrl>
#include <QLocale>
#include <QRegularExpression>

#include <QtConcurrent>
#include <QtConcurrent/QtConcurrentRun>
#include <QFuture>
#include <QThread>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#elif defined Q_OS_LINUX
#include "mauikde.h"
#include <KFilePlacesModel>
#include <KIO/CopyJob>
#include <KIO/SimpleJob>
#include <KIO/MkdirJob>
#include <KIO/DeleteJob>
#include <KCoreDirLister>
#include <KFileItem>
#include <QIcon>
#endif


QDirLister::QDirLister(QObject* parent) : QObject(parent)
{}

bool QDirLister::openUrl(QUrl url)
{
    qDebug() << "GET FILES <<" << m_nameFilters.split(" ");
    FMH::MODEL_LIST content;
    
    if (FMStatic::isDir(url))
    {
        QDir::Filters dirFilter;
        
        dirFilter = (m_dirOnly ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot :
        QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);
        
        if(m_showDotFiles)
            dirFilter = dirFilter | QDir::Hidden | QDir::System;
        
        QDirIterator it (url.toLocalFile(), m_nameFilters.isEmpty() ? QStringList() : m_nameFilters.split(" "), dirFilter, QDirIterator::NoIteratorFlags);
        while (it.hasNext())
        {
            const auto item = FMH::getFileInfoModel(QUrl::fromLocalFile(it.next()));
                        content << item;                

            emit itemReady(item, url);
        }
    } else return false;	
    
    emit itemsReady(content, url);
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


FM::FM(QObject *parent) : QObject(parent)
#ifdef COMPONENT_SYNCING
,sync(new Syncing(this))
#endif
#ifdef COMPONENT_TAGGING
,tag(Tagging::getInstance())
#endif
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
,dirLister( new KCoreDirLister(this))
#else
,dirLister( new QDirLister)
#endif
{	
	#ifdef Q_OS_ANDROID
	MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"});
	#endif
	
	#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
	this->dirLister->setAutoUpdate(true);	
	
	const static auto packItem = [](const KFileItem &kfile) -> FMH::MODEL
	{
		return FMH::MODEL{ {FMH::MODEL_KEY::LABEL, kfile.name()},
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
		// 			{FMH::MODEL_KEY::FAVORITE, QVariant(this->urlTagExists(kfile.mostLocalUrl().toString(), "fav")).toString()},
		{FMH::MODEL_KEY::COUNT, kfile.isLocalFile() && kfile.isDir() ?  QString::number(QDir(kfile.localPath()).count() - 2) : "0"}
		};
	};
	
	const static auto packItems = [](const KFileItemList &items) -> FMH::MODEL_LIST 
	{		
		return std::accumulate(items.constBegin(), items.constEnd(), FMH::MODEL_LIST(), [](FMH::MODEL_LIST &res, const KFileItem &item) ->FMH::MODEL_LIST
		{
			res << packItem(item);
			return res;
		});
	};	
	
	connect(dirLister, static_cast<void (KCoreDirLister::*)(const QUrl&)>(&KCoreDirLister::completed), this, [&](QUrl url)
	{
		qDebug()<< "PATH CONTENT READY" << url;		
		emit this->pathContentReady(url);
	});
	
	connect(dirLister, static_cast<void (KCoreDirLister::*)(const QUrl&, const KFileItemList &items)>(&KCoreDirLister::itemsAdded), this, [&](QUrl dirUrl, KFileItemList items)
	{
		qDebug()<< "MORE ITEMS WERE ADDED";		
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
	
	connect(dirLister, static_cast<void (KCoreDirLister::*)(const KFileItemList &items)>(&KCoreDirLister::itemsDeleted), this, [&](KFileItemList items)
	{
		qDebug()<< "ITEMS WERE DELETED";			
		emit this->pathContentItemsRemoved({dirLister->url(), packItems(items)});
	});
	
	connect(dirLister, static_cast<void (KCoreDirLister::*)(const QList< QPair< KFileItem, KFileItem > > &items)>(&KCoreDirLister::refreshItems), this, [&](QList< QPair< KFileItem, KFileItem > > items)
	{
		qDebug()<< "ITEMS WERE REFRESHED";
		
		const auto res = std::accumulate(items.constBegin(), items.constEnd(), QVector<QPair<FMH::MODEL, FMH::MODEL>>(), [](QVector<QPair<FMH::MODEL, FMH::MODEL>> &list, const QPair<KFileItem, KFileItem> &pair) -> QVector<QPair<FMH::MODEL, FMH::MODEL>>
		{
			list << QPair<FMH::MODEL, FMH::MODEL>{packItem(pair.first), packItem(pair.second)};
			return list;
		});	
		
        emit this->pathContentItemsChanged(res);
    });
    #else
    connect(dirLister, &QDirLister::itemReady, this, [&](FMH::MODEL item, QUrl url)
    {
        emit this->pathContentItemsReady(FMH::PATH_CONTENT {url, {item}});
    });
    
    connect(dirLister, &QDirLister::itemsReady, this, [&](FMH::MODEL_LIST, QUrl url)
    {
        emit this->pathContentReady(url);
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
				FMStatic::openUrl(item[FMH::MODEL_KEY::PATH]);
				break;
				
			case Syncing::SIGNAL_TYPE::DOWNLOAD:
				emit this->cloudItemReady(item, url);
				break;
				
			case Syncing::SIGNAL_TYPE::COPY:
			{
				QVariantMap data;
				for(auto key : item.keys())
					data.insert(FMH::MODEL_NAME[key], item[key]);
				
				//                         this->copy(QVariantList {data}, this->sync->getCopyTo());
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

void FM::getPathContent(const QUrl& path, const bool &hidden, const bool &onlyDirs, const QStringList& filters, const QDirIterator::IteratorFlags &iteratorFlags)
{
	qDebug()<< "Getting async path contents";

	this->dirLister->setShowingDotFiles(hidden);
	this->dirLister->setDirOnlyMode(onlyDirs);
	
	this->dirLister->setNameFilter(filters.join(" "));
	
	if(this->dirLister->openUrl(path))
		qDebug()<< "GETTING PATH CONTENT" << path;
		
}

FMH::MODEL_LIST FM::getAppsPath()
{
    #if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS //for android, windows and mac use this for now

	return FMH::MODEL_LIST();
	#else
	
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
	#endif
}

FMH::MODEL_LIST FM::getTags(const int &limit)
{
	Q_UNUSED(limit);
	FMH::MODEL_LIST data;
	#ifdef COMPONENT_TAGGING
	if(this->tag)
	{
		for(const auto &tag : this->tag->getAllTags(false))
		{
			const QVariantMap item = tag.toMap();
			const auto label = item.value(TAG::KEYMAP[TAG::KEYS::TAG]).toString();
            
			data << FMH::MODEL
			{
				{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::TAGS_PATH]+label},
				{FMH::MODEL_KEY::ICON, item.value(TAG::KEYMAP[TAG::KEYS::ICON], "tag").toString()},
				{FMH::MODEL_KEY::MODIFIED, QDateTime::fromString(item.value(TAG::KEYMAP[TAG::KEYS::ADD_DATE]).toString(), Qt::TextDate).toString()},
				{FMH::MODEL_KEY::IS_DIR, "true"},
				{FMH::MODEL_KEY::LABEL, label},
				{FMH::MODEL_KEY::TYPE, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::TAGS_PATH]}
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
	//        auto data = this->get(QString("select * from clouds where user = '%1'").arg(user));
	QVariantList data;
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

FMH::MODEL_LIST FM::getTagContent(const QString &tag, const QStringList &filters)
{
	FMH::MODEL_LIST content;
	#ifdef COMPONENT_TAGGING
	if(tag.isEmpty())
	{
		return this->getTags();
	}else
	{
		for(const auto &url : FMStatic::getTagUrls(tag, filters, false))
		{
			content << FMH::getFileInfoModel(url);
		}
	}
	#endif
	return content;
}

FMH::MODEL_LIST FM::getUrlTags(const QUrl &url)
{
	FMH::MODEL_LIST content;
	#ifdef COMPONENT_TAGGING
	content = FMH::toModelList(this->tag->getUrlTags(url.toString(), false));
	#endif
	return content;
}

bool FM::urlTagExists(const QUrl& url, const QString tag)
{
	#ifdef COMPONENT_TAGGING
	return this->tag->urlTagExists(url.toString(), tag, false);
	#endif
}

bool FM::addTagToUrl(const QString tag, const QUrl& url)
{
	#ifdef COMPONENT_TAGGING
	return this->tag->tagUrl(url.toString(), tag);
	#endif
}

bool FM::removeTagToUrl(const QString tag, const QUrl& url)
{
	#ifdef COMPONENT_TAGGING
	return this->tag->removeUrlTag(url.toString(), tag);
	#endif
}

bool FM::cut(const QList<QUrl> &urls, const QUrl &where)
{
	return FMStatic::cut(urls, where);	
}

bool FM::copy(const QList<QUrl> &urls, const QUrl &where)
{
// 	QStringList cloudPaths;

	return FMStatic::copy(urls, where, false);		
	
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


