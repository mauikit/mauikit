#include "abstractplatform.h"

AbstractPlatform::AbstractPlatform(QObject *parent) : QObject(parent)
{

}

void AbstractPlatform::notify(const QString &title, const QString &message, const QString &icon, const QString &imageUrl)
{
    Q_UNUSED(title)
    Q_UNUSED(message)
    Q_UNUSED(icon)
    Q_UNUSED(imageUrl)
}
