/*
 *   Copyright 2020 Camilo Higuita <milo.h@aol.com>
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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtQuick.Layouts 1.3

SwipeView
{
	id: control
	interactive: true
	clip: true
	property int maxViews : 4
	property Maui.ToolBar toolbar : window().headBar
	property alias actions : _actionGroup.actions
	property alias hiddenAction : _actionGroup.hiddenActions
	
	readonly property int index : -1
	
	readonly property QtObject actionGroup : Maui.ActionGroup
	{
		id: _actionGroup	
		currentIndex : control.currentIndex
		onCurrentIndexChanged: control.currentIndex = currentIndex		
		Component.onCompleted:
		{
			control.toolbar.middleContent.push(_actionGroup)
		}
	}	
	
	currentIndex: _actionGroup.currentIndex
	onCurrentIndexChanged: _actionGroup.currentIndex = currentIndex	
	
	onCurrentItemChanged: currentItem.forceActiveFocus()
	
	contentItem: ListView
	{
		model: control.contentModel
		interactive: control.interactive
		currentIndex: control.currentIndex
		spacing: control.spacing
		orientation: control.orientation
		snapMode: ListView.SnapOneItem
		boundsBehavior: Flickable.StopAtBounds
		
		highlightRangeMode: ListView.StrictlyEnforceRange
		preferredHighlightBegin: 0
		highlightMoveDuration: 0
		
		highlightResizeDuration: 0		
		
		preferredHighlightEnd: width
// 		highlight: Item {}
		highlightMoveVelocity: -1
		highlightResizeVelocity: -1
		
// 		resize
		maximumFlickVelocity: 4 * (control.orientation === Qt.Horizontal ? width : height)	
	}
	
	Component.onCompleted:
	{
		control.toolbar.middleContent.push(control.actionGroup)
		for(var i in control.contentChildren)
		{
			const obj = control.contentChildren[i]
			
			if(obj.hasOwnProperty("action"))
			{
				if(control.actions.length < control.maxViews)
				{
					control.actions.push(obj.action)
				}else
				{
					control.hiddenAction.push(obj.action)					
				}
			}
		}
	}
}
