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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ItemDelegate
{
	id: control
	
	isCurrentItem : ListView.isCurrentItem
	
	default property alias content : _content.data
		
		property bool showQuickActions : true
		property list<Action> quickActions
		
		property bool collapse : width < Kirigami.Units.gridUnit * 26 || Kirigami.Settings.isMobile
		
		onCollapseChanged:
		{
			if(_swipeDelegate.swipe.position < 0)
				_swipeDelegate.swipe.close()
		}
		
		SwipeDelegate
		{
			id: _swipeDelegate
			anchors.fill: parent
			anchors.margins: 1
			hoverEnabled: true
			clip: true
			
			onClicked: control.clicked(null)
			onPressed: control.pressed(null)
			onDoubleClicked: control.doubleClicked(null)
			onPressAndHold: control.pressAndHold(null)
			
			swipe.enabled: control.collapse && control.showQuickActions
			padding: 0
			
			Rectangle
			{
				id: _bg
				anchors.fill: _swipeDelegate.background
				z: _swipeDelegate.background.z -1
				color: Kirigami.Theme.backgroundColor
				radius: Maui.Style.radiusV
				opacity: Math.abs( _swipeDelegate.swipe.position)
			}
			
			background: RowLayout
			{
				spacing: 0
				id: _background

//                transform: Translate {
//                           x: _swipeDelegate.swipe.position * control.width * 0.33
//                       }
				Item
				{
					id: _content
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				
				Row
				{
					id: _buttonsRow
					visible: hovered && control.showQuickActions && !control.collapse
					Layout.fillHeight: true
					Layout.preferredWidth: Math.max(Maui.Style.space.big, _buttonsRow.implicitWidth)
					Layout.alignment: Qt.AlignRight
					Layout.margins: Maui.Style.space.medium
					
					Behavior on Layout.preferredWidth
					{
						NumberAnimation
						{
							duration: Kirigami.Units.longDuration
							easing.type: Easing.InOutQuad
						}
					}
					
					spacing: Maui.Style.space.medium
					
					Repeater
					{
						model: !control.collapse &&  control.showQuickActions ? control.quickActions : undefined
						
						ToolButton
						{
							action: modelData
							anchors.verticalCenter: parent.verticalCenter
						}
					}
				}
				
				Item
				{
					visible: control.collapse && control.quickActions.length > 0 && control.showQuickActions
					Layout.fillHeight: true
					Layout.preferredWidth: Maui.Style.iconSizes.big + Maui.Style.space.small
					Layout.margins: Maui.Style.space.small
					
					ToolButton
					{
						anchors.centerIn: parent
						icon.name: "overflow-menu"
                        onClicked: _swipeDelegate.swipe.complete ? _swipeDelegate.swipe.close() : _swipeDelegate.swipe.open(SwipeDelegate.Right)
					}
				}				
			}			
			
			swipe.right: Row
			{
				id: _rowActions
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: Maui.Style.space.big
				padding: Maui.Style.space.medium
//                width:  implicitWidth * Math.abs(_swipeDelegate.swipe.position)
                height: parent.height

                opacity: Math.abs(_swipeDelegate.swipe.position) > 0.5 ? 1 : 0
//                Behavior on width
//                {
//                    NumberAnimation
//                    {
//                        duration: Kirigami.Units.longDuration
//                        easing.type: Easing.InOutQuad
//                    }
//                }

				Repeater
				{
					model: control.collapse && control.showQuickActions ? control.quickActions : undefined
					
					ToolButton
					{
						action: modelData
						anchors.verticalCenter: parent.verticalCenter
						onClicked: _swipeDelegate.swipe.close()
					}
				}
			}
		}
}
