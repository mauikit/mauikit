#include "mauiwindows.h"
#include <QDesktopServices>

MAUIWindows::MAUIWindows(QObject *parent) : AbstractPlatform(parent)
{

}

void MAUIWindows::shareFiles(const QList<QUrl> &urls)
{

}

void MAUIWindows::shareText(const QString &urls)
{

}

void MAUIWindows::openUrl(const QUrl &url)
{
    QDesktopServices::openUrl(url);
}

bool MAUIWindows::hasKeyboard()
{
    return true;
}

bool MAUIWindows::hasMouse()
{
    return true;
}

void MAUIWindows::notify(const QString &title, const QString &message, const QString &icon, const QString &imageUrl)
{

}
