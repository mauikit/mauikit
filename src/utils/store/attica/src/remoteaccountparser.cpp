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

#include "remoteaccountparser.h"
#include <qdebug.h>

using namespace Attica;

RemoteAccount RemoteAccount::Parser::parseXml(QXmlStreamReader &xml)
{
    RemoteAccount remoteaccount;

    // For specs about the XML provided, see here:
    // http://www.freedesktop.org/wiki/Specifications/open-collaboration-services-draft#RemoteAccounts
    while (!xml.atEnd()) {
        //qCDebug(ATTICA) << "XML returned:" << xml.text().toString();
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("id")) {
                remoteaccount.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("type")) {
                remoteaccount.setType(xml.readElementText());
            } else if (xml.name() == QLatin1String("typeid")) {  // FIXME: change to remoteserviceid sometime soon (OCS API change pending
                remoteaccount.setRemoteServiceId(xml.readElementText());
            } else if (xml.name() == QLatin1String("data")) {
                remoteaccount.setData(xml.readElementText());
            } else if (xml.name() == QLatin1String("login")) {
                remoteaccount.setLogin(xml.readElementText());
            } else if (xml.name() == QLatin1String("password")) {
                remoteaccount.setPassword(xml.readElementText());
            }
        } else if (xml.isEndElement() && (xml.name() == QLatin1String("remoteaccount") || xml.name() == QLatin1String("user"))) {
            break;
        }
    }
    return remoteaccount;
}

QStringList RemoteAccount::Parser::xmlElement() const
{
    return QStringList(QLatin1String("remoteaccount")) << QLatin1String("user");
}
