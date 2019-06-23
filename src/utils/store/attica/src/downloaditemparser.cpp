/*
    This file is part of KDE.

    Copyright (c) 2009 Frederik Gladhorn <gladhorn@kde.org>

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

#include "downloaditemparser.h"

#include <QXmlStreamReader>

using namespace Attica;

QStringList DownloadItem::Parser::xmlElement() const
{
    return QStringList(QLatin1String("content"));
}

DownloadItem DownloadItem::Parser::parseXml(QXmlStreamReader &xml)
{
    DownloadItem item;

    while (!xml.atEnd()) {
        xml.readNext();
        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("downloadlink")) {
                item.setUrl(QUrl(xml.readElementText()));
            } else if (xml.name() == QLatin1String("mimetype")) {
                item.setMimeType(xml.readElementText());
            } else if (xml.name() == QLatin1String("packagename")) {
                item.setPackageName(xml.readElementText());
            } else if (xml.name() == QLatin1String("packagerepository")) {
                item.setPackageRepository(xml.readElementText());
            } else if (xml.name() == QLatin1String("gpgfingerprint")) {
                item.setGpgFingerprint(xml.readElementText());
            } else if (xml.name() == QLatin1String("gpgsignature")) {
                item.setGpgSignature(xml.readElementText());
            } else if (xml.name() == QLatin1String("downloadway")) {
                item.setType(DownloadDescription::Type(xml.readElementText().toInt()));
            }
        }
    }
    return item;
}
