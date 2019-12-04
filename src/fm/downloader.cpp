#include "downloader.h"

// #if defined Q_OS_LINUX && !defined Q_OS_ANDROID
// #include <KIO/CopyJob>
// #include <KJob>
// #endif

FMH::Downloader::Downloader(QObject *parent) : QObject(parent), manager(new QNetworkAccessManager), array(new QByteArray)
{}

 FMH::Downloader::~Downloader()
{
    qDebug()<< "DELETEING DOWNLOADER";
    this->manager->deleteLater();
    this->reply->deleteLater();
    this->reply = nullptr;
    this->array->clear();
 }

void FMH::Downloader::downloadFile(const QUrl &source, const QUrl &destination) {
    
#ifdef KIO_COPYJOB_H
	KIO::CopyJob *downloadJob = KIO::copy(source, destination);

	QObject::connect(downloadJob, &KIO::CopyJob::warning, [=](KJob *job, QString message){
		Q_UNUSED(job)
		emit this->warning(message);
	});
	
    QObject::connect(downloadJob, &KIO::CopyJob::processedSize, [=](KJob *job, qulonglong size){
        emit this->progress(size, job->percent());
    });
	
    QObject::connect(downloadJob, &KIO::CopyJob::finished, [=](KJob *job){
		emit this->downloadReady();
		emit this->done();
		job->deleteLater();
    });
#else
	if(destination.isEmpty() || source.isEmpty())
		return;
	
	QNetworkRequest request;
	request.setUrl(source);
	reply = manager->get(request);
	
	file = new QFile;
	file->setFileName(destination.toLocalFile());
	if(!file->open(QIODevice::WriteOnly))
		emit this->warning("Can not open file to write download");
	
	connect(reply, SIGNAL(downloadProgress(qint64,qint64)),this,SLOT(onDownloadProgress(qint64,qint64)));
	connect(manager, SIGNAL(finished(QNetworkReply*)),this,SLOT(onFinished(QNetworkReply*)));
	connect(reply, SIGNAL(readyRead()),this,SLOT(onReadyRead()));
	connect(reply, SIGNAL(finished()),this,SLOT(onReplyFinished()));
#endif
}

void FMH::Downloader::getArray(const QUrl &fileURL, const QMap<QString, QString> &headers)
{
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
			emit this->fileSaved(file->fileName());
			qDebug() << "file is downloaded successfully." << file->fileName();
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
        file->deleteLater();
    }
}

void FMH::Downloader::onReadyRead()
{
    file->write(reply->readAll());
}

void FMH::Downloader::onReplyFinished()
{
    if(file->isOpen())
    {
        file->close();		
        file->deleteLater();
    }
    
    emit done();
}
