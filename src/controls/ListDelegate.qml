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
import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control

    property bool isCurrentListItem :  ListView.isCurrentItem

    property alias label: controlLabel.text
	property int radius : 0
	
	signal rightClicked()
	
    width: parent.width
    height: rowHeight

    clip: true

    property string labelColor: ListView.isCurrentItem ? highlightedTextColor :
                                                         textColor

	
	MouseArea
	{
		anchors.fill: parent
		acceptedButtons:  Qt.RightButton
		onClicked:
		{
			if(!isMobile && mouse.button === Qt.RightButton)
				rightClicked()
		}
	}
														 
    background: Rectangle
    {
        anchors.fill: parent
        color: isCurrentListItem ? highlightColor : "transparent"
		radius: control.radius
        //                                   index % 2 === 0 ? Qt.lighter(backgroundColor,1.2) :
        //                                                     backgroundColor
    }

    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            visible: model.icon !== typeof("undefined")
            width: model.icon ? parent.height : 0

            Maui.ToolButton
            {
                id:controlIcon
                anchors.centerIn: parent
                iconName: model.icon ? model.icon : ""
//                isMask: !isMobile
                iconColor: labelColor
                enabled: false
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Label
            {
                id: controlLabel
                height: parent.height
                width: parent.width
                verticalAlignment:  Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft

                text: model.label
                font.bold: false
                elide: Text.ElideRight

                font.pointSize: isMobile ? fontSizes.big :
                                           fontSizes.default
                color: labelColor
            }
        }
    }
}
