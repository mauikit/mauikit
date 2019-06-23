/*
    This file is part of KDE.

    Copyright (c) 2018 Ralf Habacker <ralf.habacker@freenet.de>

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

#include "configparser.h"


using namespace Attica;

Config Config::Parser::parseXml(QXmlStreamReader& xml)
{
    Config config;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("version")) {
                config.setVersion( xml.readElementText());
            } else if (xml.name() == QLatin1String("website")) {
                config.setWebsite( xml.readElementText());
            } else if (xml.name() == QLatin1String("host")) {
                config.setHost( xml.readElementText());
            } else if (xml.name() == QLatin1String("contact")) {
                config.setContact( xml.readElementText());
            } else if (xml.name() == QLatin1String("ssl")) {
                config.setSsl(xml.readElementText() == QLatin1String("true"));
            }
        }

        if (xml.isEndElement() && xml.name() == QLatin1String("data")) {
            break;
        }
    }

    return config;
}


QStringList Config::Parser::xmlElement() const {
    return QStringList(QLatin1String( "data" ));
}
