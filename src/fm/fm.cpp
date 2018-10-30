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

#include <QFlags>
#include <QDateTime>
#include <QFileInfo>
#include <QDesktopServices>
#include <QUrl>
#include <QLocale>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#else
#include "mauikde.h"
#endif


FM *FM::instance = nullptr;

FM* FM::getInstance()
{
	if(!instance)
	{
		instance = new FM();
		qDebug() << "getInstance(): First instance\n";
		instance->tag = Tagging::getInstance("MAUIFM","1.0", "org.kde.maui","MauiKit File Manager");
		
		return instance;
	} else
	{
		qDebug()<< "getInstance(): previous instance\n";
		return instance;
	}
}

FM::FM(QObject *parent) : FMDB(parent)
{
	
}

FM::~FM() 
{
	// 	delete this->instance;
}

FMH::MODEL_LIST FM::packItems(const QStringList &items, const QString &type)
{
	FMH::MODEL_LIST data;
	
	for(auto path : items)
		if(UTIL::fileExists(path))
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

FMH::MODEL_LIST FM::getPathContent(const QString& path, const bool &hidden, const bool &onlyDirs, const QStringList& filters, const QDirIterator::IteratorFlags &iteratorFlags)
{
	FMH::MODEL_LIST content;
	
	if (FM::isDir(path))
	{
		QDir::Filters dirFilter;
		
		dirFilter = (onlyDirs ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot :
		QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);
		
		if(hidden)
			dirFilter = dirFilter | QDir::Hidden | QDir::System;
		
		QDirIterator it (path, filters, dirFilter, iteratorFlags);
		while (it.hasNext())
		{
			auto url = it.next();			
			content << FMH::getFileInfoModel(url);
		}		
	}
	
	return content;
}

FMH::MODEL_LIST FM::getAppsContent(const QString& path)
{
	FMH::MODEL_LIST res;
	#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
	if(path.startsWith(FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::APPS_PATH]+"/"))
		return MAUIKDE::getApps(QString(path).replace(FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::APPS_PATH]+"/",""));
	else
		return MAUIKDE::getApps();
	#endif
	return res;
}

FMH::MODEL_LIST FM::getDefaultPaths()
{
	return packItems(FMH::defaultPaths, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::PLACES_PATH]);
}

FMH::MODEL_LIST FM::getCustomPaths()
{
	#ifdef Q_OS_ANDROID
	return FMH::MODEL_LIST();
	#endif
	
	return FMH::MODEL_LIST
	{
		FMH::MODEL
		{
			{FMH::MODEL_KEY::ICON, "system-run"},
			{FMH::MODEL_KEY::LABEL, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::APPS_PATH]},
			{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::APPS_PATH]+"/"},
			{FMH::MODEL_KEY::TYPE, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::PLACES_PATH]}
		}
	};
}

FMH::MODEL_LIST FM::search(const QString& query, const QString &path, const bool &hidden, const bool &onlyDirs, const QStringList &filters)
{
	FMH::MODEL_LIST content;
	
	if (FM::isDir(path))
	{
		QDir::Filters dirFilter;
		
		dirFilter = (onlyDirs ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot :
		QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);
		
		if(hidden)
			dirFilter = dirFilter | QDir::Hidden | QDir::System;
		
		QDirIterator it (path, filters, dirFilter, QDirIterator::NoIteratorFlags);
		while (it.hasNext())
		{
			auto url = it.next();
			auto info = it.fileInfo();
			qDebug()<< info.completeBaseName() <<  info.completeBaseName().contains(query);
			if(info.completeBaseName().contains(query, Qt::CaseInsensitive))			
				content << FMH::getFileInfoModel(url);
		}		
	}
	
	qDebug()<< content;
	return content;
}

FMH::MODEL_LIST FM::getDevices()
{
	FMH::MODEL_LIST drives;
	
	#if defined(Q_OS_ANDROID)
	drives << packItems({MAUIAndroid::sdDir()}, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::DRIVES_PATH]);
	return drives;
	#else	
	return drives;
	#endif
	
	//     auto devices = QStorageInfo::mountedVolumes();
	//     for(auto device : devices)
	//     {
	//         if(device.isValid() && !device.isReadOnly())
	//         {
	//             QVariantMap drive =
	//             {
	//                 {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], "drive-harddisk"},
	//                 {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], device.displayName()},
	//                 {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], device.rootPath()},
	//                 {FMH::MODEL_NAME[FMH::MODEL_KEY::TYPE], FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::DRIVES]}
	//             };
	// 
	//             drives << drive;
	//         }
	//     }
	
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

FMH::MODEL_LIST FM::getTags(const int &limit)
{
	Q_UNUSED(limit);
	
	FMH::MODEL_LIST data;
	
	if(this->tag)
	{
		for(auto tag : this->tag->getUrlsTags(false))
		{
			qDebug()<< "TAG << "<< tag;
			auto label = tag.toMap().value(TAG::KEYMAP[TAG::KEY::TAG]).toString();
			data << FMH::MODEL
			{
				{FMH::MODEL_KEY::PATH, label},
				{FMH::MODEL_KEY::ICON, "tag"},
				{FMH::MODEL_KEY::LABEL, label},
				{FMH::MODEL_KEY::TYPE,  FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::TAGS_PATH]}
			};
		}
	}
	
	return data;
}

FMH::MODEL_LIST FM::getBookmarks()
{
	QStringList bookmarks;
	for(auto bookmark : this->get("select * from bookmarks"))
		bookmarks << bookmark.toMap().value(FMH::MODEL_NAME[FMH::MODEL_KEY::PATH]).toString();
	
	return packItems(bookmarks, FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::BOOKMARKS_PATH]);
}

FMH::MODEL_LIST FM::getTagContent(const QString &tag)
{
	FMH::MODEL_LIST content;
	
	qDebug()<< "TAG CONTENT FOR TAG"<< tag;
	
	for(auto data : this->tag->getUrls(tag, false))
	{
		auto url = data.toMap().value(TAG::KEYMAP[TAG::KEY::URL]).toString();
		
		auto item = FMH::getFileInfoModel(url);
		item.insert(FMH::MODEL_KEY::THUMBNAIL, url);
		
		content << item;
	}
	
	return content;
}

QVariantMap FM::getDirInfo(const QString &path, const QString &type)
{
	return FMH::getDirInfo(path, type);
}

QVariantMap FM::getFileInfo(const QString &path)
{
	return FMH::getFileInfo(path);
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

bool FM::isApp(const QString& path)
{
	return /*QFileInfo(path).isExecutable() ||*/ path.endsWith(".desktop");	
}

bool FM::bookmark(const QString &path)
{
	if(FMH::defaultPaths.contains(path))
		return false;
	
	if(!FMH::fileExists(path))
		return false;
	
	QFileInfo file (path);
	QVariantMap bookmark_map {
		{FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], path},
		{FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], file.baseName()},
		{FMH::MODEL_NAME[FMH::MODEL_KEY::DATE], QDateTime::currentDateTime()}
	};
	
	if(this->insert(FMH::TABLEMAP[FMH::TABLE::BOOKMARKS], bookmark_map))
	{
		emit this->bookmarkInserted(path);
		return true;
	}
	
	return false;
}

bool FM::removeBookmark(const QString& path)
{
	FMH::DB data = {{FMH::MODEL_KEY::PATH, path}};
	if(this->remove(FMH::TABLEMAP[FMH::TABLE::BOOKMARKS], data))
	{		
		emit this->bookmarkRemoved(path);
		return true;
	}
	
	return false;
}

bool FM::isBookmark(const QString& path)
{
	return this->checkExistance(QString("select * from bookmarks where path = '%1'").arg(path));
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

bool FM::removeFile(const QString &path)
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

void FM::runApplication(const QString& exec)
{
	#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
	return  MAUIKDE::launchApp(exec);
	#endif
}

QVariantMap FM::dirConf(const QString &path)
{
	return FMH::dirConf(path);
}

void FM::setDirConf(const QString &path, const QString &group, const QString &key, const QVariant &value)
{
	FMH::setDirConf(path, group, key, value);
}

