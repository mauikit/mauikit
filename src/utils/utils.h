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

#include <QColor>
#include <QObject>

#include "appsettings.h"

namespace UTIL
{

/**
 * @brief whoami
 * @return
 */
static const inline QString whoami()
{
#ifdef Q_OS_UNIX
    return qgetenv("USER"); /// for Mac or Linux
#else
    return qgetenv("USERNAME"); // for windows
#endif
}

/**
 * @brief saveSettings
 * @param key
 * @param value
 * @param group
 * @param global
 */
static inline void saveSettings(const QString &key, const QVariant &value, const QString &group, const bool &global = false)
{
    if (global)
        AppSettings::global().save(key, value, group);
    else
        AppSettings::local().save(key, value, group);
}

/**
 * @brief loadSettings
 * @param key
 * @param group
 * @param defaultValue
 * @param global
 * @return
 */
static inline const QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue, const bool &global = false)
{
    if (global)
        return AppSettings::global().load(key, group, defaultValue);
    else
        return AppSettings::local().load(key, group, defaultValue);
}

/**
 * @brief isDark
 * @param color
 * @return
 */
static inline bool isDark(const QColor &color)
{
    const double darkness = 1 - (0.299 * color.red() + 0.587 * color.green() + 0.114 * color.blue()) / 255;
    return (darkness > 0.5);
}

}

#endif // UTILS_H
