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
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Item
{
	id: control
	
	default property list<Action> actions
	property list<Action> hiddenActions
	
	property int currentIndex : -1
	readonly property int count : control.actions.length + control.hiddenActions.length
	
	signal clicked(int index)
	signal pressAndHold(int index)
	signal doubleClicked(int index)
	
	
	property Component delegate : ToolButton
	{
		anchors.verticalCenter: parent.verticalCenter
		action: modelData
		icon.width: Maui.Style.iconSizes.medium
		icon.height: Maui.Style.iconSizes.medium
		autoExclusive: true
		checkable: true
		checked: index == control.currentIndex
		display: control.currentIndex === index  ? ToolButton.TextBesideIcon : ToolButton.IconOnly
		
		Kirigami.Theme.backgroundColor: modelData.Kirigami.Theme.backgroundColor
		Kirigami.Theme.highlightColor: modelData.Kirigami.Theme.highlightColor
		
		Behavior on implicitWidth
		{		
			NumberAnimation
			{
				duration: Kirigami.Units.longDuration
				easing.type: Easing.InOutQuad
			}
		}
		
		onClicked: 
		{
			control.currentIndex = index
			control.clicked(index)
		}
		onPressAndHold: control.pressAndHold(index)
		onDoubleClicked: control.doubleClicked(index)
	}
	
	implicitHeight: parent.height
	implicitWidth: _layout.implicitWidth
	
	Behavior on implicitWidth
	{		
		NumberAnimation
		{
			duration: Kirigami.Units.longDuration
			easing.type: Easing.Linear
		}
	}
	
	Row
	{
		id: _layout
		height: parent.height
		spacing: Maui.Style.space.medium	
		
		Repeater
		{
			model: control.actions
			delegate: control.delegate			
		}
		
		ToolButton
		{
			id: _exposedHiddenActionButton
			visible: action
			action: control.currentIndex >= control.actions.length ? control.hiddenActions[control.currentIndex - control.actions.length] : null
			checkable: true
			checked: visible
			anchors.verticalCenter: parent.verticalCenter
			icon.width: Maui.Style.iconSizes.medium
			icon.height: Maui.Style.iconSizes.medium
			display: ToolButton.TextBesideIcon
			Behavior on implicitWidth
			{		
				NumberAnimation
				{
					duration: Kirigami.Units.longDuration
					easing.type: Easing.InOutQuad
				}
			}
		}
		
		
		ToolButton
		{
			id: _menuButton
			icon.name: "list-add"
			visible: control.hiddenActions.length > 0
			onClicked: 
			{
				if(_menu.visible)
					_menu.close()
					else
						_menu.popup(_menuButton, 0, _menuButton.height)
			}
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("More")		
			autoExclusive: false
			checkable: true
			checked: _menu.visible
			display: checked  ? ToolButton.TextBesideIcon : ToolButton.IconOnly
			Behavior on implicitWidth
			{		
				NumberAnimation
				{
					duration: Kirigami.Units.longDuration
					easing.type: Easing.InOutQuad
				}
			}
			Menu
			{
				id: _menu
				closePolicy: Popup.CloseOnReleaseOutsideParent
				Repeater
				{
					model: control.hiddenActions
					
					MenuItem
					{
						action: modelData
						checkable: true
						autoExclusive: true
						checked: control.currentIndex === control.actions.length + index
						
						onTriggered:
						{
							control.currentIndex = control.actions.length + index
							control.clicked(control.currentIndex)
						}
					}
				}
			}
		}
	}
}
