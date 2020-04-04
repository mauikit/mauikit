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
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.GridView
{
	id: control
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	
	itemSize : Maui.Style.iconSizes.large * 2	
	adaptContent: true
	
	property bool showPreviewThumbnails: true
	property bool checkable : false
	
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)	
	signal itemToggled(int index, bool state)	
	signal itemRightClicked(int index)	
	
	delegate: Item
	{
		property bool isCurrentItem : GridView.isCurrentItem
		height: control.cellHeight
		width: control.cellWidth
		
		Maui.GridBrowserDelegate
		{
			id: delegate
			
			iconSizeHint: height * 0.5
			
			anchors.centerIn: parent
			height: control.cellHeight - 5
			width: control.itemSize
			padding: Maui.Style.space.tiny
			isCurrentItem: parent.isCurrentItem
			
			checkable: control.checkable
			showThumbnails: control.showPreviewThumbnails
			
			Connections
			{
				target: delegate
				onClicked:
				{
					control.currentIndex = index
					itemClicked(index)
				}
				
				onDoubleClicked:
				{
					control.currentIndex = index
					itemDoubleClicked(index)
				}
				
				onPressAndHold:
				{
					control.currentIndex = index
					control.itemRightClicked(index)
				}
				
				onRightClicked:
				{
					control.currentIndex = index
					control.itemRightClicked(index)
				}
				
				onToggled:
				{
					control.currentIndex = index
					control.itemToggled(index, state)
				}
			}
		}
	}
}
