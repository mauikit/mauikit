#include "thumbnailer.h"

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include <KIO/PreviewJob>
#endif

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
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    QStringList plugins = KIO::PreviewJob::defaultPlugins();
    auto job = new KIO::PreviewJob(KFileItemList() << KFileItem(QUrl::fromUserInput (id)), requestedSize, &plugins);

    connect (job, &KIO::PreviewJob::gotPreview, [this](KFileItem, QPixmap pixmap)
	{
		m_image = pixmap.toImage ();
		emit this->finished ();
	});

    connect (job, &KIO::PreviewJob::failed, [this](KFileItem)
    {
		emit this->cancel ();
		emit this->finished ();
	});

	job->start ();
#endif
}

QQuickTextureFactory * AsyncImageResponse::textureFactory() const
{
	return QQuickTextureFactory::textureFactoryForImage(m_image);
}
