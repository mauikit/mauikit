/*
    This file is part of KDE.

    Copyright (c) 2012 Laszlo Papp <lpapp@kde.org>

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

#include "cloudparser.h"
#include "atticautils.h"

using namespace Attica;

Cloud Cloud::Parser::parseXml(QXmlStreamReader &xml)
{
    Cloud cloud;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("name")) {
                cloud.setName(xml.readElementText());
            } else if (xml.name() == QLatin1String("url")) {
                cloud.setUrl(xml.readElementText());
                // TODO: there should be usage for the attica icon class
            } else if (xml.name() == QLatin1String("icon")) {
                cloud.setIcon(QUrl(xml.readElementText()));
            } else if (xml.name() == QLatin1String("quota")) {
                cloud.setQuota(xml.readElementText().toULongLong());
            } else if (xml.name() == QLatin1String("free")) {
                cloud.setFree(xml.readElementText().toULongLong());
            } else if (xml.name() == QLatin1String("used")) {
                cloud.setUsed(xml.readElementText().toULongLong());
            } else if (xml.name() == QLatin1String("relative")) {
                cloud.setRelative(xml.readElementText().toFloat());
            } else if (xml.name() == QLatin1String("key")) {
                cloud.setKey(xml.readElementText());
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("cloud")) {
            break;
        }
    }

    return cloud;
}

QStringList Cloud::Parser::xmlElement() const
{
    return QStringList(QLatin1String("cloud"));
}
