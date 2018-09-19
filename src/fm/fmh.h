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


enum class MODEL_KEY : uint_fast8_t
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
    MODIFIED,
    MIME,
    TAGS,
    PERMISSIONS,
    THUMBNAIL,
    HIDDEN,
    ICONSIZE,
    DETAILVIEW,
    SHOWTHUMBNAIL,
    SHOWTERMINAL
};

static const QMap<MODEL_KEY, QString> MODEL_NAME =
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
    {MODEL_KEY::TAGS, "tags"},
    {MODEL_KEY::PERMISSIONS, "permissions"},
    {MODEL_KEY::THUMBNAIL, "thumbnail"},
    {MODEL_KEY::ICONSIZE, "iconsize"},
    {MODEL_KEY::HIDDEN, "hidden"},
    {MODEL_KEY::DETAILVIEW, "detailview"},
    {MODEL_KEY::SHOWTERMINAL, "showterminal"},
    {MODEL_KEY::SHOWTHUMBNAIL, "showthumbnail"}

};

enum class CUSTOMPATH : uint_fast8_t
{
    APPS,
    TAGS,
    TRASH
};

static const QMap<CUSTOMPATH, QString> CUSTOMPATH_PATH =
{
    {CUSTOMPATH::APPS, "#apps"},
    {CUSTOMPATH::TAGS, "#tags"},
    {CUSTOMPATH::TRASH, "#trash"}
};

static const QMap<CUSTOMPATH, QString> CUSTOMPATH_NAME =
{
    {CUSTOMPATH::APPS, "Apps"},
    {CUSTOMPATH::TAGS, "Tags"},
    {CUSTOMPATH::TRASH, "Trash"}
};

enum class PATHTYPE_KEY : uint_fast8_t
{
    PLACES,
    DRIVES,
    BOOKMARKS,
    TAGS
};

static const QMap<PATHTYPE_KEY, QString> PATHTYPE_NAME =
{
    {PATHTYPE_KEY::PLACES, "Places"},
    {PATHTYPE_KEY::DRIVES, "Drives"},
    {PATHTYPE_KEY::BOOKMARKS, "Bookmarks"},
    {PATHTYPE_KEY::TAGS, "Tags"}
};

const QString DataPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);

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
    file.endGroup();

#else
    KConfig file(path);
    icon =  file.entryMap(QString("Desktop Entry"))["Icon"];
    hidden = file.entryMap(QString("Settings"))["HiddenFilesShown"];
    iconsize = file.entryMap(QString("MAUIFM"))["IconSize"];
    detailview = file.entryMap(QString("MAUIFM"))["DetailView"];
    showthumbnail = file.entryMap(QString("MAUIFM"))["ShowThumbnail"];
    showterminal = file.entryMap(QString("MAUIFM"))["ShowTerminal"];

#endif

    auto res = QVariantMap({
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], icon.isEmpty() ? "folder" : icon},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::ICONSIZE], iconsize},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTERMINAL], showterminal.isEmpty() ? "false" : showterminal},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTHUMBNAIL], showthumbnail.isEmpty() ? "false" : showthumbnail},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::DETAILVIEW], detailview.isEmpty() ? "false" : detailview},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN], hidden.isEmpty() ? false :
                            (hidden == "true" ? true : false)}
                       });

    return res;
}

inline void setDirConf(const QString &path, const QString &group, const QString &key, const QString &value)
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
        return type.genericIconName();
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
    BOOKMARKS
};

static const QMap<FMH::TABLE, QString> TABLEMAP =
{
    {TABLE::BOOKMARKS, "bookmarks"}
};

typedef QMap<FMH::MODEL_KEY, QString> DB;

const QString FMPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/maui/fm/";
const QString DBName = "fm.db";


inline QVariantMap getDirInfo(const QString &path, const QString &type = QString())
{
    QFileInfo file (path);
    QVariantMap data =
    {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], FMH::getIconName(path)},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], file.baseName()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::PATH], path},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::TYPE], type}
    };

    return data;
}

}



#endif // FMH_H
