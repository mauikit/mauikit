#ifndef SYNCING_H
#define SYNCING_H

#include <QObject>
#include <QNetworkReply>
#include "fmh.h"

class WebDAVClient;
class WebDAVReply;
class Syncing : public QObject
{
    Q_OBJECT
	
public:	
	enum SIGNAL_TYPE : uint_fast8_t
	{
		OPEN,
		DOWNLOAD,
		COPY,
		SAVE,
		CUT,
		DELETE,
		RENAME,
		MOVE,
		UPLOAD
	};
    explicit Syncing(QObject *parent = nullptr);
    void listContent(const QString &path);
    void setCredentials(const QString &server, const QString &user, const QString &password);
	void download(const QString &path);
	void upload(const QString &path, const QString &filePath);
	void createDir(const QString &path, const QString &name);
	void resolveFile(const FMH::MODEL &item, const Syncing::SIGNAL_TYPE &signalType);
	void setCopyTo(const QString &path);
	QString getCopyTo() const;	
	
	QString getUser() const;

protected:
	void emitSignal(const FMH::MODEL &item);

private:
    WebDAVClient *client;
    QString host = "https://cloud.opendesktop.cc/remote.php/webdav/";
    QString user = "mauitest";
    QString password = "mauitest";
    void listDirOutputHandler(WebDAVReply *reply);
	
	void saveTo(const QByteArray &array, const QString& path);
	QString getCacheFile(const QString &path);

	QString currentPath;
	QString copyTo;
	
	void emitError(const QNetworkReply::NetworkError &err);
	
	SIGNAL_TYPE signalType;
	
	QFile mFile;
	
signals:
    void listReady(FMH::MODEL_LIST data, QString url);

	void readyOpen(FMH::MODEL item, QString url);
	void readyDownload(FMH::MODEL item, QString url);
	void readyCopy(FMH::MODEL item, QString url);
	void dirCreated(FMH::MODEL item, QString url);
	void uploadReady(FMH::MODEL item, QString url);
	void error(QString message);
	void progress(int percent);
	
public slots:
};

#endif // SYNCING_H
