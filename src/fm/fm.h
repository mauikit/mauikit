#ifndef FM_H
#define FM_H

#include <QObject>
#include <QVariantList>
#include <QStringList>
#include <QStorageInfo>
#include "fmdb.h"
#include "fmh.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#endif

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
	static FM *getInstance();
	
	FMH::MODEL_LIST  getTags(const int &limit = 5);	
	FMH::MODEL_LIST getTagContent(const QString &tag);	
    FMH::MODEL_LIST  getBookmarks();

    /** Syncing **/
    void getCloudServerContent(const QString &server);
    FMH::MODEL_LIST getCloudAccounts();

	/*** START STATIC METHODS ***/
	static FMH::MODEL_LIST search(const QString &query, const QString &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList());
	
	static FMH::MODEL_LIST getDevices();	
	static FMH::MODEL_LIST getDefaultPaths();
	static FMH::MODEL_LIST getCustomPaths();	
	
	static FMH::MODEL_LIST packItems(const QStringList &items, const QString &type);
	
	FMH::MODEL_LIST static getPathContent(const QString &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList(), const QDirIterator::IteratorFlags &iteratorFlags = QDirIterator::NoIteratorFlags);
	
	FMH::MODEL_LIST static getAppsContent(const QString &path);	

	static bool copyPath(QString sourceDir, QString destinationDir, bool overWriteDirectory);
	static bool removeDir(const QString &path);	
	/*** END STATIC METHODS ***/
	
private:
    Tagging *tag;
    Syncing *sync;
	static FM* instance;
	
    void init();
	QVariantList get(const QString &queryTxt);
	
	FM(QObject *parent = nullptr);
	~FM();

signals:
	void bookmarkInserted(QString bookmark);
	void bookmarkRemoved(QString bookmark);

    void cloudAccountInserted(QString user);
    void cloudAccountRemoved(QString user);

    void cloudServerContentReady(FMH::MODEL_LIST list);
	void cloudItemReady(FMH::MODEL item);
	
public slots:	
	bool bookmark(const QString &path);
	bool removeBookmark(const QString &path);
	bool isBookmark(const QString &path);

    void addCloudAccount(const QString &server, const QString &user, const QString &password);
	void openCloudItem(const QVariantMap &item);	
	
	static QString formatSize(const int &size);
	static QString formatDate(const QString &dateStr, const QString &format = "dd/MM/yyyy");
	static QString homePath();	
	static QString parentDir(const QString &path);
	
	static QVariantMap getDirInfo(const QString &path, const QString &type);
	static QVariantMap getFileInfo(const QString &path);
	
	static bool isDefaultPath(const QString &path);
	static bool isDir(const QString &path);
	static bool isApp(const QString &path);	
	static bool fileExists(const QString &path);
	
	/* SETTINGS */
	static void saveSettings(const QString &key, const QVariant &value, const QString &group);
	static QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue);
	
	static QVariantMap dirConf(const QString &path);
	static void setDirConf(const QString &path, const QString &group, const QString &key, const QVariant &value);
	
	/* ACTIONS */	
	static bool copy(const QStringList &paths, const QString &where);
	static bool cut(const QStringList &paths, const QString &where);
	static bool removeFile(const QString &path);
	static bool rename(const QString &path, const QString &name);
	static bool createDir(const QString &path, const QString &name);
	static bool createFile(const QString &path, const QString &name);
	
	static bool openUrl(const QString &url);
	static void runApplication(const QString &exec);	
};

#endif // FM_H
