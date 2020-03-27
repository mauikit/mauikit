#ifndef FMSTATIC_H
#define FMSTATIC_H

#include <QObject>
#include "fmh.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#ifdef STATIC_MAUIKIT
class FMStatic : public QObject
#else
class MAUIKIT_EXPORT FMStatic : public QObject
#endif
{
    Q_OBJECT
public:
    explicit FMStatic(QObject *parent = nullptr);
    
public slots:
    static FMH::MODEL_LIST search(const QString &query, const QUrl &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList());
    
    static FMH::MODEL_LIST getDevices();
    static FMH::MODEL_LIST getDefaultPaths();
    
    static FMH::MODEL_LIST packItems(const QStringList &items, const QString &type);
    
	static bool copy(const QList<QUrl> &urls, const QUrl &destinationDir, const bool &overWriteDirectory = false);
	static bool cut(const QList<QUrl> &urls, const QUrl &where);
	static bool cut(const QList<QUrl> &urls, const QUrl &where, const QString &name);
	static bool removeFiles(const QList<QUrl> &urls);
	
    static bool removeDir(const QUrl &path);
    
    static QString formatSize(const int &size);
    static QString formatTime(const qint64 &value);
    static QString formatDate(const QString &dateStr, const QString &format = QString("dd/MM/yyyy"), const QString &initFormat = QString());
    static QString homePath();
    static QUrl parentDir(const QUrl &path);
    
    static QVariantMap getDirInfo(const QUrl &path, const QString &type);
    static QVariantMap getFileInfo(const QUrl &path);
    
    static bool isDefaultPath(const QString &path);
    static bool isDir(const QUrl &path);
    static bool isApp(const QString &path);
    static bool isCloud(const QUrl &path);
    static bool fileExists(const QUrl &path);
    
    /**
     * if the url is a file path then it returns its directory
     * and if it is a directory returns the same path
     * */
    static QString fileDir(const QUrl &path);
    
    /* SETTINGS */
    static void saveSettings(const QString &key, const QVariant &value, const QString &group);
    static QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue);
    
    static const QVariantMap dirConf(const QUrl &path);
    static void setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value);
    static bool checkFileType(const int &type, const QString &mimeTypeName);
    static void moveToTrash(const QList<QUrl> &urls);
    static void emptyTrash();
    static bool rename(const QUrl &url, const QString &name);
    static bool createDir(const QUrl &path, const QString &name);
    static bool createFile(const QUrl &path, const QString &name);
    static bool createSymlink(const QUrl &path, const QUrl &where);
    
    static bool openUrl(const QUrl &url);
    static void openLocation(const QStringList &urls);
    
	static bool isFav(const QUrl &url, const bool &strict = false);
	static bool unFav(const QUrl &url);
	static bool fav(const QUrl &url);
	static bool toggleFav(const QUrl &url);
	static QList<QUrl> getTagUrls(const QString &tag, const QStringList &filters, const bool &strict = false);
	static void bookmark(const QUrl &url);
};

#endif // FMSTATIC_H
