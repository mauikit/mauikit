#include "downloader.h"

FMH::Downloader::Downloader(QObject *parent) : QObject(parent), manager(new QNetworkAccessManager)
{}

FMH::Downloader::~Downloader()
{
    qDebug()<< "DELETEING DOWNLOADER";
    this->manager->deleteLater();
    // 			this->reply->deleteLater();

}

void FMH::Downloader::setFile(const QString &fileURL, const QString &fileName)
{
    QString filePath = fileURL;

    if(fileName.isEmpty() || fileURL.isEmpty())
        return;

    QNetworkRequest request;
    request.setUrl(QUrl(fileURL));
    reply = manager->get(request);

    file = new QFile;
    file->setFileName(fileName);
    file->open(QIODevice::WriteOnly);

    connect(reply, SIGNAL(downloadProgress(qint64,qint64)),this,SLOT(onDownloadProgress(qint64,qint64)));
    connect(manager, SIGNAL(finished(QNetworkReply*)),this,SLOT(onFinished(QNetworkReply*)));
    connect(reply, SIGNAL(readyRead()),this,SLOT(onReadyRead()));
    connect(reply, SIGNAL(finished()),this,SLOT(onReplyFinished()));
}

void FMH::Downloader::getArray(const QString &fileURL, const QMap<QString, QString> &headers)
{
    qDebug() << fileURL << headers;
    if(fileURL.isEmpty())
        return;

    QNetworkRequest request;
    request.setUrl(QUrl(fileURL));
    if(!headers.isEmpty())
    {
        for(auto key: headers.keys())
            request.setRawHeader(key.toLocal8Bit(), headers[key].toLocal8Bit());
    }

    reply = manager->get(request);

    connect(reply, &QNetworkReply::readyRead, [this]()
    {
        switch(reply->error())
        {
        case QNetworkReply::NoError:
        {
            this->array = reply->readAll();
            break;
        }

        default:
        {
            qDebug() << reply->errorString();
            emit this->warning(reply->errorString());
        };
        }
    });

    connect(reply, &QNetworkReply::finished, [=]()
    {
        qDebug() << "Array reply is now finished";
        emit this->dataReady(this->array);
        emit this->done();
    });
}

void FMH::Downloader::onDownloadProgress(qint64 bytesRead, qint64 bytesTotal)
{
    emit this->progress((bytesRead * bytesTotal) / 100);
}

void FMH::Downloader::onFinished(QNetworkReply *reply)
{
    switch(reply->error())
    {
    case QNetworkReply::NoError:
    {
        qDebug("file is downloaded successfully.");
        emit this->downloadReady();
        break;
    }

    default:
    {
        emit this->warning(reply->errorString());
    };
    }

    if(file->isOpen())
    {
        file->close();
        emit this->fileSaved(file->fileName());
        file->deleteLater();
    }
}

void FMH::Downloader::onReadyRead()
{
    file->write(reply->readAll());
    // 			emit this->fileSaved(file->fileName());
}

void FMH::Downloader::onReplyFinished()
{
    if(file->isOpen())
    {
        file->close();
        // 				emit this->fileSaved(file->fileName());
        file->deleteLater();
    }

    emit done();
}
