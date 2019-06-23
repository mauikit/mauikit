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

#include "projectparser.h"
#include <qdebug.h>

using namespace Attica;

Project Project::Parser::parseXml(QXmlStreamReader &xml)
{
    Project project;

    // For specs about the XML provided, see here:
    // http://www.freedesktop.org/wiki/Specifications/open-collaboration-services-draft#Projects
    while (!xml.atEnd()) {
        //qCDebug(ATTICA) << "XML returned:" << xml.text().toString();
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("projectid")) {
                project.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("name")) {
                project.setName(xml.readElementText());
            } else if (xml.name() == QLatin1String("version")) {
                project.setVersion(xml.readElementText());
            } else if (xml.name() == QLatin1String("license")) {
                project.setLicense(xml.readElementText());
            } else if (xml.name() == QLatin1String("url")) {
                project.setUrl(xml.readElementText());
            } else if (xml.name() == QLatin1String("summary")) {
                project.setSummary(xml.readElementText());
            } else if (xml.name() == QLatin1String("description")) {
                project.setDescription(xml.readElementText());
            } else if (xml.name() == QLatin1String("specfile")) {
                project.setSpecFile(xml.readElementText());
            } else if (xml.name() == QLatin1String("developers")) {
                project.setDevelopers(xml.readElementText().split(QLatin1String("\n")));
            } else if (xml.name() == QLatin1String("projectlist")) {
                QXmlStreamReader list_xml(xml.readElementText());
                while (!list_xml.atEnd()) {
                    list_xml.readNext();
                    if (xml.name() == QLatin1String("projectid")) {
                        project.setSpecFile(xml.readElementText());
                    }
                }

            }
        } else if (xml.isEndElement() && (xml.name() == QLatin1String("project") || xml.name() == QLatin1String("user"))) {
            break;
        }
    }
    return project;
}

QStringList Project::Parser::xmlElement() const
{
    return QStringList(QLatin1String("project")) << QLatin1String("user");
}
