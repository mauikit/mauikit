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

#ifndef KDECONNECT_H
#define KDECONNECT_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QVariantList>

class KdeConnect : public QObject
{
    Q_OBJECT
public:
    explicit KdeConnect(QObject *parent = nullptr);
    static QVariantList getDevices();
    static bool sendToDevice(const QString &device, const QString &id, const QString &url);
signals:

public slots:
};

#endif // KDECONNECT_H
