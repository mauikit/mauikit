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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.GridView
{
	id: control
	
	itemSize : Maui.Style.iconSizes.large
    spacing: Kirigami.Settings.isMobile ? itemSize * 0.7 : itemSize * 0.8
	property bool showEmblem : true
	property bool keepEmblemOverlay : false
	property string rightEmblem
	property string leftEmblem
	
	centerContent: false
	adaptContent: true
	property bool showPreviewThumbnails: true
	
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)
	
	signal rightEmblemClicked(int index)
	signal leftEmblemClicked(int index)
	
	signal itemRightClicked(int index)
	
	cellWidth: itemSize + spacing
    cellHeight: itemSize + (spacing * 1.5)
	
	model: ListModel { id: gridModel  }
	
	delegate: Maui.IconDelegate
	{
		id: delegate
	
		isDetails: false
		width: control.cellWidth * 0.9
		height: control.cellHeight * 0.9
		folderSize : control.itemSize
		showTooltip: true
// 		draggable: !Kirigami.Settings.isMobile
		showEmblem: control.showEmblem
		keepEmblemOverlay: control.keepEmblemOverlay
		showThumbnails: control.showPreviewThumbnails
		rightEmblem: control.rightEmblem
		leftEmblem: control.leftEmblem
		
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
			
			onRightEmblemClicked:
			{
				control.currentIndex = index
				control.rightEmblemClicked(index)
			}
			
			onLeftEmblemClicked:
			{
				control.currentIndex = index
				control.leftEmblemClicked(index)
			}
		}
	}
}
