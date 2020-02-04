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

import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0
import "private"

ItemDelegate
{
    id: control

    default property alias content : _content.data

    property alias mouseArea : _mouseArea
//    property alias tapArea : _tapArea
    property bool draggable: false
    property bool isCurrentItem :  false

    property int radius: Maui.Style.radiusV
    highlighted: isCurrentItem
    //override the itemdelegate default signals to allow dragging content
    signal pressed(var mouse)
    signal pressAndHold(var mouse)
    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal doubleClicked(var mouse)

    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "transparent"

    hoverEnabled: !Kirigami.Settings.isMobile

    padding: 0
    bottomPadding: padding
    rightPadding: padding
    leftPadding: padding
    topPadding: padding
    
    MouseArea
    {
        id: _mouseArea
//        enabled: !Kirigami.Settings.isMobile
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        property int startX
        property int startY

        onClicked:
        {
            if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                control.rightClicked(mouse)
            else
                control.clicked(mouse)
        }

        onDoubleClicked: control.doubleClicked(mouse)

        onPressed:
        {
            if(control.draggable && mouse.source !== Qt.MouseEventSynthesizedByQt)
            {
                drag.target = control
                control.grabToImage(function(result)
                {
                    parent.Drag.imageSource = result.url
                })
            }else drag.target = null


            startX = control.x
            startY = control.y
            control.pressed(mouse)
        }

        onReleased :
        {
            control.x = startX
            control.y = startY
        }

        onPressAndHold : control.pressAndHold(mouse)
    }

//    TapHandler
//    {
//        id: _tapArea
//        enabled: Kirigami.Settings.isMobile
//        acceptedButtons: Qt.RightButton
//        onSingleTapped: control.clicked(eventPoint)
//        onDoubleTapped: control.doubleClicked(eventPoint)
//        onLongPressed: control.pressAndHold(eventPoint)
//    }
    
    contentItem: null
    
    Item
    {
		id: _content
		
		anchors
		{
			fill: control
			topMargin: control.topPadding
			bottomMargin: control.bottomPadding
			leftMargin: control.leftPadding
			rightMargin: control.rightPadding
			margins: control.padding
		}
	}

    background: Rectangle
    {
        anchors
        {
            fill: control
            topMargin: control.topPadding
            bottomMargin: control.bottomPadding
            leftMargin: control.leftPadding
            rightMargin: control.rightPadding
            margins: control.padding
        }

        Behavior on color
        {
            ColorAnimation
            {
                duration: Kirigami.Units.shortDuration
            }
        }
        color: control.isCurrentItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : control.Kirigami.Theme.backgroundColor

        radius: control.radius
        border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"
    }
}
