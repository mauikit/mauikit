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

#include <QtTest>
#include <configparser.h>

using namespace Attica;

class ConfigTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testParsing();
};

void ConfigTest::testParsing()
{
    Config::Parser parser;
    QString validData (QLatin1String("<?xml version=\"1.0\"?>"
                                     "<ocs><data>"
                                     "<version>1.7</version>"
                                     "<website>store.kde.org</website>"
                                     "<host>api.kde-look.org</host>"
                                     "<contact>contact@opendesktop.org</contact>"
                                     "<ssl>true</ssl>"
                                     "</data></ocs>"));
    Config config = parser.parse(validData);
    QVERIFY(config.isValid());

    QString invalidData = QLatin1String("<ocs><braaaaaaaaaaawrlawrf></braaaaaaaaaaawrlawrf></ocs>");
    config = parser.parse(invalidData);
    QVERIFY(!config.isValid());
}

QTEST_GUILESS_MAIN(ConfigTest)

#include "configtest.moc"
