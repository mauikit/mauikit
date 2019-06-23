/*
    This file is part of KDE.

    Copyright (c) 2009 Eckhart Wörner <ewoerner@kde.org>

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

#include "parser.h"
#include <QStringList>
#include <QDebug>

using namespace Attica;

static bool stringList_contains_stringRef(const QStringList &stringList, const QStringRef &str)
{
    for (const auto &string : stringList) {
        if (str == string)
            return true;
    }
    return false;
}

template <class T>
Parser<T>::~Parser()
{
}

template <class T>
T Parser<T>::parse(const QString &xmlString)
{
    QStringList elements = xmlElement();
    T item;

    QXmlStreamReader xml(xmlString);

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("meta")) {
                parseMetadataXml(xml);
            } else if (stringList_contains_stringRef(elements, xml.name())) {
                item = parseXml(xml);
            }
        }
    }
    if (xml.hasError()) {
        // TODO: error handling in metadata?
        qWarning() << "parse():: XML Error: " << xml.errorString() << "\nIn XML:\n" << xmlString;
    }

    return item;
}

template <class T>
typename T::List Parser<T>::parseList(const QString &xmlString)
{
    /*
            QString testxml = QString("<?xml version=\"1.0\"?>\
    <ocs>\
     <meta>\
      <status>ok</status>\
      <statuscode>100</statuscode>\
      <message></message>\
     </meta>\
     <data>\
      <buildservice>\
       <id>obs</id>\
       <name>openSUSE Build Service</name>\
       <registrationurl>foobar.com</registrationurl>\
       <supportedtargets>\
        <target>openSUSE 11.2 32bit Intel</target>\
        <target>openSUSE 11.3 64bit Intel</target>\
        <target>openSUSE 11.3 32bit Intel</target>\
        <target>openSUSE 11.3 64bit Intel</target>\
       </supportedtargets>\
      </buildservice>\
      <buildservice>\
       <id>mbs</id>\
       <name>MeeGo Build Service</name>\
       <registrationurl>foobar42.com</registrationurl>\
       <supportedtargets>\
        <target>MeeGo 1.0 Intel</target>\
        <target>MeeGo 1.0 ARM</target>\
        <target>MeeGo 1.1 Intel</target>\
        <target>MeeGo 1.1 ARM</target>\
       </supportedtargets>\
      </buildservice>\
      <buildservice>\
       <id>sbs</id>\
       <name>Sebas' Build Service</name>\
       <registrationurl>foobar42.com</registrationurl>\
       <supportedtargets>\
        <target>sebasix 1.3 33bit</target>\
        <target>sebasis 4.4 14bit</target>\
        <target>sebasix 1.3 65bit</target>\
        <target>sebasis 4.4 37bit</target>\
       </supportedtargets>\
      </buildservice>\
     </data>\
    </ocs>\
     ");

        qCDebug(ATTICA) << "parsing list:" << xmlString;
        */
    QStringList elements = xmlElement();
    typename T::List items;

    //QXmlStreamReader xml( xmlString );
    QXmlStreamReader xml(xmlString);

    while (!xml.atEnd()) {
        xml.readNext();
        //qCDebug(ATTICA) << "parseList():: Looking for:" << xml.name().toString();
        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("data")) {
                while (!xml.atEnd()) {
                    xml.readNext();

                    if (xml.isEndElement() && xml.name() == QLatin1String("data")) {
                        break;
                    }

                    if (xml.isStartElement() && stringList_contains_stringRef(elements, xml.name())) {
                        //qCDebug(ATTICA) << "xxxxxxxxx New Item!" << xml.name().toString();
                        items.append(parseXml(xml));
                    }
                }
            } else if (xml.name() == QLatin1String("meta")) {
                parseMetadataXml(xml);
            }
        }
    }
    if (xml.hasError()) {
        // TODO: error handling in metadata?
        qWarning() << "parseList():: XML Error: " << xml.errorString() << "\nIn xml name" << xml.name() << "with text" << xml.text() << "at offset:\n" << xml.characterOffset() << "\nIn XML:\n" << xmlString;
    }

    return items;
}

template <class T>
void Parser<T>::parseMetadataXml(QXmlStreamReader &xml)
{
    while (!xml.atEnd()) {
        xml.readNext();
        if (xml.isEndElement() && xml.name() == QLatin1String("meta")) {
            break;
        } else if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("status")) {
                m_metadata.setStatusString(xml.readElementText());
            } else if (xml.name() == QLatin1String("statuscode")) {
                m_metadata.setStatusCode(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("message")) {
                m_metadata.setMessage(xml.readElementText());
            } else if (xml.name() == QLatin1String("totalitems")) {
                m_metadata.setTotalItems(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("itemsperpage")) {
                m_metadata.setItemsPerPage(xml.readElementText().toInt());
            }
        }
    }
    if (xml.hasError()) {
        // TODO: error handling in metadata?
        qWarning() << "XML Error: " << xml.errorString();
    }

}

template <class T>
Metadata Parser<T>::metadata() const
{
    return m_metadata;
}
