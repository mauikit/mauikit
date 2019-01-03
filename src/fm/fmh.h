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
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QString>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#elif defined(Q_OS_LINUX)
#include <KConfig>
#include <KConfigGroup>
#include <KFileItem>
#endif

namespace FMH
{
	
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
		DOCUMENT,
		NONE
	}; 
	
	static const QHash<FMH::FILTER_TYPE, QStringList> FILTER_LIST =
	{
		{FILTER_TYPE::AUDIO, QStringList {"*.mp3", "*.mp4", "*.wav", "*.ogg", "*.flac"}},
		{FILTER_TYPE::VIDEO, QStringList {"*.mp4", "*.mkv", "*.mov", "*.avi", "*.flv"}},
		{FILTER_TYPE::TEXT, QStringList {"*.txt", "*.cpp", "*.js", "*.doc", "*.h", "*.json", "*.html", "*.rtf"}},
		{FILTER_TYPE::DOCUMENT, QStringList {"*.pdf", "*.txt", "*.cbz", "*.cbr", "*.epub", "*.cbt", "*.cba", "*.cb7"}},
		{FILTER_TYPE::IMAGE, QStringList {"*.png", "*.jpg", "*.jpeg", "*.gif", "*.svg", "*.bmp"}},
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
		TAG,
		PERMISSIONS,
		THUMBNAIL,
		THUMBNAIL_1,
		THUMBNAIL_2,
		THUMBNAIL_3,
		HIDDEN,
		ICONSIZE,
		DETAILVIEW,
		SHOWTHUMBNAIL,
		SHOWTERMINAL,
		COUNT,
        SORTBY,
        USER,
        PASSWORD,
        SERVER,
		FOLDERSFIRST,
		VIEWTYPE,
		ADDDATE,
		FAV,
		COLOR,
		RATE,
		FORMAT,
		PLACE,
		LOCATION,
		ALBUM,
		ARTIST,
		GENRE,
		NOTE,
		COMMENT,
		SOURCE,
		TITLE,
		ID,
		LICENSE,
		DESCRIPTION,
		BOOKMARK
	}; 
	
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
		{MODEL_KEY::TAG, "tag"},
		{MODEL_KEY::PERMISSIONS, "permissions"},
		{MODEL_KEY::THUMBNAIL, "thumbnail"},
		{MODEL_KEY::THUMBNAIL_1, "thumbnail_1"},
		{MODEL_KEY::THUMBNAIL_2, "thumbnail_2"},
		{MODEL_KEY::THUMBNAIL_3, "thumbnail_3"},
		{MODEL_KEY::ICONSIZE, "iconsize"},
		{MODEL_KEY::HIDDEN, "hidden"},
		{MODEL_KEY::DETAILVIEW, "detailview"},
		{MODEL_KEY::SHOWTERMINAL, "showterminal"},
		{MODEL_KEY::SHOWTHUMBNAIL, "showthumbnail"},
		{MODEL_KEY::COUNT, "count"},
        {MODEL_KEY::SORTBY, "sortby"},
        {MODEL_KEY::USER, "user"},
        {MODEL_KEY::PASSWORD, "password"},
		{MODEL_KEY::SERVER, "server"},
		{MODEL_KEY::FOLDERSFIRST, "foldersfirst"},
		{MODEL_KEY::VIEWTYPE, "viewtype"},
		{MODEL_KEY::ADDDATE, "adddate"},
		{MODEL_KEY::FAV, "fav"},
		{MODEL_KEY::COLOR, "color"},
		{MODEL_KEY::RATE, "rate"},
		{MODEL_KEY::FORMAT, "fav"},
		{MODEL_KEY::PLACE, "place"},
		{MODEL_KEY::LOCATION, "location"},
		{MODEL_KEY::ALBUM, "album"},
		{MODEL_KEY::ARTIST, "artist"},
		{MODEL_KEY::GENRE, "genre"},	
		{MODEL_KEY::NOTE, "note"},	
		{MODEL_KEY::COMMENT, "comment"},	
		{MODEL_KEY::SOURCE, "source"},
		{MODEL_KEY::TITLE, "title"},	
		{MODEL_KEY::ID, "id"},	
		{MODEL_KEY::LICENSE, "license"},	
		{MODEL_KEY::DESCRIPTION, "description"},
		{MODEL_KEY::BOOKMARK, "bookmark"}	
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
		{MODEL_NAME[MODEL_KEY::TAG], MODEL_KEY::TAG},
		{MODEL_NAME[MODEL_KEY::PERMISSIONS], MODEL_KEY::PERMISSIONS},
		{MODEL_NAME[MODEL_KEY::THUMBNAIL], MODEL_KEY::THUMBNAIL},
		{MODEL_NAME[MODEL_KEY::THUMBNAIL_1], MODEL_KEY::THUMBNAIL_1},
		{MODEL_NAME[MODEL_KEY::THUMBNAIL_2], MODEL_KEY::THUMBNAIL_2},
		{MODEL_NAME[MODEL_KEY::THUMBNAIL_3], MODEL_KEY::THUMBNAIL_3},
		{MODEL_NAME[MODEL_KEY::ICONSIZE], MODEL_KEY::ICONSIZE},
		{MODEL_NAME[MODEL_KEY::HIDDEN], MODEL_KEY::HIDDEN},
		{MODEL_NAME[MODEL_KEY::DETAILVIEW], MODEL_KEY::DETAILVIEW},
		{MODEL_NAME[MODEL_KEY::SHOWTERMINAL], MODEL_KEY::SHOWTERMINAL},
		{MODEL_NAME[MODEL_KEY::SHOWTHUMBNAIL], MODEL_KEY::SHOWTHUMBNAIL},
		{MODEL_NAME[MODEL_KEY::COUNT], MODEL_KEY::COUNT},
		{MODEL_NAME[MODEL_KEY::SORTBY], MODEL_KEY::SORTBY},
		{MODEL_NAME[MODEL_KEY::USER], MODEL_KEY::USER},
		{MODEL_NAME[MODEL_KEY::PASSWORD], MODEL_KEY::PASSWORD},
		{MODEL_NAME[MODEL_KEY::SERVER], MODEL_KEY::SERVER},
		{MODEL_NAME[MODEL_KEY::VIEWTYPE], MODEL_KEY::VIEWTYPE},
		{MODEL_NAME[MODEL_KEY::ADDDATE], MODEL_KEY::ADDDATE},
		{MODEL_NAME[MODEL_KEY::FAV], MODEL_KEY::FAV},
		{MODEL_NAME[MODEL_KEY::COLOR], MODEL_KEY::COLOR},
		{MODEL_NAME[MODEL_KEY::RATE], MODEL_KEY::RATE},
		{MODEL_NAME[MODEL_KEY::FORMAT], MODEL_KEY::FORMAT},
		{MODEL_NAME[MODEL_KEY::PLACE], MODEL_KEY::PLACE},
		{MODEL_NAME[MODEL_KEY::LOCATION], MODEL_KEY::LOCATION},
		{MODEL_NAME[MODEL_KEY::ALBUM], MODEL_KEY::ALBUM},
		{MODEL_NAME[MODEL_KEY::ARTIST], MODEL_KEY::ARTIST},
		{MODEL_NAME[MODEL_KEY::GENRE], MODEL_KEY::GENRE},
		{MODEL_NAME[MODEL_KEY::FORMAT], MODEL_KEY::FORMAT},
		{MODEL_NAME[MODEL_KEY::NOTE], MODEL_KEY::NOTE},
		{MODEL_NAME[MODEL_KEY::COMMENT], MODEL_KEY::COMMENT},
		{MODEL_NAME[MODEL_KEY::SOURCE], MODEL_KEY::SOURCE},		
		{MODEL_NAME[MODEL_KEY::TITLE], MODEL_KEY::TITLE},		
		{MODEL_NAME[MODEL_KEY::ID], MODEL_KEY::ID},		
		{MODEL_NAME[MODEL_KEY::LICENSE], MODEL_KEY::LICENSE},
		{MODEL_NAME[MODEL_KEY::DESCRIPTION], MODEL_KEY::DESCRIPTION},		
		{MODEL_NAME[MODEL_KEY::BOOKMARK], MODEL_KEY::BOOKMARK}		
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
	};
	
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
		uint count = 0, sortby = FMH::MODEL_KEY::MODIFIED, viewType = 0;
		bool foldersFirst = false;
		
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
		foldersFirst = file.value("FoldersFirst").toBool();
		viewType = file.value("ViewType").toInt();
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
		foldersFirst = file.entryMap(QString("MAUIFM"))["FoldersFirst"] == "true" ? true : false;
		viewType = file.entryMap(QString("MAUIFM"))["ViewType"].toInt();
		#endif
		
		auto res = QVariantMap({
			{FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], icon.isEmpty() ? "folder" : icon},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::ICONSIZE], iconsize},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::COUNT], count},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTERMINAL], showterminal.isEmpty() ? "false" : showterminal},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTHUMBNAIL], showthumbnail.isEmpty() ? "false" : showthumbnail},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::DETAILVIEW], detailview.isEmpty() ? "false" : detailview},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN], hidden.isEmpty() ? false : (hidden == "true" ? true : false)},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::SORTBY], sortby},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::FOLDERSFIRST], foldersFirst},
			{FMH::MODEL_NAME[FMH::MODEL_KEY::VIEWTYPE], viewType}
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
			{FMH::MODEL_KEY::COUNT, file.isDir() ? QString::number(QDir(path).count() - 2) : "0"}			
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
	
	
	class Downloader : public QObject
	{
		Q_OBJECT
	public:
		explicit Downloader(QObject *parent = 0) : QObject(parent)
		{
			this->manager = new QNetworkAccessManager;
		}
		
		virtual ~Downloader()
		{
			this->manager->deleteLater();
		}
		
		void setFile(const QString &fileURL, const QString &fileName = QString())
		{
			QString filePath = fileURL;
			
			if(fileName .isEmpty() || fileURL.isEmpty())			
				return;
			
			QNetworkRequest request;
			request.setUrl(QUrl(fileURL));
			reply = manager->get(request);
			
			file = new QFile;
			file->setFileName(fileName);
			file->open(QIODevice::WriteOnly);
			
			connect(reply,SIGNAL(downloadProgress(qint64,qint64)),this,SLOT(onDownloadProgress(qint64,qint64)));
			connect(manager,SIGNAL(finished(QNetworkReply*)),this,SLOT(onFinished(QNetworkReply*)));
			connect(reply,SIGNAL(readyRead()),this,SLOT(onReadyRead()));
			connect(reply,SIGNAL(finished()),this,SLOT(onReplyFinished()));
		}
		
	private:
		QNetworkAccessManager *manager;
		QNetworkReply *reply;
		QFile *file;
		
	signals:
		void progress(int percent);
		void downloadReady();
		void fileSaved(QString path);
		void warning(QString warning);
		
	private slots:
		void onDownloadProgress(qint64 bytesRead, qint64 bytesTotal)
		{			
			emit this->progress((bytesRead * bytesTotal) / 100);
		}
		
		void onFinished(QNetworkReply* reply)
		{
			switch(reply->error())
			{
				case QNetworkReply::NoError:
				{
					qDebug("file is downloaded successfully.");
					emit this->downloadReady();
				}break;
				default:{
					emit this->warning(reply->errorString());
				};
			}
			
			if(file->isOpen())
			{
				file->close();
				emit this->fileSaved(file->fileName());			
				file->deleteLater();
			}
		}
		
		void onReadyRead()
		{
			file->write(reply->readAll());
// 			emit this->fileSaved(file->fileName());			
		}
		
		void onReplyFinished()
		{
			if(file->isOpen())
			{
				file->close();
// 				emit this->fileSaved(file->fileName());
				file->deleteLater();
			}
		}
	};
	
}

#endif // FMH_H
