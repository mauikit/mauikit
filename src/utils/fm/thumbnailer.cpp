#include "thumbnailer.h"
#include <KIO/PreviewJob>
//#include <KIO/KFileItem>
#include <QDebug>
#include <QImage>

QQuickImageResponse * Thumbnailer::requestImageResponse(const QString & id, const QSize & requestedSize)
{
	AsyncImageResponse *response = new AsyncImageResponse(id, requestedSize);
	return response;
}

AsyncImageResponse::AsyncImageResponse(const QString & id, const QSize & requestedSize)
	: m_id(id), m_requestedSize(requestedSize)
{
    QStringList plugins;
    plugins.append ("ffmpegthumbs");
    auto job = new KIO::PreviewJob(KFileItemList() << KFileItem(QUrl::fromUserInput (id)), requestedSize, &plugins);

	connect (job, &KIO::PreviewJob::gotPreview, [this](KFileItem item, QPixmap pixmap)
	{
		m_image = pixmap.toImage ();
		emit this->finished ();
	});

	connect (job, &KIO::PreviewJob::failed, [this](KFileItem item)
    {
		emit this->cancel ();
		emit this->finished ();
	});


	job->start ();
}

QQuickTextureFactory * AsyncImageResponse::textureFactory() const
{
	return QQuickTextureFactory::textureFactoryForImage(m_image);
}
