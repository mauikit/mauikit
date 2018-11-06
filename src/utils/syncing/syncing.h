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

private:
    WebDAVClient *client;
    QString host = "https://cloud.opendesktop.cc/remote.php/webdav/";
    QString user = "mauitest";
    QString password = "mauitest";
    void listDirOutputHandler(WebDAVReply *reply);

signals:
    void listReady(FMH::MODEL_LIST data);

public slots:
};

#endif // SYNCING_H
