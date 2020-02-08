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

#ifndef MAUIKIT_H
#define MAUIKIT_H

#define MAUIKIT_VERSION "1.0.2"

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

class MauiAccounts;
#ifdef STATIC_MAUIKIT
class MauiKit : public QQmlExtensionPlugin
        #else
class MAUIKIT_EXPORT MauiKit : public QQmlExtensionPlugin
        #endif
{
    Q_OBJECT

#ifndef STATIC_MAUIKIT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
#endif

public:    
    void registerTypes(const char *uri) Q_DECL_OVERRIDE;

    static MauiKit& getInstance()
    {
        static MauiKit instance;
        return instance;
    }

    static void registerTypes()
    {
        static MauiKit instance;
        instance.registerTypes("org.kde.mauikit");
    }
    
    void initResources();

private:
    QUrl componentUrl(const QString &fileName) const;
    QString resolveFilePath(const QString &path) const
    {
#ifdef STATIC_MAUIKIT
        return QStringLiteral(":/org/kde/mauikit/") + path;
#else
        return baseUrl().toLocalFile() + QLatin1Char('/') + path;
#endif
    }
    
    QString resolveFileUrl(const QString &filePath) const
    {
#ifdef STATIC_MAUIKIT
        return filePath;
#else
        return baseUrl().toString() + QLatin1Char('/') + filePath;
#endif
    }

signals:

public slots:
};

#endif // MAUIKIT_H
