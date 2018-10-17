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
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

ListView
{
	id: control
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/

	property color bgColor: isCollapsed ? colorScheme.altColor : colorScheme.backgroundColor
	property color fgColor : isCollapsed ? colorScheme.altColorText : colorScheme.textColor
    property string downloadBadget : ""

    property int iconSize : isMobile ? (isCollapsed || isWide ? iconSizes.medium : iconSizes.big) :
                                       iconSizes.small
    property bool collapsable : true
    property bool isCollapsed : false

    signal itemClicked(var item)

    keyNavigationEnabled: true
    clip: true
    focus: true
    interactive: true
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0
    snapMode: ListView.SnapToItem
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds


    Rectangle
    {
        anchors.fill: parent
        z: -1
        color: bgColor
    }

    model: ListModel {}

    delegate: SideBarDelegate
    {
        id: itemDelegate
        sidebarIconSize: iconSize
        labelsVisible: !isCollapsed
        itemFgColor: fgColor

        Connections
        {
            target: itemDelegate
            onClicked:
            {
                control.currentIndex = index
                itemClicked(control.model.get(index))
            }
        }
    }
}
