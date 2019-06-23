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

#include "buildserviceparser.h"
#include <qdebug.h>

using namespace Attica;

BuildService BuildService::Parser::parseXml(QXmlStreamReader &xml)
{
    // For specs about the XML provided, see here:
    // http://www.freedesktop.org/wiki/Specifications/open-collaboration-services-draft

    BuildService buildservice;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {

            if (xml.name() == QLatin1String("id")) {
                buildservice.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("name")) {
                buildservice.setName(xml.readElementText());
            } else if (xml.name() == QLatin1String("registrationurl")) {
                buildservice.setUrl(xml.readElementText());
            } else if (xml.name() == QLatin1String("supportedtargets")) {
                while (!xml.atEnd()) {
                    xml.readNextStartElement();
                    if (xml.isStartElement()) {
                        if (xml.name() == QLatin1String("target")) {
                            Target t;
                            while (!xml.atEnd()) {
                                xml.readNextStartElement();
                                if (xml.isStartElement()) {
                                    if (xml.name() == QLatin1String("id")) {
                                        t.id = xml.readElementText();
                                    } else if (xml.name() == QLatin1String("name")) {
                                        t.name = xml.readElementText();
                                    }
                                } else if (xml.isEndElement() && (xml.name() == QLatin1String("target"))) {
                                    xml.readNext();
                                    break;
                                }
                            }
                            buildservice.addTarget(t);
                        }
                    } else if (xml.isEndElement() && (xml.name() == QLatin1String("supportedtargets"))) {
                        xml.readNext();
                        break;
                    }
                }
            }
        } else if (xml.isEndElement()
                   && ((xml.name() == QLatin1String("buildservice"))
                       || (xml.name() == QLatin1String("user")))) {
            break;
        }
    }
    return buildservice;
}

QStringList BuildService::Parser::xmlElement() const
{
    return QStringList(QLatin1String("buildservice")) << QLatin1String("user");
}
