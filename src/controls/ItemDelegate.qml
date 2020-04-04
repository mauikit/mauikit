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

Kirigami.DelegateRecycler
{    
    id: control
    
    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "transparent"
    
    default property alias content : _content.data

    property alias mouseArea : _mouseArea
    //    property alias tapArea : _tapArea
    property bool draggable: false
    property bool isCurrentItem :  false

    property int radius: Maui.Style.radiusV

    property alias padding: _delegate.padding
    property alias leftPadding: _delegate.leftPadding
    property alias rightPadding: _delegate.rightPadding
    property alias topPadding: _delegate.topPadding
    property alias bottomPadding: _delegate.bottomPadding

    property alias hovered: _delegate.hovered
    property alias containsPress: _mouseArea.containsPress
    property alias hoverEnabled: _delegate.hoverEnabled
    property alias highlighted: _delegate.highlighted

    signal pressed(var mouse)
    signal pressAndHold(var mouse)
    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal doubleClicked(var mouse)

    property alias background : _delegate.background
    
    Drag.active: mouseArea.drag.active && control.draggable
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction   

    ItemDelegate
    {
        id: _delegate
        anchors.fill: parent

        highlighted: control.isCurrentItem
        //override the itemdelegate default signals to allow dragging content

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
                    drag.target = _mouseArea
                    control.grabToImage(function(result)
                    {
                        control.Drag.imageSource = result.url
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

        contentItem: Item{}
        
        Item
        {
            id: _content
            anchors
            {
                fill: parent
                topMargin: _delegate.topPadding
                bottomMargin: _delegate.bottomPadding
                leftMargin: _delegate.leftPadding
                rightMargin: _delegate.rightPadding
                margins: _delegate.padding
            }
        }
        
        background: Rectangle
        {
            opacity: 0.5
            anchors
            {
                fill: parent
                topMargin: _delegate.topPadding
                bottomMargin: _delegate.bottomPadding
                leftMargin: _delegate.leftPadding
                rightMargin: _delegate.rightPadding
                margins: _delegate.padding
            }

            Behavior on color
            {
                ColorAnimation
                {
                    duration: Kirigami.Units.shortDuration
                }
            }
            color: control.isCurrentItem || control.hovered || _mouseArea.containsPress ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : control.Kirigami.Theme.backgroundColor

            radius: control.radius
            border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"
        }
    }
}

