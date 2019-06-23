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

#include "messageparser.h"

using namespace Attica;

Message Message::Parser::parseXml(QXmlStreamReader &xml)
{
    Message message;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("id")) {
                message.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("messagefrom")) {
                message.setFrom(xml.readElementText());
            } else if (xml.name() == QLatin1String("messageto")) {
                message.setTo(xml.readElementText());
            } else if (xml.name() == QLatin1String("senddate")) {
                message.setSent(QDateTime::fromString(xml.readElementText(), Qt::ISODate));
            } else if (xml.name() == QLatin1String("status")) {
                message.setStatus(Message::Status(xml.readElementText().toInt()));
            } else if (xml.name() == QLatin1String("subject")) {
                message.setSubject(xml.readElementText());
            } else if (xml.name() == QLatin1String("body")) {
                message.setBody(xml.readElementText());
            }
        }

        if (xml.isEndElement() && xml.name() == QLatin1String("message")) {
            break;
        }
    }

    return message;
}

QStringList Message::Parser::xmlElement() const
{
    return QStringList(QLatin1String("message"));
}
