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
#include "tagging.h"
#include "syncing.h"

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
#include <KIO/DeleteJob>
#include <KIO/EmptyTrashJob>
#include <KCoreDirLister>
#include <KFileItem>
#include <QIcon>
#endif

/*
 * FM *FM::instance = nullptr;
 * 
 * FM* FM::getInstance()
 * {
 *    if(!instance)
 *    {
 *        instance = new FM();
 *        qDebug() << "getInstance(): First instance\n";
 *        instance->init();
 *        return instance;
 *    } else
 *    {
 *        qDebug()<< "getInstance(): previous instance\n";
 *        return instance;
 *    }
 * }*/

#ifdef Q_OS_ANDROID
FM::FM(QObject *parent) : FMDB(parent),
sync(new Syncing(this)),
tag(Tagging::getInstance())
#else
FM::FM(QObject *parent) : FMDB(parent),
sync(new Syncing(this)),
tag(Tagging::getInstance()),
dirLister(new KCoreDirLister(this))
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
			{FMH::MODEL_KEY::PATH, kfile.url().toString()},
			{FMH::MODEL_KEY::THUMBNAIL, kfile.localPath()},
			{FMH::MODEL_KEY::MIME, kfile.mimetype()},
			{FMH::MODEL_KEY::GROUP, kfile.group()},
			{FMH::MODEL_KEY::ICON, kfile.iconName()},
			{FMH::MODEL_KEY::SIZE, QString::number(kfile.size())},
			{FMH::MODEL_KEY::THUMBNAIL, kfile.mostLocalUrl().toString()},
			{FMH::MODEL_KEY::OWNER, kfile.user()},
			{FMH::MODEL_KEY::COUNT, kfile.isLocalFile() && kfile.isDir() ?  QString::number(QDir(kfile.localPath()).count() - 2) : "0"}
			};
		}
		
		res.path = url.toString();
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
	connect(this->sync, &Syncing::listReady, [this](const FMH::MODEL_LIST &list, const QString &url)
	{
		emit this->cloudServerContentReady(list, url);
	});
	
	connect(this->sync, &Syncing::itemReady, [this](const FMH::MODEL &item, const QString &url, const Syncing::SIGNAL_TYPE &signalType)
	{		
		switch(signalType)
		{
			case Syncing::SIGNAL_TYPE::OPEN:
				this->openUrl(item[FMH::MODEL_KEY::PATH]);
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
	
	connect(this->sync, &Syncing::dirCreated, [this](const FMH::MODEL &dir, const QString &url)
	{		
		emit this->newItem(dir, url);
	});
	
	connect(this->sync, &Syncing::uploadReady, [this](const FMH::MODEL &item, const QString &url)
	{		
		emit this->newItem(item, url);
	});
}

FM::~FM() {}

QVariantMap FM::toMap(const FMH::MODEL& model)
{
	QVariantMap map;
	for(const auto &key : model.keys())
		map.insert(FMH::MODEL_NAME[key], model[key]);
	
	return map;		
}

FMH::MODEL FM::toModel(const QVariantMap& map)
{
	FMH::MODEL model;
	for(const auto &key : map.keys())
		model.insert(FMH::MODEL_NAME_KEY[key], map[key].toString());
	
	return model;		
}

FMH::MODEL_LIST FM::packItems(const QStringList &items, const QString &type)
{
	FMH::MODEL_LIST data;
	
	for(const auto &path : items)
		if(FMH::fileExists(path))
		{
			auto model = FMH::getFileInfoModel(path);
			model.insert(FMH::MODEL_KEY::TYPE, type);
			data << model;
		}
		
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
		res.path = path.toString();
		
		FMH::MODEL_LIST content;
		
		if (FM::isDir(path))
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

void FM::getTrashContent()
{	
	#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)	
	if(this->dirLister->openUrl(QUrl("trash://")))
		qDebug()<< "TRASH CONTENT";		
	#endif
}

FMH::MODEL_LIST FM::getAppsContent(const QString& path)
{
	FMH::MODEL_LIST res;
	#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
	QUrl __url(path);	
	
	// 	if(__url.scheme() == FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::APPS_PATH])
	return MAUIKDE::getApps(QString(path).replace("apps://", ""));
	
	#endif
	return res;
}

FMH::MODEL_LIST FM::getDefaultPaths()
{
	return packItems(FMH::defaultPaths, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]);
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
			{FMH::MODEL_KEY::LABEL, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]},
			{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::APPS_PATH]},
			{FMH::MODEL_KEY::TYPE, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]}
		}
	};
}

FMH::MODEL_LIST FM::search(const QString& query, const QUrl &path, const bool &hidden, const bool &onlyDirs, const QStringList &filters)
{
	FMH::MODEL_LIST content;	
	
	if(!path.isLocalFile())
	{
		qWarning() << "URL recived is not a local file. FM::search" << path;
		return content;	  
	}	
	
	if (FM::isDir(path))
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
			qDebug()<< info.completeBaseName() <<  info.completeBaseName().contains(query);
			if(info.completeBaseName().contains(query, Qt::CaseInsensitive))
			{
				content << FMH::getFileInfoModel(QUrl::fromLocalFile(url));
			}
		}
	}
	
	qDebug()<< content;
	return content;
}

// FMH::MODEL_LIST FM::getDevices()
// {
//     FMH::MODEL_LIST drives;
// 
// #if defined(Q_OS_ANDROID)
//     drives << packItems({MAUIAndroid::sdDir()}, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::DRIVES_PATH]);
//     return drives;
// #else
//     KFilePlacesModel model;
//     for(const auto &i : model.groupIndexes(KFilePlacesModel::GroupType::RemoteType))
//     {
//         drives << FMH::MODEL{
//             {FMH::MODEL_KEY::NAME, model.text(i)},
//             {FMH::MODEL_KEY::LABEL, model.text(i)},
//             {FMH::MODEL_KEY::PATH, model.url(i).toString()},
//             {FMH::MODEL_KEY::ICON, model.icon(i).name()},            
//             {FMH::MODEL_KEY::TYPE, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::DRIVES_PATH]},
//         };           
//     }
//     
// #endif
// 
//     //     auto devices = QStorageInfo::mountedVolumes();
//     //     for(auto device : devices)
//     //     {
//     //         if(device.isValid() && !device.isReadOnly())
//     //         {
//     //             QVariantMap drive =
//     //             {
//     //                 {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], "drive-harddisk"},
//     //                 {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], device.displayName()},
//     //                 {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], device.rootPath()},
//     //                 {FMH::MODEL_NAME[FMH::MODEL_KEY::TYPE], FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::DRIVES]}
//     //             };
//     //
//     //             drives << drive;
//     //         }
//     //     }
// 
//     //    for(auto device : QDir::drives())
//     //    {
//     //        QVariantMap drive =
//     //        {
//     //            {"iconName", "drive-harddisk"},
//     //            {"label", device.baseName()},
//     //            {"path", device.absoluteFilePath()},
//     //            {"type", "Drives"}
//     //        };
// 
//     //        drives << drive;
//     //    }
// 
//     return drives;
// }

FMH::MODEL_LIST FM::getTags(const int &limit)
{
	Q_UNUSED(limit);
	
	FMH::MODEL_LIST data;
	
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
	
	return data;
}

bool FM::getCloudServerContent(const QString &path, const QStringList &filters, const int &depth)
{
	const auto __list = QString(path).replace("cloud://", "/").split("/");
	
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
}

FMH::MODEL_LIST FM::getCloudAccounts()
{
	auto accounts = this->get("select * from clouds");
	FMH::MODEL_LIST res;
	for(const auto &account : accounts)
	{
		auto map = account.toMap();
		res << FMH::MODEL {
			{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]+map[FMH::MODEL_NAME[FMH::MODEL_KEY::USER]].toString()},
			{FMH::MODEL_KEY::ICON, "folder-cloud"},
			{FMH::MODEL_KEY::LABEL, map[FMH::MODEL_NAME[FMH::MODEL_KEY::USER]].toString()},
			{FMH::MODEL_KEY::USER, map[FMH::MODEL_NAME[FMH::MODEL_KEY::USER]].toString()},
			{FMH::MODEL_KEY::SERVER, map[FMH::MODEL_NAME[FMH::MODEL_KEY::SERVER]].toString()},
			{FMH::MODEL_KEY::PASSWORD, map[FMH::MODEL_NAME[FMH::MODEL_KEY::PASSWORD]].toString()},
			{FMH::MODEL_KEY::TYPE,  FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::CLOUD_PATH]}};
	}
	return res;
}

void FM::createCloudDir(const QString &path, const QString &name)
{
	qDebug()<< "trying to create folder at"<< path;
	this->sync->createDir(path, name);
}

void FM::openCloudItem(const QVariantMap &item)
{
	qDebug()<< item;
	FMH::MODEL data;
	for(const auto &key : item.keys())
		data.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());
	
	this->sync->resolveFile(data, Syncing::SIGNAL_TYPE::OPEN);
}

void FM::getCloudItem(const QVariantMap &item)
{
	qDebug()<< item;
	FMH::MODEL data;
	for(const auto &key : item.keys())
		data.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());
	
	this->sync->resolveFile(data, Syncing::SIGNAL_TYPE::DOWNLOAD);
}

QVariantList FM::getCloudAccountsList()
{
	QVariantList res;
	
	const auto data = this->getCloudAccounts();
		for(const auto &item : data)
		res << FM::toMap(item);
	
	return res;
}

bool FM::addCloudAccount(const QString &server, const QString &user, const QString &password)
{
	const QVariantMap account = {
		{FMH::MODEL_NAME[FMH::MODEL_KEY::SERVER], server},
		{FMH::MODEL_NAME[FMH::MODEL_KEY::USER], user},
		{FMH::MODEL_NAME[FMH::MODEL_KEY::PASSWORD], password}
	};
	
	if(this->insert(FMH::TABLEMAP[FMH::TABLE::CLOUDS], account))
	{
		emit this->cloudAccountInserted(user);
		return true;
	}
	
	return false;
}

bool FM::removeCloudAccount(const QString &server, const QString &user)
{
	FMH::DB account = {
		{FMH::MODEL_KEY::SERVER, server},
		{FMH::MODEL_KEY::USER, user},
	};
	
	if(this->remove(FMH::TABLEMAP[FMH::TABLE::CLOUDS], account))
	{
		emit this->cloudAccountRemoved(user);
		return true;
	}
	
	return false;
}

QString FM::resolveUserCloudCachePath(const QString &server, const QString &user)
{
	return FMH::CloudCachePath+"opendesktop/"+user;
}

QString FM::resolveLocalCloudPath(const QString& path)
{
	return QString(path).replace(FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]+this->sync->getUser(), "");
}

FMH::MODEL_LIST FM::getTagContent(const QString &tag)
{
	FMH::MODEL_LIST content;
	
	qDebug()<< "TAG CONTENT FOR TAG"<< tag;
	
	for(const auto &data : this->tag->getUrls(tag, false))
	{
		const auto url = data.toMap().value(TAG::KEYMAP[TAG::KEYS::URL]).toString();
		auto item = FMH::getFileInfoModel(QUrl::fromLocalFile(url));
		content << item;
	}
	
	return content;
}

QVariantMap FM::getDirInfo(const QUrl &path, const QString &type)
{
	return FMH::getDirInfo(path, type);
}

QVariantMap FM::getFileInfo(const QUrl &path)
{
	return FMH::getFileInfo(path);
}

bool FM::isDefaultPath(const QString &path)
{
	return FMH::defaultPaths.contains(path);
}

QUrl FM::parentDir(const QUrl &path)
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

bool FM::isDir(const QUrl &path)
{
	if(!path.isLocalFile())
	{
		qWarning() << "URL recived is not a local file. FM::isDir" << path;
		return false;	  
	}	
	
	QFileInfo file(path.toLocalFile());
	return file.isDir();
}

bool FM::isApp(const QString& path)
{
	return /*QFileInfo(path).isExecutable() ||*/ path.endsWith(".desktop");
}

bool FM::isCloud(const QUrl &path)
{
	return path.scheme() == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::CLOUD_PATH];
}

bool FM::fileExists(const QUrl &path)
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

QString FM::formatSize(const int &size)
{
	QLocale locale;
	return locale.formattedDataSize(size);
}

QString FM::formatDate(const QString &dateStr, const QString &format, const QString &initFormat)
{
	QDateTime date;
	if( initFormat.isEmpty() )
		date = QDateTime::fromString(dateStr, Qt::TextDate);
	else
		date = QDateTime::fromString(dateStr, initFormat);
	return date.toString(format);
}

QString FM::homePath()
{
	return FMH::HomePath;
}

bool FM::cut(const QVariantList &data, const QString &where)
{	
	FMH::MODEL_LIST items;
	
	for(const auto &k : data)		
		items << FM::toModel(k.toMap());
	
	
	for(const auto &item : items)
	{
		const auto path = item[FMH::MODEL_KEY::PATH];
		
		if(this->isCloud(path))
		{
			this->sync->setCopyTo(where);			
			this->sync->resolveFile(item, Syncing::SIGNAL_TYPE::COPY);
			
		}else if(FMH::fileExists(path))
		{
			#ifdef Q_OS_ANDROID
			QFile file(QUrl(path).toLocalFile());
			file.rename(where+"/"+QFileInfo(QUrl(path).toLocalFile()).fileName());
			#else			
			auto job = KIO::move(QUrl(path), QUrl(where+"/"+FMH::getFileInfoModel(path)[FMH::MODEL_KEY::LABEL]));
			job->start();
			#endif
		}
	}
	
	return true;
}

bool FM::copy(const QVariantList &data, const QString &where)
{
	FMH::MODEL_LIST items;
	for(const auto &k : data)		
		items << FM::toModel(k.toMap());
	
	
	QStringList cloudPaths;	
	for(const auto &item : items)
	{
		const auto path = item[FMH::MODEL_KEY::PATH];
		if(this->isDir(path))
		{
			return FM::copyPath(path, where+"/"+QFileInfo(path).fileName(), false);
			
		}else if(this->isCloud(path))
		{
			this->sync->setCopyTo(where);			
			this->sync->resolveFile(item, Syncing::SIGNAL_TYPE::COPY);
			
		}else if(FMH::fileExists(path))
		{
			if(this->isCloud(where))
				cloudPaths << path;
			else
				FM::copyPath(path, where+"/"+FMH::getFileInfoModel(path)[FMH::MODEL_KEY::LABEL], false);			
		}
	}
	
	if(!cloudPaths.isEmpty())
	{
		qDebug()<<"UPLOAD QUEUE" << cloudPaths;		
		const auto firstPath = cloudPaths.takeLast();
		this->sync->setUploadQueue(cloudPaths);
		
		if(where.split("/").last().contains("."))		
		{
			QStringList whereList = where.split("/");
			whereList.removeLast();
			auto whereDir = whereList.join("/");			
			qDebug()<< "Trying ot copy to cloud" << where << whereDir;
			
			this->sync->upload(this->resolveLocalCloudPath(whereDir), firstPath);
		} else
			this->sync->upload(this->resolveLocalCloudPath(where), firstPath);		
	}
	
	return true;
}

bool FM::copyPath(QUrl sourceDir, QUrl destinationDir, bool overWriteDirectory)
{
	#ifdef Q_OS_ANDROID	
	QFileInfo fileInfo(sourceDir.toLocalFile());
	if(fileInfo.isFile())		
		QFile::copy(sourceDir.toLocalFile(), destinationDir.toLocalFile());	
	
	QDir originDirectory(sourceDir.toLocalFile());
	
	if (!originDirectory.exists())    
		return false;
	
	QDir destinationDirectory(destinationDir);
	
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
	qDebug()<< "TRYING TO COPY" << sourceDir.toLocalFile() << destinationDir.toLocalFile();
	auto job = KIO::copy(QUrl(sourceDir), QUrl(destinationDir));
	job->start();
	return true;	
	#endif
}

bool FM::removeFile(const QUrl &path)
{
	if(!path.isLocalFile())	
		qWarning() << "URL recived is not a local file, FM::removeFile" << path;	
	
	#ifdef Q_OS_ANDROID
	if(QFileInfo(path.toLocalFile()).isDir())
		return removeDir(path.toLocalFile());
	else return QFile(path.toLocalFile()).remove();
	#else
	auto job = KIO::del(path);
	job->start();
	return true;
	#endif    
}

void FM::moveToTrash(const QUrl &path)
{
	if(!path.isLocalFile())	
		qWarning() << "URL recived is not a local file, FM::moveToTrash" << path;	
	
	#ifdef Q_OS_ANDROID
	#else
	auto job = KIO::trash(path);
	job->start();	
	#endif
}

void FM::emptyTrash()
{
	#ifdef Q_OS_ANDROID
	#else
	auto job = KIO::emptyTrash();
	job->start();	
	#endif
}

bool FM::removeDir(const QUrl &path)
{
	bool result = true;
	QDir dir(path.toLocalFile());
	
	if (dir.exists())
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
		result = dir.rmdir(path.toLocalFile());
	}
	
	return result;
}

bool FM::rename(const QUrl &path, const QString &name)
{
	QFile file(path.toLocalFile());
	const auto url = QFileInfo(path.toLocalFile()).dir().absolutePath();	
	return file.rename(url+"/"+name);
}

bool FM::createDir(const QUrl &path, const QString &name)
{
	return QDir(path.toLocalFile()).mkdir(name);
}

bool FM::createFile(const QUrl &path, const QString &name)
{
	QFile file(path.toLocalFile() + "/" + name);
	
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

void FM::openLocation(const QStringList &urls)
{
	for(auto url : urls)
		QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(url).dir().absolutePath()));
}

void FM::runApplication(const QString& exec)
{
	#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
	return  MAUIKDE::launchApp(exec);
	#endif
}

QVariantMap FM::dirConf(const QUrl &path)
{
	return FMH::dirConf(path);
}

void FM::setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value)
{
	FMH::setDirConf(path, group, key, value);
}

