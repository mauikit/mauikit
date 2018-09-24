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

#include "handy.h"
#include "utils.h"
#include <QDebug>

#include <QIcon>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

Handy::Handy(QObject *parent) : QObject(parent) 
{
    
}

Handy::~Handy()
{
    
}

QVariantMap Handy::appInfo()
{
    auto app =  QCoreApplication::instance();
    
    auto res = QVariantMap({{"name", app->applicationName()},
                           {"version", app->applicationVersion()},
                           {"organization", app->organizationName()},
                           {"domain", app->organizationDomain()},
                           {"mauikit", MAUIKIT_VERSION_STR},
                           {"qt", QT_VERSION_STR} });
    
#ifdef Q_OS_ANDROID
    res.insert("icon", QGuiApplication::windowIcon().name());
#else
    res.insert("icon", QApplication::windowIcon().name());
#endif
    
qDebug() << "APP INFO" << res;
    
    return res;
    
}
