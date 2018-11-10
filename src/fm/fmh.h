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

#ifndef FMH_H
#define FMH_H

#include <QStandardPaths>
#include <QFileInfo>
#include <QDebug>
#include <QDirIterator>
#include <QMimeType>
#include <QMimeData>
#include <QMimeDatabase>
#include <QSettings>
#include <QDateTime>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#elif defined(Q_OS_LINUX)
#include <KConfig>
#include <KConfigGroup>
#include <KFileItem>
#endif

namespace FMH
{
	Q_NAMESPACE
	
	inline bool isAndroid()
	{
		#if defined(Q_OS_ANDROID)
		return true;
		#elif defined(Q_OS_LINUX)
		return false;
		#elif defined(Q_OS_WIN32)
		return false;
		#elif defined(Q_OS_WIN64)
		return false;
		#elif defined(Q_OS_MACOS)
		return false;
		#elif defined(Q_OS_IOS)
		return false;
		#elif defined(Q_OS_HAIKU)
		return false;
		#endif
	}
	
	enum FILTER_TYPE : uint_fast8_t
	{
		AUDIO,
		VIDEO,
		TEXT,
		IMAGE,
		NONE
	}; Q_ENUM_NS(FILTER_TYPE);
	
	static const QHash<FMH::FILTER_TYPE, QStringList> FILTER_LIST =
	{
		{FILTER_TYPE::AUDIO, {"*.mp3", "*.mp4", "*.wav", "*.ogg", "*.flac"}},
		{FILTER_TYPE::VIDEO, {"*.mp4", "*.mkv", "*.mov", "*.avi", "*.flv"}},
		{FILTER_TYPE::TEXT, {"*.txt", "*.cpp", "*.js", "*.doc", "*.h", "*.json", "*.html", "*.rtf"}},
		{FILTER_TYPE::IMAGE, {"*.png", "*.jpg", "*.jpeg", "*.gif", "*.svg", "*.bmp"}},
		{FILTER_TYPE::NONE, QStringList()}
	};
	
	enum MODEL_KEY : uint_fast8_t
	{
		ICON,
		LABEL,
		PATH,
		URL,
		TYPE,
		GROUP,
		OWNER,
		SUFFIX,
		NAME,
		DATE,
		SIZE,
		MODIFIED,
		MIME,
		TAGS,
		PERMISSIONS,
		THUMBNAIL,
		HIDDEN,
		ICONSIZE,
		DETAILVIEW,
		SHOWTHUMBNAIL,
		SHOWTERMINAL,
		COUNT,
        SORTBY,
        USER,
        PASSWORD,
        SERVER
	}; Q_ENUM_NS(MODEL_KEY);
	
	static const QHash<FMH::MODEL_KEY, QString> MODEL_NAME =
	{
		{MODEL_KEY::ICON, "icon"},
		{MODEL_KEY::LABEL, "label"},
		{MODEL_KEY::PATH, "path"},
		{MODEL_KEY::URL, "url"},
		{MODEL_KEY::TYPE, "type"},
		{MODEL_KEY::GROUP, "group"},
		{MODEL_KEY::OWNER, "owner"},
		{MODEL_KEY::SUFFIX, "suffix"},
		{MODEL_KEY::NAME, "name"},
		{MODEL_KEY::DATE, "date"},
		{MODEL_KEY::MODIFIED, "modified"},
		{MODEL_KEY::MIME, "mime"},
		{MODEL_KEY::SIZE, "size"},
		{MODEL_KEY::TAGS, "tags"},
		{MODEL_KEY::PERMISSIONS, "permissions"},
		{MODEL_KEY::THUMBNAIL, "thumbnail"},
		{MODEL_KEY::ICONSIZE, "iconsize"},
		{MODEL_KEY::HIDDEN, "hidden"},
		{MODEL_KEY::DETAILVIEW, "detailview"},
		{MODEL_KEY::SHOWTERMINAL, "showterminal"},
		{MODEL_KEY::SHOWTHUMBNAIL, "showthumbnail"},
		{MODEL_KEY::COUNT, "count"},
        {MODEL_KEY::SORTBY, "sortby"},
        {MODEL_KEY::USER, "user"},
        {MODEL_KEY::PASSWORD, "password"},
        {MODEL_KEY::SERVER, "server"}
    };
	
	static const QHash<QString, FMH::MODEL_KEY> MODEL_NAME_KEY =
	{
		{MODEL_NAME[MODEL_KEY::ICON], MODEL_KEY::ICON},
		{MODEL_NAME[MODEL_KEY::LABEL], MODEL_KEY::LABEL},
		{MODEL_NAME[MODEL_KEY::PATH], MODEL_KEY::PATH},
		{MODEL_NAME[MODEL_KEY::URL], MODEL_KEY::URL},
		{MODEL_NAME[MODEL_KEY::TYPE], MODEL_KEY::TYPE},
		{MODEL_NAME[MODEL_KEY::GROUP], MODEL_KEY::GROUP},
		{MODEL_NAME[MODEL_KEY::OWNER], MODEL_KEY::OWNER},
		{MODEL_NAME[MODEL_KEY::SUFFIX], MODEL_KEY::SUFFIX},
		{MODEL_NAME[MODEL_KEY::NAME], MODEL_KEY::NAME},
		{MODEL_NAME[MODEL_KEY::DATE], MODEL_KEY::DATE},
		{MODEL_NAME[MODEL_KEY::MODIFIED], MODEL_KEY::MODIFIED},
		{MODEL_NAME[MODEL_KEY::MIME], MODEL_KEY::MIME},
		{MODEL_NAME[MODEL_KEY::SIZE], MODEL_KEY::SIZE,},
		{MODEL_NAME[MODEL_KEY::TAGS], MODEL_KEY::TAGS},
		{MODEL_NAME[MODEL_KEY::PERMISSIONS], MODEL_KEY::PERMISSIONS},
		{MODEL_NAME[MODEL_KEY::THUMBNAIL], MODEL_KEY::THUMBNAIL},
		{MODEL_NAME[MODEL_KEY::ICONSIZE], MODEL_KEY::ICONSIZE},
		{MODEL_NAME[MODEL_KEY::HIDDEN], MODEL_KEY::HIDDEN},
		{MODEL_NAME[MODEL_KEY::DETAILVIEW], MODEL_KEY::DETAILVIEW},
		{MODEL_NAME[MODEL_KEY::SHOWTERMINAL], MODEL_KEY::SHOWTERMINAL},
		{MODEL_NAME[MODEL_KEY::SHOWTHUMBNAIL], MODEL_KEY::SHOWTHUMBNAIL},
		{MODEL_NAME[MODEL_KEY::COUNT], MODEL_KEY::COUNT},
		{MODEL_NAME[MODEL_KEY::SORTBY], MODEL_KEY::SORTBY},
		{MODEL_NAME[MODEL_KEY::USER], MODEL_KEY::USER},
		{MODEL_NAME[MODEL_KEY::PASSWORD], MODEL_KEY::PASSWORD},
		{MODEL_NAME[MODEL_KEY::SERVER], MODEL_KEY::SERVER}
	};
	
	typedef QHash<FMH::MODEL_KEY, QString> MODEL;
	typedef QList<MODEL> MODEL_LIST;
	
	enum PATHTYPE_KEY : uint_fast8_t
	{
		PLACES_PATH,
		DRIVES_PATH,
		BOOKMARKS_PATH,
		TAGS_PATH,
		APPS_PATH,
		TRASH_PATH,
        SEARCH_PATH,
        CLOUD_PATH
	}; Q_ENUM_NS(PATHTYPE_KEY);
	
	static const QHash<PATHTYPE_KEY, QString> PATHTYPE_NAME =
	{
		{PATHTYPE_KEY::PLACES_PATH, "Places"},
		{PATHTYPE_KEY::DRIVES_PATH, "Drives"},
		{PATHTYPE_KEY::BOOKMARKS_PATH, "Bookmarks"},
		{PATHTYPE_KEY::APPS_PATH, "Apps"},
		{PATHTYPE_KEY::TRASH_PATH, "Trash"},
		{PATHTYPE_KEY::TAGS_PATH, "Tags"},
        {PATHTYPE_KEY::SEARCH_PATH, "Search"},
        {PATHTYPE_KEY::CLOUD_PATH, "Cloud"}
	};
	
	const QString DataPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
	const QString CloudCachePath = FMH::DataPath+"/Cloud/";
	
	#if defined(Q_OS_ANDROID)
	const QString PicturesPath = PATHS::PicturesPath;
	const QString DownloadsPath = PATHS::DownloadsPath;
	const QString DocumentsPath = PATHS::DocumentsPath;
	const QString HomePath = PATHS::HomePath;
	const QString MusicPath = PATHS::MusicPath;
	const QString VideosPath = PATHS::VideosPath;
	
	const QStringList defaultPaths =
	{
		HomePath,
		DocumentsPath,
		PicturesPath,
		MusicPath,
		VideosPath,
		DownloadsPath
	};
	
	const QMap<QString, QString> folderIcon
	{
		{PicturesPath, "folder-pictures"},
		{DownloadsPath, "folder-download"},
		{DocumentsPath, "folder-documents"},
		{HomePath, "user-home"},
		{MusicPath, "folder-music"},
		{VideosPath, "folder-videos"},
	};	
	
	#else
	const QString PicturesPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
	const QString DownloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
	const QString DocumentsPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
	const QString HomePath =  QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
	const QString MusicPath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
	const QString VideosPath = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
	const QString DesktopPath = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
	const QString AppsPath = QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
	const QString RootPath = "/";
	const QStringList defaultPaths =
	{
		HomePath,
		DesktopPath,
		DocumentsPath,
		PicturesPath,
		MusicPath,
		VideosPath,
		DownloadsPath
	};
	
	const QMap<QString, QString> folderIcon
	{
		{PicturesPath, "folder-pictures"},
		{DownloadsPath, "folder-download"},
		{DocumentsPath, "folder-documents"},
		{HomePath, "user-home"},
		{MusicPath, "folder-music"},
		{VideosPath, "folder-videos"},
		{DesktopPath, "user-desktop"},
		{AppsPath, "system-run"},
		{RootPath, "folder-root"}
	};
	
	#endif	
	
	inline bool fileExists(const QString &url)
	{
		QFileInfo path(url);
		if (path.exists()) return true;
		else return false;
	}
	
	inline QVariantMap dirConf(const QString &path)
	{
		if(!FMH::fileExists(path))
			return QVariantMap();
		
		QString icon, iconsize, hidden, detailview, showthumbnail, showterminal;
		uint count = 0, sortby = FMH::MODEL_KEY::MODIFIED;
		
		#ifdef Q_OS_ANDROID
		QSettings file(path, QSettings::Format::NativeFormat);
		file.beginGroup(QString("Desktop Entry"));
		icon = file.value("Icon").toString();
		file.endGroup();
		
		file.beginGroup(QString("Settings"));
		hidden = file.value("HiddenFilesShown").toString();
		file.endGroup();
		
		file.beginGroup(QString("MAUIFM"));
		iconsize =  file.value("IconSize").toString();
		detailview = file.value("DetailView").toString();
		showthumbnail = file.value("ShowThumbnail").toString();
		showterminal = file.value("ShowTerminal").toString();		
		count = file.value("Count").toInt();
		sortby = file.value("SortBy").toInt();
		file.endGroup();
		
		#else
		KConfig file(path);
		icon =  file.entryMap(QString("Desktop Entry"))["Icon"];
		hidden = file.entryMap(QString("Settings"))["HiddenFilesShown"];
		iconsize = file.entryMap(QString("MAUIFM"))["IconSize"];
		detailview = file.entryMap(QString("MAUIFM"))["DetailView"];
		showthumbnail = file.entryMap(QString("MAUIFM"))["ShowThumbnail"];
		showterminal = file.entryMap(QString("MAUIFM"))["ShowTerminal"];
		count = file.entryMap(QString("MAUIFM"))["Count"].toInt();
		sortby = file.entryMap(QString("MAUIFM"))["SortBy"].toInt();
		#endif
		
		auto res = QVariantMap({
			{FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], icon.isEmpty() ? "folder" : icon},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::ICONSIZE], iconsize},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::COUNT], count},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTERMINAL], showterminal.isEmpty() ? "false" : showterminal},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTHUMBNAIL], showthumbnail.isEmpty() ? "false" : showthumbnail},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::DETAILVIEW], detailview.isEmpty() ? "false" : detailview},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN], hidden.isEmpty() ? false : (hidden == "true" ? true : false)}
		});
		
		return res;
	}
	
	inline void setDirConf(const QString &path, const QString &group, const QString &key, const QVariant &value)
	{
		#ifdef Q_OS_ANDROID
		QSettings file(path, QSettings::Format::IniFormat);
		file.beginGroup(group);
		file.setValue(key, value);
		file.endGroup();
		file.sync();
		#else
		KConfig file(path);
		auto kgroup = file.group(group);
		kgroup.writeEntry(key, value);
		#endif
	}
	
	inline QString getIconName(const QString &path)
	{
		if(QFileInfo(path).isDir())
		{
			if(folderIcon.contains(path))
				return folderIcon[path];
			else
			{
				auto icon = FMH::dirConf(QString(path+"/%1").arg(".directory"))[FMH::MODEL_NAME[FMH::MODEL_KEY::ICON]].toString();
				return icon.isEmpty() ? "folder" : icon;
			}
			
		}else {
			
			#if defined(Q_OS_ANDROID)
			QMimeDatabase mime;
			auto type = mime.mimeTypeForFile(path);
            return type.iconName();
			#else
			KFileItem mime(path);
			return mime.iconName();
			#endif
		}
	}
	
	inline QString getMime(const QString &path)
	{
		QMimeDatabase mimedb;
		auto mime = mimedb.mimeTypeForFile(path).name();
		
		return mime;
	}
	
	enum class TABLE : uint8_t
	{
        BOOKMARKS,
        CLOUDS
	};
	
	static const QMap<FMH::TABLE, QString> TABLEMAP =
	{
        {TABLE::BOOKMARKS, "bookmarks"},
        {TABLE::CLOUDS, "clouds"}
    };
	
	typedef QMap<FMH::MODEL_KEY, QString> DB;
	
	const QString FMPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/maui/fm/";
	const QString DBName = "fm.db";
	
	
	inline QVariantMap getDirInfo(const QString &path, const QString &type = QString())
	{
		QFileInfo file (path);
		if(!file.exists()) return QVariantMap();
		
		QVariantMap data =
		{
			{FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], FMH::getIconName(path)},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], file.baseName()},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], path},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::TYPE], type}
		};
		
		return data;
	}
	
	inline FMH::MODEL getFileInfoModel(const QString &path)
	{
		QFileInfo file(path);
		if(!file.exists()) return FMH::MODEL();
		
		auto mime = FMH::getMime(path);
// 		QLocale locale;
		
		FMH::MODEL res =
		{
			{FMH::MODEL_KEY::GROUP, file.group()},
			{FMH::MODEL_KEY::OWNER, file.owner()},
			{FMH::MODEL_KEY::SUFFIX, file.completeSuffix()},
			{FMH::MODEL_KEY::LABEL, /*file.isDir() ? file.baseName() :*/ path == FMH::HomePath ? QStringLiteral("Home") : file.fileName()},
			{FMH::MODEL_KEY::NAME, file.fileName()},
			{FMH::MODEL_KEY::DATE,  file.birthTime().toString(Qt::TextDate)},
			{FMH::MODEL_KEY::MODIFIED, file.lastModified().toString(Qt::TextDate)},
			{FMH::MODEL_KEY::MIME, mime },
			{FMH::MODEL_KEY::ICON, FMH::getIconName(path)},
			{FMH::MODEL_KEY::SIZE, QString::number(file.size()) /*locale.formattedDataSize(file.size())*/},
			{FMH::MODEL_KEY::PATH, path},
			{FMH::MODEL_KEY::THUMBNAIL, path},
			{FMH::MODEL_KEY::COUNT, file.isDir() ? QString::number(QDir(path).count()) : "0"}
			
		};
		
		return res;
	}	
	
	inline QVariantMap getFileInfo(const QString &path)
	{
		QFileInfo file(path);
		if(!file.exists()) return QVariantMap();
		auto data = FMH::getFileInfoModel(path);
		QVariantMap res; 
		for(auto key : data.keys())		
			res.insert(FMH::MODEL_NAME[key], data[key]);
		
		return res;
	}	
	
	
}

#endif // FMH_H
