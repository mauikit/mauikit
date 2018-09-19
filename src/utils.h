#ifndef UTILS_H
#define UTILS_H

#include <QString>
#include <QFileInfo>
#include <QSettings>

namespace UTIL
{
    inline bool fileExists(const QString &url)
    {
        QFileInfo path(url);
        if (path.exists()) return true;
        else return false;
    }

    inline QString whoami()
    {
#ifdef Q_OS_UNIX
        return qgetenv("USER"); ///for MAc or Linux
#else
        return  qgetenv("USERNAME"); //for windows
#endif
    }

    inline void saveSettings(const QString &key, const QVariant &value, const QString &group)
    {
        QSettings setting("org.kde.maui","mauikit");
        setting.beginGroup(group);
        setting.setValue(key,value);
        setting.endGroup();
    }

    inline QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
    {
        QVariant variant;
        QSettings setting("org.kde.maui","mauikit");
        setting.beginGroup(group);
        variant = setting.value(key,defaultValue);
        setting.endGroup();

        return variant;
    }

}


#endif // UTILS_H
