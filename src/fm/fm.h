#ifndef FM_H
#define FM_H

#include <QObject>
#include <QVariantList>
#include <QStringList>
#include <QStorageInfo>
#include <QVector>
#include <QHash>

#include "fmdb.h"
#include "fmh.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#endif

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
class KCoreDirLister;
#endif


class FM_STATIC : public QObject
{
    Q_OBJECT
public:
    FM_STATIC(QObject *parent = nullptr) : QObject(parent){}

public slots:
    static FMH::MODEL_LIST search(const QString &query, const QUrl &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList());

    static FMH::MODEL_LIST getDevices();
    static FMH::MODEL_LIST getDefaultPaths();

    static FMH::MODEL_LIST packItems(const QStringList &items, const QString &type);

    static bool copyPath(QUrl sourceDir, QUrl destinationDir, bool overWriteDirectory);
    static bool removeDir(const QUrl &path);

    static QString formatSize(const int &size);
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

    static QVariantMap dirConf(const QUrl &path);
    static void setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value);

    static bool removeFile(const QUrl &path);
    static void moveToTrash(const QUrl &path);
    static void emptyTrash();
    static bool rename(const QUrl &path, const QString &name);
    static bool createDir(const QUrl &path, const QString &name);
    static bool createFile(const QUrl &path, const QString &name);
    static bool createSymlink(const QUrl &path, const QUrl &where);

    static bool openUrl(const QUrl &url);
    static void openLocation(const QStringList &urls);
};


class Syncing;
class Tagging;
#ifdef STATIC_MAUIKIT
class FM : public FMDB
#else
class MAUIKIT_EXPORT FM : public FMDB
#endif
{
    Q_OBJECT

public:  
	Syncing *sync;
	
	FM(QObject *parent = nullptr);
	~FM();
	
	FMH::MODEL_LIST getTags(const int &limit = 5);	
	FMH::MODEL_LIST getTagContent(const QString &tag);
	bool addTagToUrl(const QString tag, const QUrl &url);
//     FMH::MODEL_LIST getBookmarks();

    /** Syncing **/
    bool getCloudServerContent(const QUrl &server, const QStringList &filters= QStringList(), const int &depth = 0);
    FMH::MODEL_LIST getCloudAccounts();
	Q_INVOKABLE void createCloudDir(const QString &path, const QString &name);
		
	void getPathContent(const QUrl &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList(), const QDirIterator::IteratorFlags &iteratorFlags = QDirIterator::NoIteratorFlags);
    QString resolveLocalCloudPath(const QString &path);

    static FMH::MODEL_LIST getAppsPath();
    static QString resolveUserCloudCachePath(const QString &server, const QString &user);

private:
    Tagging *tag;
	#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)	
	KCoreDirLister *dirLister;
	#endif
	QVariantList get(const QString &queryTxt);	

signals:
    void cloudAccountInserted(QString user);
    void cloudAccountRemoved(QString user);

    void cloudServerContentReady(FMH::MODEL_LIST list, const QUrl &url);
    void cloudItemReady(FMH::MODEL item, QUrl path); //when a item is downloaded and ready
	void pathContentReady(FMH::PATH_CONTENT list);
	void pathContentChanged(QUrl path);
	
	void warningMessage(QString message);
	void loadProgress(int percent);
	
	void dirCreated(FMH::MODEL dir);
    void newItem(FMH::MODEL item, QUrl path); // when a new item is created
	
public slots:	
	QVariantList getCloudAccountsList();	
    bool removeCloudAccount(const QString &server, const QString &user);
	void openCloudItem(const QVariantMap &item);	
	void getCloudItem(const QVariantMap &item);	
	
	/* ACTIONS */	
	bool copy(const QVariantList &data, const QUrl &where);
	bool cut(const QVariantList &data, const QUrl &where);	

    friend class FM_STATIC;
};

#endif // FM_H
