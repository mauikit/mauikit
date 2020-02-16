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

Drawer
{
    id: control

    edge: Qt.LeftEdge
    implicitHeight: parent.height - (ApplicationWindow.header ? ApplicationWindow.header.height : 0) - (ApplicationWindow.footer ? ApplicationWindow.footer.height : 0)
    height: implicitHeight
    y: (ApplicationWindow.header ? ApplicationWindow.header.height : 0)
    closePolicy: modal ?  Popup.CloseOnEscape | Popup.CloseOnPressOutside : Popup.NoAutoClose
    interactive: modal
    property bool collapsible: false
    property bool collapsed: false
    property int collapsedSize: 0
    property int preferredWidth : Kirigami.Units.gridUnit * 12
    property alias overlay : _overlay

    onCollapsedChanged: position = collapsed && collapsedSize < 1 ? 0 : 1

    signal contentDropped(var drop)

    MouseArea
    {
        id: _overlay
        anchors.fill: parent
        anchors.margins: 0
        anchors.leftMargin: (control.width * control.position)
        parent: ApplicationWindow.contentItem
        preventStealing: true
        propagateComposedEvents: false
        visible: false
        Rectangle
        {
            color: control.Kirigami.Theme.backgroundColor
            opacity: 0.7 * control.position
            anchors.fill: parent
        }
    }

    //	onVisibleChanged:
    //	{
    //		if(control.visible && !control.modal)
    //			control.position = 1
    //	}

    Component.onCompleted:
    {
        if(!control.collapsed)
        {
            control.visible = true;
            control.position = 1;
        }
    }

    Behavior on position
    {
        enabled: control.collapsible && control.position === 1

        NumberAnimation
        {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    opacity: _dropArea.containsDrag ? 0.5 : 1

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            control.contentDropped(drop)
        }
    }
}

