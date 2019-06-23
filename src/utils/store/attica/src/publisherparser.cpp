/*
    This file is part of KDE.

    Copyright 2010 Sebastian Kügler <sebas@kde.org>

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

#include "publisherparser.h"
#include <qdebug.h>

using namespace Attica;

Publisher Publisher::Parser::parseXml(QXmlStreamReader &xml)
{
    // For specs about the XML provided, see here:
    // http://www.freedesktop.org/wiki/Specifications/open-collaboration-services-draft

    Publisher publisher;
    QStringList fields;

    while (!xml.atEnd()) {
        //qCDebug(ATTICA) << "XML returned:" << xml.text().toString();
        xml.readNext();

        if (xml.isStartElement()) {

            if (xml.name() == QLatin1String("id")) {
                publisher.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("name")) {
                publisher.setName(xml.readElementText());
            } else if (xml.name() == QLatin1String("registrationurl")) {
                publisher.setUrl(xml.readElementText());
            } else if (xml.name() == QLatin1String("fields")) {
                while (!xml.atEnd()) {
                    xml.readNextStartElement();
                    if (xml.isStartElement()) {
                        if (xml.name() == QLatin1String("field")) {
                            Field t;
                            while (!xml.atEnd()) {
                                xml.readNextStartElement();
                                if (xml.isStartElement()) {
                                    if (xml.name() == QLatin1String("fieldtype")) {
                                        t.type = xml.readElementText();
                                    } else if (xml.name() == QLatin1String("name")) {
                                        t.name = xml.readElementText();
                                    } else if (xml.name() == QLatin1String("fieldsize")) {
                                        t.fieldsize = xml.readElementText().toInt();
                                    } else if (xml.name() == QLatin1String("required")) {
                                        t.required = xml.readElementText() == QLatin1String("true");
                                    } else if (xml.name() == QLatin1String("options")) {
                                        while (!xml.atEnd()) {
                                            xml.readNextStartElement();
                                            if (xml.isStartElement()) {
                                                if (xml.name() == QLatin1String("option")) {
                                                    t.options << xml.readElementText();
                                                }
                                            } else if (xml.isEndElement() && xml.name() == QLatin1String("options")) {
                                                xml.readNext();
                                                break;
                                            }
                                        }
                                    }
                                } else if (xml.isEndElement() && (xml.name() == QLatin1String("field"))) {
                                    xml.readNext();
                                    break;
                                }
                            }
                            publisher.addField(t);
                        }
                    } else if (xml.isEndElement() && (xml.name() == QLatin1String("fields"))) {
                        xml.readNext();
                        break;
                    }
                }
            } else if (xml.name() == QLatin1String("supportedtargets")) {
                while (!xml.atEnd()) {
                    xml.readNextStartElement();
                    if (xml.isStartElement()) {
                        if (xml.name() == QLatin1String("target")) {
                            Target t;
                            t.name = xml.readElementText();
                            publisher.addTarget(t);
                        }
                    } else if (xml.isEndElement() && (xml.name() == QLatin1String("supportedtargets"))) {
                        xml.readNext();
                        break;
                    }
                }
            }
        } else if (xml.isEndElement()
                   && ((xml.name() == QLatin1String("publisher"))
                       || (xml.name() == QLatin1String("user")))) {
            break;
        }
    }
    return publisher;
}

QStringList Publisher::Parser::xmlElement() const
{
    return QStringList(QLatin1String("publisher")) << QLatin1String("user");
}
