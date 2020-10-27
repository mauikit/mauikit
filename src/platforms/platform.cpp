#include "platform.h"

#ifdef Q_OS_ANDROID
#include "mauiandroid.h"
#elif defined Q_OS_MAC
#include "mauimacos.h"
#elif defined Q_OS_WIN
#include "mauiwindows.h"
#elif defined Q_OS_IOS
#include "mauiios.h"
#else
#include "mauilinux.h"
#endif

Platform *Platform::qmlAttachedProperties(QObject *object)
{
    Q_UNUSED(object)
    return Platform::instance();
}

Platform::Platform(QObject *parent) : AbstractPlatform(parent),
    #ifdef Q_OS_ANDROID
    m_platform(new MAUIAndroid(this))
    #elif defined Q_OS_MAC
      m_platform(new MAUIMacOS(this))
    #elif defined Q_OS_WIN
      m_platform(new MAUIWindows(this))
    #elif defined Q_OS_IOS
      m_platform(new MAUIIOS(this))
    #else
      m_platform(MAUIKDE::instance())
    #endif
{    
    connect(m_platform, &AbstractPlatform::shareFilesRequest, this, &Platform::shareFilesRequest);
}

void Platform::shareFiles(const QList<QUrl> &urls)
{
    m_platform->shareFiles(urls);
}

void Platform::shareText(const QString &text)
{
    m_platform->shareText(text);
}

void Platform::openUrl(const QUrl &url)
{
    m_platform->openUrl(url);
}

bool Platform::hasKeyboard()
{
    return m_platform->hasKeyboard();
}

bool Platform::hasMouse()
{
    return m_platform->hasMouse();
}
