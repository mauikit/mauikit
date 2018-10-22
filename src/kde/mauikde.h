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

#ifndef MAUIKDE_H
#define MAUIKDE_H

#include <QObject>
#include <QVariantList>

class MAUIKDE : public QObject
{
    Q_OBJECT
public:
    MAUIKDE(QObject *parent = nullptr);
    ~MAUIKDE();
	
    Q_INVOKABLE static QVariantList services(const QUrl &url);
    Q_INVOKABLE static QVariantList devices();
    Q_INVOKABLE static bool sendToDevice(const QString &device, const QString &id, const QStringList &urls);
    Q_INVOKABLE static void openWithApp(const QString &exec, const QStringList &urls);
    Q_INVOKABLE static void attachEmail(const QStringList &urls);
    Q_INVOKABLE static void setColorScheme(const QString &schemeName, const QString &bg =  QString(), const QString &fg = QString());
    
signals:

public slots:
};

#endif // MAUIKDE_H
