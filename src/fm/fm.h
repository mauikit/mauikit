#ifndef FM_H
#define FM_H

#include <QObject>
#include <QVariantList>
#include <QStringList>
#include <QStorageInfo>
#include <QVector>
#include <QHash>

#include "fmh.h"
#include "fmstatic.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#endif

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
class KCoreDirLister;
#endif

class Syncing;
class Tagging;
#ifdef STATIC_MAUIKIT
class FM : public QObject
#else
class MAUIKIT_EXPORT FM : public QObject
#endif
{
    Q_OBJECT

public:  
	Syncing *sync;
	
	FM(QObject *parent = nullptr);
	~FM();
	
	FMH::MODEL_LIST getTags(const int &limit = 5);	
	FMH::MODEL_LIST getTagContent(const QString &tag);
	FMH::MODEL_LIST getUrlTags(const QUrl &url);
	bool urlTagExists(const QUrl& url, const QString tag);
	bool addTagToUrl(const QString tag, const QUrl &url);
	bool removeTagToUrl(const QString tag, const QUrl &url);
	
    /** Syncing **/
    bool getCloudServerContent(const QUrl &server, const QStringList &filters= QStringList(), const int &depth = 0);
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

signals:
    void cloudServerContentReady(FMH::MODEL_LIST list, const QUrl &url);
    void cloudItemReady(FMH::MODEL item, QUrl path); //when a item is downloaded and ready
	void pathContentReady(FMH::PATH_CONTENT list);
	void pathContentChanged(QUrl path);
	
	void warningMessage(QString message);
	void loadProgress(int percent);
	
	void dirCreated(FMH::MODEL dir);
    void newItem(FMH::MODEL item, QUrl path); // when a new item is created
	
public slots:	
	void openCloudItem(const QVariantMap &item);	
	void getCloudItem(const QVariantMap &item);	
	
	/* ACTIONS */	
	bool copy(const QList<QUrl> &urls, const QUrl &where);
	bool cut(const QList<QUrl> &urls, const QUrl &where);	

    friend class FMStatic;
};

#endif // FM_H
