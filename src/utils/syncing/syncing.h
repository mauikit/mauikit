#ifndef SYNCING_H
#define SYNCING_H

#include <QObject>
#ifdef Q_OS_ANDROID
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

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
