#include "syncing.h"
#include "fm.h"

#include <QFile>

#include "WebDAVClient.hpp"
#include "WebDAVItem.hpp"
#include "WebDAVReply.hpp"

Syncing::Syncing(QObject *parent) : QObject(parent)
{
	this->setCredentials(this->host, this->user, this->password);
}

void Syncing::listContent(const QString &path)
{
	this->currentPath = path;
	
	auto url = QString(path).replace("Cloud/"+user, "");
	this->listDirOutputHandler(this->client->listDir(url, ListDepthEnum::One));
}

void Syncing::setCredentials(const QString &server, const QString &user, const QString &password)
{
	this->host = server;
	this->user = user;
	this->password = password;
	
	this->client = new WebDAVClient(this->host, this->user, this->password);
}

void Syncing::listDirOutputHandler(WebDAVReply *reply)
{
	connect(reply, &WebDAVReply::listDirResponse,
			[=](QNetworkReply *listDirReply, QList<WebDAVItem> items) 
			{
				qDebug() << "URL :" << listDirReply->url();
				qDebug() << "Received List of" << items.length() << "items";
				qDebug() << endl << "---------------------------------------";
				FMH::MODEL_LIST list;
				for (WebDAVItem item : items)
				{
					
					auto url = QUrl(item.getHref()).toString();
					auto displayName = QString(url).replace("/remote.php/webdav/", "").replace("/", "");
					auto path =  QString("Cloud/"+this->user+"/")+QString(url).replace("/remote.php/webdav/", "");
					
					qDebug()<< "PATHS:" << path << this->currentPath;
					
					if(QString(url).replace("/remote.php/webdav/", "").isEmpty() || path == this->currentPath)
						continue;
					
					list << FMH::MODEL {
						{FMH::MODEL_KEY::LABEL, displayName},
		 {FMH::MODEL_KEY::NAME, item.getDisplayName()},
			{FMH::MODEL_KEY::DATE, item.getCreationDate().toString(Qt::TextDate)},
			{FMH::MODEL_KEY::MODIFIED, item.getLastModified()},
			{FMH::MODEL_KEY::MIME, item.getContentType().isEmpty() ? "inode/directory" : item.getContentType()},
			{FMH::MODEL_KEY::ICON, FMH::getIconName(url)},
			{FMH::MODEL_KEY::SIZE, QString::number(item.getContentLength())},
			{FMH::MODEL_KEY::PATH, path},
		 {FMH::MODEL_KEY::URL, url},
		 {FMH::MODEL_KEY::THUMBNAIL, item.getContentType().isEmpty() ? url : this->getCacheFile(url)}
					};
				}
				emit this->listReady(list);
				
			});
	connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
		qDebug() << err;
	});
}

QString Syncing::getCacheFile(const QString& path)
{	
	const auto directory = FMH::CloudCachePath+"opendesktop/"+this->user;
	const auto file = directory + QString(path).replace("remote.php/webdav/", "");	
	
	qDebug()<< "resolving file"<< file;
	
	if(FMH::fileExists(file))
		return file;
	else return path;
}


void Syncing::download(const QString& path)
{
	QString url = QString(path).replace("remote.php/webdav/", "");
	
	WebDAVReply *reply = this->client->downloadFrom(url);
	qDebug()<< "CURRENT CREDENTIALS"<< this->host << this->user;
	connect(reply, &WebDAVReply::downloadResponse, [=](QNetworkReply *reply) 
	{
		if (!reply->error())
		{
			qDebug() << "\nDownload Success"
			<< "\nURL  :" << reply->url() << "\nSize :" << reply->size();
			auto file = reply->readAll();
			auto directory = FMH::CloudCachePath+"opendesktop/"+this->user;
			
			QDir dir(directory);
			
			if (!dir.exists())
				dir.mkpath(".");
			
			this->saveTo(file, directory+url);
		} else 
		{
			qDebug() << "ERROR(DOWNLOAD)" << reply->error() << reply->url() <<url;
		}
	});
	
	connect(reply, &WebDAVReply::downloadProgressResponse, [=](qint64 bytesReceived, qint64 bytesTotal)
	{
		int percent = ((float)bytesReceived / bytesTotal) * 100;
		
		qDebug() << "\nReceived : " << bytesReceived
		<< "\nTotal    : " << bytesTotal
		<< "\nPercent  : " << percent;
	});
	
	connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
		qDebug() << "ERROR" << err;
	});
}

void Syncing::upload(const QString& path)
{
}

void Syncing::saveTo(const QByteArray &array, const QString& path)
{
	QFile file(path);
	
	if(!file.exists())
	{
		QDir dir;
		uint cut = path.length()- path.lastIndexOf("/") -1;
		auto newPath = QString(path).right(cut);
		dir.mkdir(QString(path).replace(newPath, ""));
		qDebug()<< newPath << cut;
	}
	
	file.open(QIODevice::WriteOnly);
	file.write(array);
	file.close();
	
	emit this->itemDownloaded(FMH::getFileInfoModel(path));
	emit this->itemReady(FMH::getFileInfoModel(path));
}

void Syncing::resolveFile(const FMH::MODEL& item)
{
	const auto file = this->getCacheFile(item[FMH::MODEL_KEY::URL]);	
	
	if(FMH::fileExists(file))
	{			
		const auto cacheFile = FMH::getFileInfoModel(file);
		
		const auto dateCacheFile = QDateTime::fromString(cacheFile[FMH::MODEL_KEY::DATE], Qt::TextDate);		
		const auto dateCloudFile = QDateTime::fromString(QString(item[FMH::MODEL_KEY::MODIFIED]).replace("GMT", "").simplified(), "ddd, dd MMM yyyy hh:mm:ss");
		
		qDebug()<< dateCacheFile << dateCloudFile<< QString(item[FMH::MODEL_KEY::MODIFIED]).replace("GMT", "").simplified();
		
		if(dateCloudFile >  dateCacheFile)
			this->download(file);
		
		emit this->itemReady(cacheFile);		
	}
	else
		this->download(file);
}

