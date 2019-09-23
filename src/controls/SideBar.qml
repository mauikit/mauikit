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

Maui.ListBrowser
{
	id: control

	property int iconSize : Maui.Style.iconSizes.small
    property bool showLabels: true
    
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
        itemFgColor: Kirigami.Theme.textColor
        labelVisible: control.showLabels
//         radius: Maui.Style.radiusV
//         padding: Maui.Style.space.tiny 
        
        Connections
        {
            target: itemDelegate
            onClicked:
            {
                control.currentIndex = index
                itemClicked(index)
            }
            
            onRightClicked:
            {
				control.currentIndex = index
				itemRightClicked(index)
			}
			
			onPressAndHold:
			{
				control.currentIndex = index
				itemRightClicked(index)
			}
        }
    }
}
