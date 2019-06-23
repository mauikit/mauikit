/*
    This file is part of KDE.

    Copyright (c) 2008 Cornelius Schumacher <schumacher@kde.org>

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

#include "privatedataparser.h"

using namespace Attica;

PrivateData PrivateData::Parser::parseXml(QXmlStreamReader &xml)
{
    PrivateData data;
    QString key;

    // TODO: when we get internet and some documentation
    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("key")) {
                key = xml.readElementText();
            } else if (xml.name() == QLatin1String("value")) {
                data.setAttribute(key, xml.readElementText());
            } else if (xml.name() == QLatin1String("timestamp")) {
                data.setTimestamp(key, QDateTime::fromString(xml.readElementText(), Qt::ISODate));
            }
        } else if (xml.isEndElement() && (xml.name() == QLatin1String("data") || xml.name() == QLatin1String("user"))) {
            break;
        }
    }

    return data;
}

QStringList PrivateData::Parser::xmlElement() const
{
    return QStringList(QLatin1String("privatedata"));
}

