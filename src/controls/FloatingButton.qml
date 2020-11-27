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

import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

/**
 * FloatingButton
 * A styled button to be used above other elements.
 *
 */
MouseArea
{
    id: control
    z: 999

    height: Maui.Style.toolBarHeight
    width: height

    /**
      * icon : icon
      */
    property alias icon : _button.icon

    /**
      * text : string
      */
    property alias text: _button.text

    /**
      * display : ToolButton.display
      */
    property alias display: _button.display

    /**
      * clicked :
      */
    signal clicked()

    Kirigami.Theme.backgroundColor: Kirigami.Theme.highlightColor
    Kirigami.Theme.textColor:  Kirigami.Theme.highlightedTextColor

    Rectangle
    {
        id: _rec
        anchors.fill: parent
        radius: Maui.Style.radiusV
        color: control.Kirigami.Theme.backgroundColor

        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
            radius: Maui.Style.radiusV
            border.color: Qt.darker(Kirigami.Theme.backgroundColor, 2.7)
            opacity: 0.7

            Rectangle
            {
                anchors.fill: parent
                color: "transparent"
                radius: parent.radius - 0.5
                border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
                opacity: 0.8
                anchors.margins: 1
            }
        }


        ToolButton
        {
            id : _button
            anchors.fill: parent
            icon.height: Maui.Style.iconSizes.medium
            icon.width: Maui.Style.iconSizes.medium
            Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
            onClicked: control.clicked()
        }
    }

    DropShadow
    {
        anchors.fill: parent
        cached: true
        horizontalOffset: 0
        verticalOffset: 0
        radius: 8.0
        samples: 16
        color: "#333"
        smooth: true
        source: _rec
    }
}
