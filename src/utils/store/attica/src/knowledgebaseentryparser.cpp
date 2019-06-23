/*
    This file is part of KDE.

    Copyright (c) 2008 Cornelius Schumacher <schumacher@kde.org>
    Copyright (c) 2009 Marco Martin <notmart@gmail.com>

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

#include "knowledgebaseentryparser.h"

using namespace Attica;

KnowledgeBaseEntry KnowledgeBaseEntry::Parser::parseXml(QXmlStreamReader &xml)
{
    KnowledgeBaseEntry knowledgeBase;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("id")) {
                knowledgeBase.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("status")) {
                knowledgeBase.setStatus(xml.readElementText());
            } else if (xml.name() == QLatin1String("contentId")) {
                knowledgeBase.setContentId(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("user")) {
                knowledgeBase.setUser(xml.readElementText());
            } else if (xml.name() == QLatin1String("changed")) {
                knowledgeBase.setChanged(QDateTime::fromString(xml.readElementText(), Qt::ISODate));
            } else if (xml.name() == QLatin1String("description")) {
                knowledgeBase.setDescription(xml.readElementText());
            } else if (xml.name() == QLatin1String("answer")) {
                knowledgeBase.setAnswer(xml.readElementText());
            } else if (xml.name() == QLatin1String("comments")) {
                knowledgeBase.setComments(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("detailpage")) {
                knowledgeBase.setDetailPage(QUrl(xml.readElementText()));
            } else if (xml.name() == QLatin1String("contentid")) {
                knowledgeBase.setContentId(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("name")) {
                knowledgeBase.setName(xml.readElementText());
            } else {
                knowledgeBase.addExtendedAttribute(xml.name().toString(), xml.readElementText());
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("content")) {
            break;
        }
    }

    return knowledgeBase;
}

QStringList KnowledgeBaseEntry::Parser::xmlElement() const
{
    return QStringList(QLatin1String("content"));
}
