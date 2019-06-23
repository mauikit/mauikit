/*
    This file is part of KDE.

    Copyright (c) 2010 Intel Corporation
    Author: Mateu Batle Sastre <mbatle@collabora.co.uk>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "atticautils.h"
#include <QStringList>

using namespace Attica;

QDateTime Utils::parseQtDateTimeIso8601(const QString &str)
{
    QDateTime result;
    QStringList list;
    QString datetime;

    int tzsign = 0;
    if (str.indexOf(QLatin1String("+")) != -1) {
        list = str.split(QLatin1String("+"));
        datetime = list[0];
        tzsign = 1;
    } else if (str.indexOf(QLatin1String("-")) != -1) {
        list = str.split(QLatin1String("-"));
        datetime = list[0];
        tzsign = -1;
    } else {
        datetime = str;
    }

    // parse date time
    result = QDateTime::fromString(datetime, Qt::ISODate);
    result.setTimeSpec(Qt::UTC);

    // parse timezone
    if (list.count() == 2) {
        QString tz = list[1];
        int hh = 0;
        int mm = 0;
        int tzsecs = 0;
        if (tz.indexOf(QLatin1String(":")) != -1) {
            QStringList tzlist = tz.split(QLatin1String(":"));
            if (tzlist.count() == 2) {
                hh = tzlist[0].toInt();
                mm = tzlist[1].toInt();
            }
        } else {
            hh = tz.leftRef(2).toInt();
            mm = tz.midRef(2).toInt();
        }

        tzsecs = 60 * 60 * hh + 60 * mm;
        result = result.addSecs(- tzsecs * tzsign);
    }

    return result;
}

const char *Utils::toString(QNetworkAccessManager::Operation operation)
{
    switch(operation) {
    case QNetworkAccessManager::GetOperation : return "Get";
    case QNetworkAccessManager::HeadOperation : return "Head";
    case QNetworkAccessManager::PutOperation : return "Put";
    case QNetworkAccessManager::PostOperation : return "Post";
    case QNetworkAccessManager::DeleteOperation : return "Delete";
    case QNetworkAccessManager::CustomOperation : return "Custom";
    default: return "unknown";
    }
    return "invalid";
}
