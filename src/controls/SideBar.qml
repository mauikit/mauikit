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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Maui.AbstractSideBar
{
    id: control
    default property alias content : _content.data

    implicitWidth: privateProperties.isCollapsed && collapsed && collapsible && stick ? collapsedSize : preferredWidth
    width: implicitWidth
    position: 1
    interactive: !stick && (modal || collapsed || !visible)
    
    property alias model : _listBrowser.model
    property alias count : _listBrowser.count
    
    property alias section : _listBrowser.section
    property alias currentIndex: _listBrowser.currentIndex
    
    property int iconSize : Maui.Style.iconSizes.small
    property bool showLabels: control.width > collapsedSize
    property bool stick : true
    
    property QtObject privateProperties : QtObject
    {
        property bool isCollapsed: control.collapsed
    }

    signal itemClicked(int index)
    signal itemRightClicked(int index)

    overlay.visible: stick ? (control.collapsed && control.collapsible && !privateProperties.isCollapsed) : (collapsed && position > 0 && visible)

    Connections
    {
        target: control.overlay
        onClicked: control.stick ? control.collapse() : control.close()
    }

    property Component delegate : Maui.ListDelegate
    {
        id: itemDelegate
        iconSize: control.iconSize
        labelVisible: control.showLabels
        label: model.label
        count: model.count > 0 ? model.count : ""
        iconName: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
        iconVisible: true
        leftPadding:  Maui.Style.space.tiny
        rightPadding:  Maui.Style.space.tiny

        Connections
        {
            target: itemDelegate
            onClicked:
            {
                control.currentIndex = index
                control.itemClicked(index)
            }

            onRightClicked:
            {
                control.currentIndex = index
                control.itemRightClicked(index)
            }

            onPressAndHold:
            {
                control.currentIndex = index
                control.itemRightClicked(index)
            }
        }
    }

//     onModalChanged: visible = true
    visible: true
    onStickChanged:
    {
        if(stick && collapsed)
        {
            control.collapse()
        }else
        {
            control.expand()
        }
    }

    onCollapsedChanged :
    {
        if(!collapsible)
        {
            return
        }

        if(!collapsed)
        {
            control.visible = true
            expand()
        }else
        {
            collapse()
        }
    }

    Behavior on width
    {
        id: _widthAnim

        NumberAnimation
        {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }


    ColumnLayout
    {
        id: _content
        anchors.fill: parent
        spacing: 0

        Maui.ListBrowser
        {
            id: _listBrowser
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: Maui.Style.space.tiny
            Layout.bottomMargin: Maui.Style.space.tiny
            Layout.margins: Maui.Style.unit
            listView.flickableDirection: Flickable.VerticalFlick

            verticalScrollBarPolicy:  Qt.ScrollBarAlwaysOff  //this make sthe app crash

            delegate: control.delegate
            Kirigami.Theme.inherit: true
            Kirigami.Theme.backgroundColor: "transparent"

            onKeyPress:
            {
                if(event.key == Qt.Key_Return)
                {
                    control.itemClicked(control.currentIndex)
                }
            }
        }

        MouseArea
        {
            id: _handle
            visible: control.collapsed && control.stick
            Layout.preferredHeight: Maui.Style.toolBarHeight
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
            property int startX
            property int startY

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: _handle.containsMouse || _handle.containsPress
            ToolTip.text: qsTr("Toogle SideBar")

            Rectangle
            {
                anchors.centerIn: parent
                radius: 2
                height: 18
                width: 16

                color: _handle.containsMouse || _handle.containsPress || !privateProperties.isCollapsed  ?  Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                border.color: Qt.darker(color, 1.2)

                Rectangle
                {
                    radius: 1
                    height: 10
                    width: 3

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 4

                    color: _handle.containsMouse || _handle.containsPress || !privateProperties.isCollapsed  ?  Kirigami.Theme.highlightedTextColor : Kirigami.Theme.backgroundColor
                }
            }

            onClicked:
            {
                if(privateProperties.isCollapsed)
                    control.expand()
                else control.collapse()
            }
        }
    }

    MouseArea
    {
        z: control.background.parent.z + 1
        preventStealing: true
        anchors.horizontalCenter: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: Maui.Handy.isTouch
        enabled: Maui.Handy.isTouch
        width: Maui.Style.space.large
        property int startX
        property int startY

        onPressed:
        {
            startY = mouse.y
            startX = mouse.x
            _widthAnim.enabled = false
        }

        onPositionChanged:
        {
            if (!pressed || !control.collapsible || !control.collapsed)
                return

            var value = control.width + (mouse.x-startX)
            control.width = value > control.preferredWidth ? control.preferredWidth : (value < control.collapsedSize ? collapsedSize : value)

        }

        onReleased:
        {
            _widthAnim.enabled = true
            if( privateProperties.isCollapsed)
            {
                if(control.width >= control.collapsedSize * 1.2)
                {
                    expand()

                } else
                {
                    collapse()
                }

            }else
            {
                if(control.width <= control.preferredWidth * 0.75)
                {
                    collapse()

                } else
                {
                    expand()
                }
            }
        }
    }

    function collapse()
    {
        if(collapsible)
        {
            privateProperties.isCollapsed  = true
            control.width = control.stick ? control.collapsedSize : control.preferredWidth
        }
    }

    function expand()
    {
        if(collapsible)
        {
            privateProperties.isCollapsed = false
            control.width = control.preferredWidth
        }
    }
}

