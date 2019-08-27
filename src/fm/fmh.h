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
#include <QVector>
#include <QHash>
#include <QUrl>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#elif defined(Q_OS_LINUX)
#include <KConfig>
#include <KConfigGroup>
#include <KFileItem>
#include <KFilePlacesModel>
#endif
/**
 *base key implementation model
 */
namespace PRIV
{
  template<typename T>
  struct __KEY
  {
    T value;
    QString n;
    QString label;
    uint operator[](std::string)
    {
      return value;
    }

    T operator()()
    {
      return value;
    }

    bool operator==(const __KEY &other) const
    {
      return (value == other.value
              && n == other.n);
    }

    inline operator uint()const
    {
      return value;
    }
  };

  typedef struct
  {
    QString n;
    QString label;
  } PUBLIC_KEY;


  // boilerplate code for custom qhash keys to work with qt
  inline uint qHash(const __KEY<uint> &key)
  {
    return qHash(key.n) ^ key.value;
  }

  // anon struct that holds the static list of keys on a keyring
  static struct
  {
    QHash<QString, __KEY<uint>> values;
    __KEY<uint>& operator << (const PUBLIC_KEY &__val)
    {

      if(values.contains(__val.n))
        {
          values[__val.n].n =  __val.n;
          values[__val.n].label = __val.label;
        }
      else {

          values[__val.n] = {static_cast<unsigned int>(values.size()), __val.n, __val.label};
        }

      return (values[__val.n]);
    }

    __KEY<uint>& operator[] (const QString &n)
    {
      return values[n];
    }

  } KEYDB;
}

namespace KEYS
{
  //type aliases
  typedef QHash<QString, PRIV::__KEY<uint>> KEYRING; // the keyring containing the registered keys
  typedef PRIV::__KEY<uint> KEY; // alias to the wanted type of key with uint

  inline static const KEY& _SET (const QString &value)
  {
    return PRIV::KEYDB << PRIV::PUBLIC_KEY {value , QString()};
  }

  inline static const KEY& _SET (const  PRIV::PUBLIC_KEY &value)
  {
    return PRIV::KEYDB << value;
  }


  inline static const KEYRING& _VALUES()
  {
    return PRIV::KEYDB.values;
  }

  inline static const QStringList _NAMES()
  {
    return std::accumulate(PRIV::KEYDB.values.constBegin(), PRIV::KEYDB.values.constEnd(), QStringList(), [](QStringList &res, const KEY &key)
    {
        res << key.n;
        return res;
      });
  }

  inline static const QVector<uint> _KEYS()
  {
    return std::accumulate(PRIV::KEYDB.values.constBegin(), PRIV::KEYDB.values.constEnd(), QVector<uint>(), [](QVector<uint> &res, const KEY &key)
    {
        res << key.value;
        return res;
      });
  }

  inline static uint _COUNT()
  {
    return uint (KEYS::_VALUES().count());
  }

  static struct
  {
    inline const decltype(KEY::n)& operator()(const KEY & k)
    {
      return k.n;
    }

    inline const decltype(KEY::n)& operator[](const KEY & k)
    {
        return this->operator()(k);
      }
  } _N;

  static struct
  {
    inline const KEY& operator()(const KEYRING::key_type &n)
    {
      return PRIV::KEYDB[n];
    }

    inline const KEY& operator()(const decltype(KEY::value) &value)
    {
      const auto res = std::find_if(PRIV::KEYDB.values.constBegin(), PRIV::KEYDB.values.constEnd(), [&value](const KEY &key) -> bool
      {
          return key.value == value;
        });

      return res.value();
    }

    inline const KEY& operator[](const KEYRING::key_type &n)
    {
      return this->operator()(n);
    }

    inline const KEY& operator[](const decltype(KEY::value) &value)
    {
      return this->operator()(value);
    }
  } _K;

  static const auto &ICON= _SET("icon");
  static const auto &LABEL = _SET("label");
  static const auto &PATH = _SET("path");
  static const auto &URL = _SET("url");
  static const auto &TYPE = _SET("type");
  static const auto &GROUP = _SET("group");
  static const auto &OWNER = _SET("owner");
  static const auto &SUFFIX = _SET("suffix");
  static const auto &NAME = _SET("name");
  static const auto &DATE = _SET("date");
  static const auto &MODIFIED = _SET("modified");
  static const auto &MIME = _SET("mime");
  static const auto &SIZE = _SET("size");
  static const auto &TAG = _SET("tag");
  static const auto &PERMISSIONS = _SET("permissions");
  static const auto &THUMBNAIL = _SET("thumbnail");
  static const auto &THUMBNAIL_1 = _SET("thumbnail_1");
  static const auto &THUMBNAIL_2 = _SET("thumbnail_2");
  static const auto &THUMBNAIL_3 = _SET("thumbnail_3");
  static const auto &ICONSIZE = _SET("iconsize");
  static const auto &HIDDEN = _SET("hidden");
  static const auto &DETAILVIEW = _SET("detailview");
  static const auto &SHOWTERMINAL = _SET("showterminal");
  static const auto &SHOWTHUMBNAIL = _SET("showthumbnail");
  static const auto &COUNT = _SET("count");
  static const auto &SORTBY = _SET("sortby");
  static const auto &USER = _SET("user");
  static const auto &PASSWORD = _SET("password");
  static const auto &SERVER = _SET("server");
  static const auto &FOLDERSFIRST = _SET("foldersfirst");
  static const auto &VIEWTYPE = _SET("viewtype");
  static const auto &ADDDATE = _SET("adddate");
  static const auto &FAV = _SET("fav");
  static const auto &FAVORITE = _SET("favorite");
  static const auto &COLOR = _SET("color");
  static const auto &RATE = _SET("rate");
  static const auto &FORMAT = _SET("format");
  static const auto &PLACE = _SET("place");
  static const auto &LOCATION = _SET("location");
  static const auto &ALBUM = _SET("album");
  static const auto &DURATION = _SET("duration");
  static const auto &RELEASEDATE = _SET("releasedate");
  static const auto &ARTIST = _SET("artist");
  static const auto &LYRICS = _SET("lyrics");
  static const auto &TRACK = _SET("track");
  static const auto &GENRE = _SET("genre");
  static const auto &WIKI = _SET("wiki");
  static const auto &CONTEXT = _SET("context");
  static const auto &SOURCETYPE = _SET("sourcetype");
  static const auto &ARTWORK= _SET("artwork");
  static const auto &NOTE = _SET("note");
  static const auto &MOOD = _SET("mood");
  static const auto &COMMENT = _SET("comment");
  static const auto &PLAYLIST = _SET("playlist");
  static const auto &SOURCE = _SET("source");
  static const auto &TITLE = _SET("title");
  static const auto &ID = _SET("id");
  static const auto &LICENSE = _SET("license");
  static const auto &DESCRIPTION = _SET("description");
  static const auto &BOOKMARK = _SET("bookmark");
  static const auto &ACCOUNT = _SET("account");
  static const auto &ACCOUNTTYPE= _SET("accounttype");
  static const auto &VERSION = _SET("version");
  static const auto &DOMAIN = _SET("domain");
  static const auto &CATEGORY = _SET("category");
  static const auto &CONTENT = _SET("content");
  static const auto &PIN = _SET("pin");
  static const auto &IMG = _SET("img");
  static const auto &PREVIEW = _SET("preview");
  static const auto &LINK = _SET("link");
  static const auto &STAMP = _SET("stamp");

  /** ccdav keys **/
  static const auto &N = _SET("n");
  static const auto &IM = _SET("im");
  static const auto &PHOTO = _SET("photo");
  static const auto &GENDER = _SET("gender");
  static const auto &ADR = _SET("adr");
  static const auto &ADR_2 = _SET("adr2");
  static const auto &ADR_3 = _SET("adr3");
  static const auto &EMAIL= _SET("email");
  static const auto &EMAIL_2 = _SET("email2");
  static const auto &EMAIL_3 = _SET("email3");
  static const auto &LANG= _SET("lang");
  static const auto &NICKNAME = _SET("nickname");
  static const auto &ORG = _SET("org");
  static const auto &PROFILE = _SET("profile");
  static const auto &TZ = _SET("tz");
  static const auto &TEL = _SET("tel");
  static const auto &TEL_2 = _SET("tel2");
  static const auto &TEL_3 = _SET("tel3");

  static const auto &CITY = _SET("city");
  static const auto &STATE = _SET("state");
  static const auto &COUNTRY = _SET("country");
};

namespace MODELS
{
  typedef QHash<KEYS::KEY, QString> MODEL;
  typedef QVector<MODEL> MODEL_LIST;
}

// boilerplate code for custom qhash keys to work with qt
inline uint qHash(const KEYS::KEY &key)
{
  return qHash(key.n) ^ key.value;
}


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
	
    enum FILTER_TYPE : int
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
	
    typedef MODELS::MODEL MODEL;
	typedef MODELS::MODEL_LIST MODEL_LIST;
	
	struct PATH_CONTENT
	{
		QString path;
		FMH::MODEL_LIST content;
	};
	
#ifdef Q_OS_ANDROID
    enum PATHTYPE_KEY : int
	{
        PLACES_PATH,
        REMOTE_PATH,
        DRIVES_PATH,
        REMOVABLE_PATH,
        TAGS_PATH,
        UNKNOWN_TYPE,
        APPS_PATH,
        TRASH_PATH,
        SEARCH_PATH,
        CLOUD_PATH,
		FISH_PATH,
		MTP_PATH
	};
#else
    enum PATHTYPE_KEY : int
    {
        PLACES_PATH = KFilePlacesModel::GroupType::PlacesType,
        REMOTE_PATH = KFilePlacesModel::GroupType::RemoteType,
        DRIVES_PATH = KFilePlacesModel::GroupType::DevicesType,
        REMOVABLE_PATH = KFilePlacesModel::GroupType::RemovableDevicesType,
        TAGS_PATH = KFilePlacesModel::GroupType::TagsType,
        UNKNOWN_TYPE = KFilePlacesModel::GroupType::UnknownType,
        APPS_PATH = 9,
        TRASH_PATH = 10,
        SEARCH_PATH = 11,
		CLOUD_PATH = 12,
		FISH_PATH = 13,
		MTP_PATH = 14,
	};
#endif
    static const QHash<PATHTYPE_KEY, QString> PATHTYPE_SCHEME =
	{
		{PATHTYPE_KEY::PLACES_PATH, "file"},
		{PATHTYPE_KEY::DRIVES_PATH, "drives"},
		{PATHTYPE_KEY::APPS_PATH, "apps"},
		{PATHTYPE_KEY::REMOTE_PATH, "remote"},
		{PATHTYPE_KEY::REMOVABLE_PATH, "removable"},
		{PATHTYPE_KEY::UNKNOWN_TYPE, "Unkown"},
		{PATHTYPE_KEY::TRASH_PATH, "trash"},
		{PATHTYPE_KEY::TAGS_PATH, "tags"},
		{PATHTYPE_KEY::SEARCH_PATH, "search"},
		{PATHTYPE_KEY::CLOUD_PATH, "cloud"},
		{PATHTYPE_KEY::FISH_PATH, "fish"},
		{PATHTYPE_KEY::MTP_PATH, "mtp"}
	};
	
	static const QHash<PATHTYPE_KEY, QString> PATHTYPE_URI =
	{
		{PATHTYPE_KEY::PLACES_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::PLACES_PATH] + "://"},
		{PATHTYPE_KEY::DRIVES_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::DRIVES_PATH] + "://"},
		{PATHTYPE_KEY::APPS_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::APPS_PATH] + "://"},
		{PATHTYPE_KEY::REMOTE_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::REMOTE_PATH] + "://"},
		{PATHTYPE_KEY::REMOVABLE_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::REMOVABLE_PATH] + "://"},
		{PATHTYPE_KEY::UNKNOWN_TYPE, PATHTYPE_SCHEME[PATHTYPE_KEY::UNKNOWN_TYPE] + "://"},
		{PATHTYPE_KEY::TRASH_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::TRASH_PATH] + "://"},
		{PATHTYPE_KEY::TAGS_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::TAGS_PATH] + "://"},
		{PATHTYPE_KEY::SEARCH_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::SEARCH_PATH] + "://"},
		{PATHTYPE_KEY::CLOUD_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::CLOUD_PATH] + "://"},
		{PATHTYPE_KEY::FISH_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::FISH_PATH] + "://"},
		{PATHTYPE_KEY::MTP_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::MTP_PATH] + "://"}
	};
	
	static const QHash<PATHTYPE_KEY, QString> PATHTYPE_LABEL =
	{
		{PATHTYPE_KEY::PLACES_PATH, ("Places")},
		{PATHTYPE_KEY::DRIVES_PATH, ("Drives")},
		{PATHTYPE_KEY::APPS_PATH, ("Apps")},
		{PATHTYPE_KEY::REMOTE_PATH, ("Remote")},
		{PATHTYPE_KEY::REMOVABLE_PATH, ("Removable")},
		{PATHTYPE_KEY::UNKNOWN_TYPE, ("Unknown")},
		{PATHTYPE_KEY::TRASH_PATH, ("Trash")},
		{PATHTYPE_KEY::TAGS_PATH, ("Tags")},
		{PATHTYPE_KEY::SEARCH_PATH, ("Search")},
		{PATHTYPE_KEY::CLOUD_PATH, ("Cloud")},
		{PATHTYPE_KEY::FISH_PATH, ("Remote")},
		{PATHTYPE_KEY::MTP_PATH, ("Drives")}
	};
	
	
	const QString DataPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
	const QString CloudCachePath = FMH::DataPath+"/Cloud/";
	
	#if defined(Q_OS_ANDROID)
    const QString PicturesPath = QUrl::fromLocalFile(PATHS::PicturesPath).toString();
    const QString DownloadsPath = QUrl::fromLocalFile(PATHS::DownloadsPath).toString();
    const QString DocumentsPath = QUrl::fromLocalFile(PATHS::DocumentsPath).toString();
    const QString HomePath = QUrl::fromLocalFile(PATHS::HomePath).toString();
    const QString MusicPath = QUrl::fromLocalFile(PATHS::MusicPath).toString();
    const QString VideosPath = QUrl::fromLocalFile(PATHS::VideosPath).toString();
	
	const QStringList defaultPaths =
	{
        FMH::HomePath,
        FMH::DocumentsPath,
        FMH::PicturesPath,
        FMH::MusicPath,
        FMH::VideosPath,
        FMH::DownloadsPath
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
	const QString PicturesPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)).toString();
	const QString DownloadsPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)).toString();
	const QString DocumentsPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)).toString();
	const QString HomePath =  QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::HomeLocation)).toString();
	const QString MusicPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::MusicLocation)).toString();
	const QString VideosPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::MoviesLocation)).toString();
	const QString DesktopPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation)).toString();
	const QString AppsPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation)).toString();
	const QString RootPath = "file:///";
	const QStringList defaultPaths =
	{
		FMH::HomePath,
		FMH::DesktopPath,
		FMH::DocumentsPath,
		FMH::PicturesPath,
		FMH::MusicPath,
		FMH::VideosPath,
		FMH::DownloadsPath,
		FMH::RootPath
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
	
	/**
	 * Checks if a local file exists.
	 * The URL must represent a local file path, by using the scheme file://
	 **/
	inline bool fileExists(const QUrl &path)
	{		
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return false;	  
		}		
		return QFileInfo::exists(path.toLocalFile());		
	}
	
	
	/**
	 * Return the configuration of a single directory represented
	 * by a QVariantMap.
	 * The passed path must be a local file URL.
	 **/	
	inline QVariantMap dirConf(const QUrl &path)
	{
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return QVariantMap();	  
		}	
		
		if(!FMH::fileExists(path))
			return QVariantMap();
		
		QString icon, iconsize, hidden, detailview, showthumbnail, showterminal;
		
		uint count = 0, sortby = KEYS::MODIFIED, viewType = 0;
		
		bool foldersFirst = false;
		
		#ifdef Q_OS_ANDROID
		QSettings file(path.toLocalFile(), QSettings::Format::NativeFormat);
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
		
		KConfig file(path.toLocalFile());
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
		
		return QVariantMap({
			{KEYS::_N[KEYS::ICON], icon.isEmpty() ? "folder" : icon},
							   {KEYS::_N[KEYS::ICONSIZE], iconsize},
						 {KEYS::_N[KEYS::COUNT], count},
						 {KEYS::_N[KEYS::SHOWTERMINAL], showterminal.isEmpty() ? "false" : showterminal},
							   {KEYS::_N[KEYS::SHOWTHUMBNAIL], showthumbnail.isEmpty() ? "false" : showthumbnail},
							   {KEYS::_N[KEYS::DETAILVIEW], detailview.isEmpty() ? "false" : detailview},
							   {KEYS::_N[KEYS::HIDDEN], hidden.isEmpty() ? false : (hidden == "true" ? true : false)},
							   {KEYS::_N[KEYS::SORTBY], sortby},
						 {KEYS::_N[KEYS::FOLDERSFIRST], foldersFirst},
						 {KEYS::_N[KEYS::VIEWTYPE], viewType}
		});
	}
	
	inline void setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value)
	{
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return;	  
		}		
		
		#ifdef Q_OS_ANDROID
		QSettings file(path.toLocalFile(), QSettings::Format::IniFormat);
		file.beginGroup(group);
		file.setValue(key, value);
		file.endGroup();
		file.sync();
		#else
		KConfig file(path.toLocalFile(), KConfig::SimpleConfig);
		auto kgroup = file.group(group);
		kgroup.writeEntry(key, value);
// 		file.reparseConfiguration();
		file.sync();
		#endif
	}
	
	/**
	 * Returns the icon name for certain file.
	 * The file path must be represented as a local file URL.
	 * It also looks into the directory config file to get custom set icons
	 **/	
	inline QString getIconName(const QUrl &path)
	{
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file. FMH::getIconName" << path;
		}		
		
		if(path.isLocalFile() && QFileInfo(path.toLocalFile()).isDir())
		{
			if(folderIcon.contains(path.toString()))
				return folderIcon[path.toString()];
			else
			{
				auto icon = FMH::dirConf(QString(path.toString()+"/%1").arg(".directory"))[KEYS::_N[KEYS::ICON]].toString();
				return icon.isEmpty() ? "folder" : icon;
			}
			
		}else {
			
			#if defined(Q_OS_ANDROID)
			QMimeDatabase mime;
			auto type = mime.mimeTypeForFile(path.toLocalFile());
			return type.iconName();
			#else
			KFileItem mime(path);
			return mime.iconName();
			#endif
		}
	}
	
	inline QString getMime(const QUrl &path)
	{
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return QString();	  
		}		
		
		const QMimeDatabase mimedb;
		return mimedb.mimeTypeForFile(path.toLocalFile()).name();		
	}
	
	enum class TABLE : uint
	{
		BOOKMARKS,
		CLOUDS
	};
	
	static const QMap<FMH::TABLE, QString> TABLEMAP =
	{
		{TABLE::BOOKMARKS, "bookmarks"},
		{TABLE::CLOUDS, "clouds"}
	};
	
	typedef QMap<KEYS::KEY, QString> DB;
	
	const QString FMPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/maui/fm/";
	const QString DBName = "fm.db";
	
	inline FMH::MODEL getDirInfoModel(const QUrl &path, const QString &type = QString())
	{		
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return FMH::MODEL();	  
		}		
		
		const QDir dir (path.toLocalFile());		
		if(!dir.exists()) 
			return FMH::MODEL();
		
		return FMH::MODEL
		{
			{KEYS::ICON, FMH::getIconName(path)},
			{KEYS::LABEL, dir.dirName()},
			{KEYS::PATH, path.toString()},
			{KEYS::TYPE, type}
		};
	}	
	
	inline QVariantMap getDirInfo(const QUrl &path, const QString &type = QString())
	{
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return QVariantMap();	  
		}		
		
		const QFileInfo file(path.toLocalFile());	
		
		if(!file.exists()) 
			return QVariantMap();
		
		const auto data = FMH::getDirInfoModel(path);
		
		QVariantMap res; 
		for(const auto &key : data.keys())		
			res.insert(KEYS::_N[key], data[key]);
		
		return res;
	}
	
	
	inline FMH::MODEL getFileInfoModel(const QUrl &path)
	{		
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return FMH::MODEL();  
		}		
		
		const QFileInfo file(path.toLocalFile());
		if(!file.exists()) 
			return FMH::MODEL();
		qDebug()<< "trying to get path info model. exists";
		
		const auto mime = FMH::getMime(path);
		return FMH::MODEL 
		{
			{KEYS::GROUP, file.group()},
			{KEYS::OWNER, file.owner()},
			{KEYS::SUFFIX, file.completeSuffix()},
			{KEYS::LABEL, /*file.isDir() ? file.baseName() :*/ path == FMH::HomePath ? QStringLiteral("Home") : file.fileName()},
			{KEYS::NAME, file.fileName()},
			{KEYS::DATE,  file.birthTime().toString(Qt::TextDate)},
			{KEYS::MODIFIED, file.lastModified().toString(Qt::TextDate)},
			{KEYS::MIME, mime },
			{KEYS::ICON, FMH::getIconName(path)},
			{KEYS::SIZE, QString::number(file.size()) /*locale.formattedDataSize(file.size())*/},
			{KEYS::PATH, path.toString()},
			{KEYS::THUMBNAIL, path.toLocalFile()},
			{KEYS::COUNT, file.isDir() ? QString::number(QDir(path.toLocalFile()).count() - 2) : "0"}
		};		
	}	
	
	inline QVariantMap getFileInfo(const QUrl &path)
	{		
		if(!path.isLocalFile())
		{
			qWarning() << "URL recived is not a local file" << path;
			return QVariantMap();	  
		}	
		const QFileInfo file(path.toLocalFile());	
		
		if(!file.exists()) 
			return QVariantMap();
		
		const auto data = FMH::getFileInfoModel(path);
		
		qDebug()<< "getting item info model" << data;
		
		QVariantMap res; 
		for(const auto &key : data.keys())		
			res.insert(KEYS::_N[key], data[key]);
		
		return res;
	}
	
	#ifndef STATIC_MAUIKIT
	#include "mauikit_export.h"
	#endif
	
	#ifdef STATIC_MAUIKIT
	class Downloader : public QObject
	#else
	class MAUIKIT_EXPORT Downloader : public QObject
	#endif	
	{
		Q_OBJECT
	public:
		explicit Downloader(QObject *parent = 0) : QObject(parent), manager(new QNetworkAccessManager)
		{}
		
		virtual ~Downloader()
		{
			qDebug()<< "DELETEING DOWNLOADER";
			this->manager->deleteLater();
// 			this->reply->deleteLater();
			
		}
		
		void setFile(const QString &fileURL, const QString &fileName = QString())
		{
			QString filePath = fileURL;
			
			if(fileName.isEmpty() || fileURL.isEmpty())			
				return;
			
			QNetworkRequest request;
			request.setUrl(QUrl(fileURL));
			reply = manager->get(request);
			
			file = new QFile;
			file->setFileName(fileName);
			file->open(QIODevice::WriteOnly);
			
			connect(reply, SIGNAL(downloadProgress(qint64,qint64)),this,SLOT(onDownloadProgress(qint64,qint64)));
			connect(manager, SIGNAL(finished(QNetworkReply*)),this,SLOT(onFinished(QNetworkReply*)));
			connect(reply, SIGNAL(readyRead()),this,SLOT(onReadyRead()));
			connect(reply, SIGNAL(finished()),this,SLOT(onReplyFinished()));
		}
		
		void getArray(const QString &fileURL, const QMap<QString, QString> &headers = {})
		{		
			qDebug() << fileURL << headers;
			if(fileURL.isEmpty())			
				return;
						
			QNetworkRequest request;
			request.setUrl(QUrl(fileURL));
			if(!headers.isEmpty())
			{	
				for(auto key: headers.keys())
					request.setRawHeader(key.toLocal8Bit(), headers[key].toLocal8Bit());				
			}
				
			reply = manager->get(request);			
			
			connect(reply, &QNetworkReply::readyRead, [this]()
			{
				switch(reply->error())
				{
					case QNetworkReply::NoError:
					{					
                        this->array = reply->readAll();
						break;
					}
					
					default:
					{
						qDebug() << reply->errorString();						
						emit this->warning(reply->errorString());						
					};
				}
			});
			
			connect(reply, &QNetworkReply::finished, [=]()
			{                
                qDebug() << "Array reply is now finished";
                emit this->dataReady(this->array);
				emit this->done();
			});
		}
		
	private:
		QNetworkAccessManager *manager;
		QNetworkReply *reply;
		QFile *file;
        QByteArray array;
		
	signals:
		void progress(int percent);
		void downloadReady();
		void fileSaved(QString path);
		void warning(QString warning);
		void dataReady(QByteArray array);
		void done();
		
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
					break;
				}
				
				default:
				{
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
			
			emit done();
		}
	};
	
}

#endif // FMH_H
