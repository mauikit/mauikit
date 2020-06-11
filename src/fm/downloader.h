#ifndef DOWNLOADER_H
#define DOWNLOADER_H

#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QString>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

namespace FMH
{
#ifdef STATIC_MAUIKIT
class Downloader : public QObject
#else
class MAUIKIT_EXPORT Downloader : public QObject
#endif
{
    Q_OBJECT
public:
    Downloader(QObject *parent = nullptr);

    virtual ~Downloader();

    void downloadFile(const QUrl &source, const QUrl &destination);
    void getArray(const QUrl &fileURL, const QMap<QString, QString> &headers = {});

private:
    QNetworkAccessManager *manager;
    QNetworkReply *reply;
    QFile *file;
    QByteArray *array;

signals:
    void progress(int percent);
    void downloadReady();
    void fileSaved(QString path);
    void warning(QString warning);
    void dataReady(QByteArray array);
    void done();

private slots:
    void onDownloadProgress(qint64 bytesRead, qint64 bytesTotal);

    void onFinished(QNetworkReply *reply);

    void onReadyRead();

    void onReplyFinished();
};

}

#endif // DOWNLOADER_H
