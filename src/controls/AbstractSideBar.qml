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
import org.kde.mauikit 1.2 as Maui
import "private"

Maui.Page
{
    id: control
    visible: _layout.children.length > 0
    width: visible ? ( collapsed && collapsedSize > 0 ? collapsedSize : preferredWidth ): 0
    y: 0
    x: 0

    default property alias content : _layout.data
    property bool interactive: collapsed || !visible
    property int dragMargin: Maui.Style.space.big

    readonly property double position : (width + (x)) / width

    readonly property bool hidden : Math.round(position)

    readonly property bool isCollapsed : control.width === control.collapsedSize || collapsed

    property bool collapsible: false
    property bool collapsed: false
    property int collapsedSize: -1
    property int preferredWidth : Kirigami.Units.gridUnit * 12

    onCollapsedChanged: collapsed ? close() : open()
    
    signal contentDropped(var drop)

    headerBackground.color: "transparent"

    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: 0
    }

    Behavior on x
    {
//        enabled: false
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

    function close()
    {
//        if(control.collapsedSize < control.preferredWidth)
//        {
//            control.width = control.collapsedSize
//        } else
//        {
//            control.x = 0 - control.width
//        }
    }

    function open()
    {
//        control.width = control.preferredWidth
        control.x = 0
    }
}

