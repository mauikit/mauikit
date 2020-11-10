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

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

/**
 * ItemDelegate
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Kirigami.DelegateRecycler
{
    id: control

    /**
      * content :
      */
    default property alias content : _delegate.data

    /**
      * mouseArea :
      */
    property alias mouseArea : _mouseArea

    /**
      * draggable :
      */
    property bool draggable: false

    /**
      * isCurrentItem :
      */
    property bool isCurrentItem :  false

    /**
      * radius :
      */
    property int radius: Maui.Style.radiusV

    /**
      * padding :
      */
    property alias padding: _delegate.padding

    /**
      * leftPadding :
      */
    property alias leftPadding: _delegate.leftPadding

    /**
      * rightPadding :
      */
    property alias rightPadding: _delegate.rightPadding

    /**
      * topPadding :
      */
    property alias topPadding: _delegate.topPadding

    /**
      * bottomPadding :
      */
    property alias bottomPadding: _delegate.bottomPadding

    /**
      * hovered :
      */
    property alias hovered: _delegate.hovered

    /**
      * containsPress :
      */
    property alias containsPress: _mouseArea.containsPress

    /**
      * hoverEnabled :
      */
    property alias hoverEnabled: _delegate.hoverEnabled

    /**
      * background :
      */
    property alias background : _delegate.background

    /**
      * highlighted :
      */
    property bool highlighted: control.isCurrentItem

    /**
      * pressed :
      */
    signal pressed(var mouse)

    /**
      * pressAndHold :
      */
    signal pressAndHold(var mouse)

    /**
      * clicked :
      */
    signal clicked(var mouse)

    /**
      * rightClicked :
      */
    signal rightClicked(var mouse)

    /**
      * doubleClicked :
      */
    signal doubleClicked(var mouse)

    Drag.active: mouseArea.drag.active && control.draggable
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction

    Control
    {
        id: _delegate

        width: parent.width
        height: parent.height

        hoverEnabled: !Kirigami.Settings.isMobile

        padding: 0
        bottomPadding: padding
        rightPadding: padding
        leftPadding: padding
        topPadding: padding

        SequentialAnimation on y
        {
            id: xAnim
            // Animations on properties start running by default
            running: false
            loops: 2
            NumberAnimation { from: 0; to: -10; duration: 100; easing.type: Easing.InOutQuad }
            NumberAnimation { from: -10; to: 0; duration: 100; easing.type: Easing.InOutQuad }
            PauseAnimation { duration: 50 } // This puts a bit of time between the loop
        }

        MouseArea
        {
            id: _mouseArea
            //        enabled: !Kirigami.Settings.isMobile
            anchors.fill: parent
            acceptedButtons:  Qt.RightButton | Qt.LeftButton
            property bool pressAndHoldIgnored : false
            drag.axis: Drag.XAndYAxis

            //            drag.minimumY: control.height
            //            drag.minimumX : control.width

            onCanceled:
            {
                //                if(control.draggable)
                //                {
                //                    drag.target = null
                //                }
            }

            onClicked:
            {
                if(mouse.button === Qt.RightButton)
                {
                    control.rightClicked(mouse)
                }
                else
                {
                    control.clicked(mouse)
                }
            }

            onDoubleClicked:
            {
                control.doubleClicked(mouse)
            }

            onPressed:
            {
                if(control.draggable && mouse.source !== Qt.MouseEventSynthesizedByQt)
                {
                    drag.target = _mouseArea
                    control.grabToImage(function(result)
                    {
                        control.Drag.imageSource = result.url
                    })
                }else
                {
                    drag.target = null
                }

                control.pressed(mouse)
            }

            onReleased :
            {
                if(control.draggable)
                {
                    drag.target = null
                }

                if(pressAndHoldIgnored)
                {
                    control.pressAndHold(mouse)
                    pressAndHoldIgnored = false
                }
            }

            onPressAndHold :
            {
                if(control.draggable && mouse.source === Qt.MouseEventSynthesizedByQt && Maui.Handy.isTouch)
                {
                    drag.target = _mouseArea
                    xAnim.running = true
                    control.grabToImage(function(result)
                    {
                        control.Drag.imageSource = result.url
                    })
                    pressAndHoldIgnored = true
                }else
                {
                    drag.target = null
                    control.pressAndHold(mouse)
                }
            }
        }

        background: Rectangle
        {
            opacity: 1
            Behavior on color
            {
                ColorAnimation
                {
                    duration: Kirigami.Units.shortDuration
                }
            }
            color: control.isCurrentItem || control.hovered || _mouseArea.containsPress ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : "transparent"

            radius: control.radius
            border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.draggable ? Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9)) : "transparent"
        }
    }
}
