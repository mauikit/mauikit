#include "syncing.h"
#include "fm.h"

#include "WebDAVClient.hpp"
#include "WebDAVItem.hpp"
#include "WebDAVReply.hpp"

Syncing::Syncing(QObject *parent) : QObject(parent)
{
	this->setCredentials(this->host, this->user, this->password);
}

void Syncing::listContent(const QString &path)
{
	qDebug()<< "askign for content:"<< path;
	this->listDirOutputHandler(this->client->listDir(path, ListDepthEnum::One));
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
			[=](QNetworkReply *listDirReply, QList<WebDAVItem> items) {
				qDebug() << "URL :" << listDirReply->url();
				qDebug() << "Received List of" << items.length() << "items";
				qDebug() << endl << "---------------------------------------";
				FMH::MODEL_LIST list;
				for (WebDAVItem item : items)
				{
					qDebug()<< item.getHref();
					
					if( QString(item.getHref()).replace("/remote.php/webdav/", "").isEmpty())
						continue;
					
					list << FMH::MODEL {
						{FMH::MODEL_KEY::LABEL, QString(item.getHref()).replace("/remote.php/webdav/", "")},
			{FMH::MODEL_KEY::NAME, item.getDisplayName()},
			{FMH::MODEL_KEY::DATE, item.getCreationDate().toString(Qt::TextDate)},
			{FMH::MODEL_KEY::MODIFIED, item.getLastModified()},
			{FMH::MODEL_KEY::MIME, item.getContentType().isEmpty() ? "inode/directory" : item.getContentType()},
			{FMH::MODEL_KEY::ICON, FMH::getIconName(item.getHref())},
			{FMH::MODEL_KEY::SIZE, QString::number(item.getContentLength())},
			{FMH::MODEL_KEY::PATH, QString("Cloud/"+this->user+"/")+QString(item.getHref()).replace("/remote.php/webdav/", "")}
					};
				}
				emit this->listReady(list);
				
			});
	connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
		qDebug() << err;
	});
}
