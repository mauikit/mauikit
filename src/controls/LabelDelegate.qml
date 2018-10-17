/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import "private"

ItemDelegate
{
	id: control
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
	
    width: parent.width
    height: rowHeight

    property bool isSection : false
    property bool boldLabel : false
    property alias label: labelTxt.text
    property alias labelTxt : labelTxt
    property string labelColor: ListView.isCurrentItem ? colorScheme.highlightedTextColor : colorScheme.textColor

    background: Rectangle
    {
        color:  isSection ? "transparent" : (index % 2 === 0 ? Qt.darker(colorScheme.backgroundColor) : "transparent")
        opacity: 0.1
    }

    ColumnLayout
    {
        anchors.fill: parent

        Label
        {
            id: labelTxt
            Layout.margins: contentMargins
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

            width: parent.width
            height: parent.height

            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            text: labelTxt.text
            elide: Text.ElideRight
            color: labelColor
            font.pointSize: fontSizes.default

            font.bold: boldLabel
            font.weight : boldLabel ? Font.Bold : Font.Normal
        }
    }
}
