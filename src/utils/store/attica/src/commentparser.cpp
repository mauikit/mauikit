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

#include "commentparser.h"
#include "atticautils.h"
#include <QDebug>

using namespace Attica;

Comment Comment::Parser::parseXml(QXmlStreamReader &xml)
{
    Comment comment;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("id")) {
                comment.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("subject")) {
                comment.setSubject(xml.readElementText());
            } else if (xml.name() == QLatin1String("text")) {
                comment.setText(xml.readElementText());
            } else if (xml.name() == QLatin1String("childcount")) {
                comment.setChildCount(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("user")) {
                comment.setUser(xml.readElementText());
            } else if (xml.name() == QLatin1String("date")) {
                comment.setDate(Utils::parseQtDateTimeIso8601(xml.readElementText()));
            } else if (xml.name() == QLatin1String("score")) {
                comment.setScore(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("children")) {
                QList<Comment> children = parseXmlChildren(xml);
                comment.setChildren(children);
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("comment")) {
            break;
        }
    }

    return comment;
}

QList<Comment> Comment::Parser::parseXmlChildren(QXmlStreamReader &xml)
{
    QList<Comment> children;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("comment")) {
                Comment comment = parseXml(xml);
                children.append(comment);
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("children")) {
            break;
        }
    }

    return children;
}

QStringList Comment::Parser::xmlElement() const
{
    return QStringList(QLatin1String("comment"));
}
