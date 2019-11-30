#include <KIO/CopyJob>
#include <KJob>

#include "downloader.h"

FMH::Downloader::Downloader(QObject *parent) : QObject(parent), manager(new QNetworkAccessManager), array(new QByteArray)
{}

 FMH::Downloader::~Downloader()
{
    qDebug()<< "DELETEING DOWNLOADER";
    this->manager->deleteLater();
    // 			this->reply->deleteLater();
    this->reply->deleteLater();
    this->reply = nullptr;
    this->array->clear();
 }

void FMH::Downloader::downloadFile(const QUrl &source, const QUrl &destination) {
    KIO::CopyJob *downloadJob = KIO::copy(source, destination);

    QObject::connect(downloadJob, &KIO::CopyJob::processedSize, [=](KJob *job, qulonglong size){
        emit progress(size, job->percent());
    });

    QObject::connect(downloadJob, &KIO::CopyJob::finished, [=](KJob *job){
        Q_UNUSED(job)

        emit done();
    });
}

void FMH::Downloader::setFile(const QUrl &fileURL, const QUrl &fileName)
{
    if(fileName.isEmpty() || fileURL.isEmpty())
        return;

    QNetworkRequest request;
    request.setUrl(fileURL);
    reply = manager->get(request);

    file = new QFile;
    file->setFileName(fileName.toLocalFile());
    if(!file->open(QIODevice::WriteOnly))
        qWarning()<< "can not open file to write download";

    qDebug() << QSslSocket::sslLibraryBuildVersionString();
    qDebug() << QSslSocket::supportsSsl();
    qDebug() << QSslSocket::sslLibraryVersionString();

    connect(reply, SIGNAL(downloadProgress(qint64,qint64)),this,SLOT(onDownloadProgress(qint64,qint64)));
    connect(manager, SIGNAL(finished(QNetworkReply*)),this,SLOT(onFinished(QNetworkReply*)));
    connect(reply, SIGNAL(readyRead()),this,SLOT(onReadyRead()));
    connect(reply, SIGNAL(finished()),this,SLOT(onReplyFinished()));
}

void FMH::Downloader::getArray(const QUrl &fileURL, const QMap<QString, QString> &headers)
{
    qDebug() << fileURL << headers;
    if(fileURL.isEmpty())
        return;

    QNetworkRequest request;
    request.setUrl(fileURL);
    if(!headers.isEmpty())
    {
        for(const auto &key: headers.keys())
            request.setRawHeader(key.toLocal8Bit(), headers[key].toLocal8Bit());
    }

    reply = manager->get(request);

    connect(reply, &QIODevice::readyRead, [this]()
    {
        switch(reply->error())
        {
        case QNetworkReply::NoError:
        {
            this->array->append(reply->readAll());
            break;
        }

        default:
        {
            qDebug() << reply->errorString();
            emit this->warning(reply->errorString());
        }
        }
    });

    connect(reply, &QNetworkReply::finished, [this]()
    {
        qDebug() << "Array reply is now finished";

        emit this->dataReady(*this->array);
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
    }
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
    qDebug()<< "WRITTING TO FILE >>>>>";
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
