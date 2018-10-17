#ifndef FM_H
#define FM_H

#include <QObject>
#include <QVariantList>
#include <QStringList>
#include <QFileSystemWatcher>
#include <QStorageInfo>
#include "fmdb.h"
#include "fmh.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#endif

class Tagging;

#ifdef STATIC_MAUIKIT
class FM : public FMDB
#else
class MAUIKIT_EXPORT FM : public FMDB
#endif
{
    Q_OBJECT

public:

    FM(QObject *parent = nullptr);
    ~FM();

    static QVariantList packItems(const QStringList &items, const QString &type);

    QVariantList get(const QString &queryTxt);
    void watchPath(const QString &path, const bool &clear = true);	
	FMH::MODEL_LIST getPathContent(const QString &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList()) const;
	
// 	Q_INVOKABLE QVariantList getPathContent(const QString &path, const bool &onlyDirs = false, const QStringList &filters = QStringList());
	
	Q_INVOKABLE QVariantList getTags(const int &limit = 5);
    Q_INVOKABLE QVariantList getBookmarks();
    Q_INVOKABLE QVariantList getTagContent(const QString &tag);
    Q_INVOKABLE bool bookmark(const QString &path);
	
	/* STATIC METHODS*/
    Q_INVOKABLE static QVariantList getDefaultPaths();
	Q_INVOKABLE static QString homePath();	
	Q_INVOKABLE static QString parentDir(const QString &path);
	
    Q_INVOKABLE static QVariantList getDevices();
	Q_INVOKABLE static QVariantMap getDirInfo(const QString &path, const QString &type);
	Q_INVOKABLE static QVariantMap getFileInfo(const QString &path);
	
    Q_INVOKABLE static bool isDefaultPath(const QString &path);
    Q_INVOKABLE static bool isDir(const QString &path);
	Q_INVOKABLE static bool fileExists(const QString &path);
	
	/* SETTINGS */
    Q_INVOKABLE static void saveSettings(const QString &key, const QVariant &value, const QString &group);
    Q_INVOKABLE static QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue);
	
    Q_INVOKABLE static QVariantMap dirConf(const QString &path);
    Q_INVOKABLE static void setDirConf(const QString &path, const QString &group, const QString &key, const QVariant &value);
	
	/* ACTIONS */

    Q_INVOKABLE static bool copy(const QStringList &paths, const QString &where);
    static bool copyPath(QString sourceDir, QString destinationDir, bool overWriteDirectory);
    Q_INVOKABLE static bool cut(const QStringList &paths, const QString &where);
    Q_INVOKABLE static bool remove(const QString &path);
    static bool removeDir(const QString &path);
    Q_INVOKABLE static bool rename(const QString &path, const QString &name);
    Q_INVOKABLE static bool createDir(const QString &path, const QString &name);
    Q_INVOKABLE static bool createFile(const QString &path, const QString &name);
    
    Q_INVOKABLE static bool openUrl(const QString &url);  

private:
    QFileSystemWatcher *watcher;
    Tagging *tag;

signals:
    void pathModified(QString path);

public slots:
};

#endif // FM_H
