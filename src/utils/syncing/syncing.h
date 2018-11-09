#ifndef SYNCING_H
#define SYNCING_H

#include <QObject>
#include "fmh.h"

class WebDAVClient;
class WebDAVReply;
class Syncing : public QObject
{
    Q_OBJECT
public:
    explicit Syncing(QObject *parent = nullptr);
    void listContent(const QString &path);
    void setCredentials(const QString &server, const QString &user, const QString &password);
	void download(const QString &path);
	void upload(const QString &path);
	void resolveFile(const FMH::MODEL &item);
	
protected:

private:
    WebDAVClient *client;
    QString host = "https://cloud.opendesktop.cc/remote.php/webdav/";
    QString user = "mauitest";
    QString password = "mauitest";
    void listDirOutputHandler(WebDAVReply *reply);
	
	void saveTo(const QByteArray &array, const QString& path);
	QString getCacheFile(const QString &path);

	QString currentPath;
	
signals:
    void listReady(FMH::MODEL_LIST data);
	void itemDownloaded(FMH::MODEL item);
	void itemReady(FMH::MODEL item);
	
public slots:
};

#endif // SYNCING_H
