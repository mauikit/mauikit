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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"


Drawer
{
    id: control

    position: Qt.Left
    implicitHeight: ApplicationWindow.height - ApplicationWindow.header.height - ApplicationWindow.footer.height
    height: ApplicationWindow.height - ApplicationWindow.header.height - ApplicationWindow.footer.height
    y: ApplicationWindow.header.height

    //     ApplicationWindow.height -ApplicationWindow.header.height - ApplicationWindow.footer.height
    implicitWidth: privateProperties.isCollapsed && collapsed && collapsible  ? collapsedSize : preferredWidth
    visible: true
    modal: false
    interactive: Kirigami.Settings.isMobile && modal && !collapsible && !collapsed
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnReleaseOutside

    onModalChanged: visible = true

    default property alias content : _content.data

    property alias hovered : _mouseArea.containsMouse
    property alias model : _listBrowser.model
    property alias section : _listBrowser.section
    property alias currentIndex: _listBrowser.currentIndex

    property int iconSize : Maui.Style.iconSizes.small
    property bool showLabels: !collapsed  || !privateProperties.isCollapsed

    property bool collapsible: false

    property bool collapsed: false

    property int collapsedSize: Maui.Style.iconSizes.medium + (Maui.Style.space.medium*4)
    property int preferredWidth : Kirigami.Units.gridUnit * 12

    property QtObject privateProperties : QtObject
    {
        property bool isCollapsed: control.collapsed
    }

    signal itemClicked(int index)
    signal itemRightClicked(int index)

    onCollapsedChanged :
    {
        if(!collapsed && modal)
        {
            modal = false
        }

        if(!modal && !collapsed)
        {
            privateProperties.isCollapsed = true
        }
    }

    contentItem: Item
    {
        id: _content
        anchors.fill: parent
        anchors.topMargin: Maui.Style.space.tiny
        anchors.bottomMargin: Maui.Style.space.tiny

        data: Maui.ListBrowser
        {
            id: _listBrowser
            anchors.fill: parent
            Rectangle
            {
                anchors.fill: parent
                z: -1
                color: Kirigami.Theme.backgroundColor
            }

            delegate: Maui.ListDelegate
            {
                id: itemDelegate
                iconSize: control.iconSize
                labelVisible: control.showLabels

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
        }
    }

    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: Kirigami.Settings.isMobile ? false : true
        propagateComposedEvents: true
        preventStealing: true
        parent: control.contentItem.parent

        onEntered:
        {
            if(Kirigami.Settings.isMobile)
            {
                return;
            }

            if(containsMouse && privateProperties.isCollapsed && collapsed && collapsible && !modal)
            {
                expand()
            }

            console.log("ENTERED", control.z)
        }

        onExited:
        {
            if(Kirigami.Settings.isMobile)
                return

            if(!privateProperties.isCollapsed  && collapsible  && collapsed  && modal)
            {
                collapse()
            }
            console.log("EXITED", control.z)
        }

        onPositionChanged:
        {
            if (!pressed)
                return

            if(control.collapsed && Kirigami.Settings.isMobile)
            {
                if(mouse.x > (control.collapsedSize*2))
                {
                    expand()

                }else if((mouse.x*2) < control.collapsedSize)
                {
                   collapse()
                }
            }
        }
    }

    function collapse()
    {
        if(collapsible)
        {
            modal = false
            privateProperties.isCollapsed  = true
        }
    }

    function expand()
    {
        if(collapsible)
        {
            modal = true
            privateProperties.isCollapsed = false
        }
    }
}

