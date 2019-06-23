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

#include "personparser.h"

using namespace Attica;

Person Person::Parser::parseXml(QXmlStreamReader &xml)
{
    Person person;
    bool hasAvatarPic = false;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("personid")) {
                person.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("firstname")) {
                person.setFirstName(xml.readElementText());
            } else if (xml.name() == QLatin1String("lastname")) {
                person.setLastName(xml.readElementText());
            } else if (xml.name() == QLatin1String("homepage")) {
                person.setHomepage(xml.readElementText());
            } else if (xml.name() == QLatin1String("avatarpic")) {
                person.setAvatarUrl(QUrl(xml.readElementText()));
            } else if (xml.name() == QLatin1String("avatarpicfound")) {
                QString value = xml.readElementText();
                if (value.toInt()) {
                    hasAvatarPic = true;
                }
            } else if (xml.name() == QLatin1String("birthday")) {
                person.setBirthday(QDate::fromString(xml.readElementText(), Qt::ISODate));
            } else if (xml.name() == QLatin1String("city")) {
                person.setCity(xml.readElementText());
            } else if (xml.name() == QLatin1String("country")) {
                person.setCountry(xml.readElementText());
            } else if (xml.name() == QLatin1String("latitude")) {
                person.setLatitude(xml.readElementText().toFloat());
            } else if (xml.name() == QLatin1String("longitude")) {
                person.setLongitude(xml.readElementText().toFloat());
            } else {
                person.addExtendedAttribute(xml.name().toString(), xml.readElementText());
            }
        } else if (xml.isEndElement() && (xml.name() == QLatin1String("person") || xml.name() == QLatin1String("user"))) {
            break;
        }
    }

    if (!hasAvatarPic) {
        person.setAvatarUrl(QUrl());
    }

    return person;
}

QStringList Person::Parser::xmlElement() const
{
    return QStringList(QLatin1String("person")) << QLatin1String("user");
}
