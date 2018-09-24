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

#ifndef HANDY_H
#define HANDY_H

#include <QObject>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#include <QVariantMap>

#ifdef STATIC_MAUIKIT
class Handy : public QObject
#else
class MAUIKIT_EXPORT Handy : public QObject
#endif
{
    Q_OBJECT
public:
    Handy(QObject *parent = nullptr);
    ~Handy();
    Q_INVOKABLE static QVariantMap appInfo();    
};

#endif // HANDY_H
