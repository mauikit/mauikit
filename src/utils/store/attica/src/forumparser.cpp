/*
    This file is part of KDE.

    Copyright (c) 2011 Laszlo Papp <djszapi@archlinux.us>

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

#include "forumparser.h"
#include "atticautils.h"

using namespace Attica;

Forum Forum::Parser::parseXml(QXmlStreamReader &xml)
{
    Forum forum;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("id")) {
                forum.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("name")) {
                forum.setName(xml.readElementText());
            } else if (xml.name() == QLatin1String("description")) {
                forum.setDescription(xml.readElementText());
            } else if (xml.name() == QLatin1String("date")) {
                forum.setDate(Utils::parseQtDateTimeIso8601(xml.readElementText()));
            } else if (xml.name() == QLatin1String("icon")) {
                forum.setIcon(QUrl(xml.readElementText()));
            } else if (xml.name() == QLatin1String("childcount")) {
                forum.setChildCount(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("children")) {
                QList<Forum> children = parseXmlChildren(xml);
                forum.setChildren(children);
            } else if (xml.name() == QLatin1String("topics")) {
                forum.setTopics(xml.readElementText().toInt());
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("forum")) {
            break;
        }
    }

    return forum;
}

QList<Forum> Forum::Parser::parseXmlChildren(QXmlStreamReader &xml)
{
    QList<Forum> children;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("forum")) {
                Forum forum = parseXml(xml);
                children.append(forum);
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("children")) {
            break;
        }
    }

    return children;
}

QStringList Forum::Parser::xmlElement() const
{
    return QStringList(QLatin1String("forum"));
}
