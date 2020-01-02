/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef UTILS_H
#define UTILS_H

#include <QString>
#include <QFileInfo>
#include <QSettings>
#include <QDebug>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#define MAUIKIT_MAJOR_VERSION 0
#define MAUIKIT_MINOR_VERSION 1
#define MAUIKIT_PATCH_VERSION 0

#define MAUIKIT_VERSION_STR "0.1.0"

namespace UTIL
{
	static const auto app = QCoreApplication::instance();	

    static const inline QString whoami()
    {
#ifdef Q_OS_UNIX
        return qgetenv("USER"); ///for Mac or Linux
#else
        return  qgetenv("USERNAME"); //for windows
#endif
    }

    static inline void saveSettings(const QString &key, const QVariant &value, const QString &group, QString app = UTIL::app->applicationName(), const QString organization = UTIL::app->organizationName())
    {
        QSettings setting(organization.isEmpty() ?  QString("org.kde.maui") : organization, app);
        setting.beginGroup(group);
        setting.setValue(key,value);
        setting.endGroup();
    }

    static inline const QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue, const QString app = UTIL::app->applicationName(), const QString organization = UTIL::app->organizationName())
    {
        QVariant variant;
		QSettings setting(organization.isEmpty() ?  QString("org.kde.maui") : organization, app);
		setting.beginGroup(group);
        variant = setting.value(key,defaultValue);
        setting.endGroup();
        return variant;
    }
}


#endif // UTILS_H
