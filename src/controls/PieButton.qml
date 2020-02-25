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

import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0


Item
{	
	id: control
	property int alignment : Qt.AlignLeft
	
	property int maxWidth :  ApplicationWindow.overlay.width - control.anchors.margins
	
	default property list<Action> actions

	property alias icon : _button.icon
	property alias text: _button.text
	property alias display: _button.display
	
	implicitWidth: _actionsBar.visible ? Math.min(maxWidth, height + _actionsBar.implicitWidth + Maui.Style.space.big) :  height
	
	Behavior on implicitWidth
	{		
		NumberAnimation
		{
			duration: Kirigami.Units.longDuration
			easing.type: Easing.InOutQuad
		}
	}	

	MouseArea
	{
		id: _overlay
		anchors.fill: parent
		parent: control.parent
		preventStealing: true
		propagateComposedEvents: true
		visible: _actionsBar.visible 
		opacity: visible ? 1 : 0
		
		Behavior on opacity
		{		
			NumberAnimation
			{
				duration: Kirigami.Units.longDuration
				easing.type: Easing.InOutQuad
			}
		}	
		Rectangle
		{
            color: Qt.rgba(control.Kirigami.Theme.backgroundColor.r,control.Kirigami.Theme.backgroundColor.g,control.Kirigami.Theme.backgroundColor.b, 0.5)
			anchors.fill: parent
		}
		
		onClicked: 
		{			
			control.close()
			mouse.accepted = false
		}
	}
	
	Rectangle
	{		
		id: _background
		visible: control.implicitWidth > height
		anchors.fill: parent
		color: control.Kirigami.Theme.backgroundColor
		radius: Maui.Style.radiusV
	}	
	
	DropShadow
	{
		visible: _actionsBar.visible
		anchors.fill: _background
		cached: true
		horizontalOffset: 0
		verticalOffset: 0
		radius: 8.0
		samples: 16
		color: "#333"
		opacity: 0.5
		smooth: true
		source: _background
	}	
	
	RowLayout
	{
		anchors.fill: parent
		
		Maui.ToolBar	
		{
			id: _actionsBar
			visible: false
			Layout.fillWidth: true
			Layout.fillHeight: true
			
			background: null
			
			middleContent: Repeater
			{
				model: control.actions
				
				ToolButton
				{
					Layout.fillHeight: true
					action: modelData
					display: ToolButton.TextUnderIcon
					onClicked: control.close()
				}
			}
		}	
		
		Maui.FloatingButton
		{
			id: _button	
			Layout.preferredWidth: control.height
			Layout.preferredHeight: control.height
			Layout.alignment:Qt.AlignRight
			
			onClicked: _actionsBar.visible = !_actionsBar.visible			
		}		
	}
	
	function open()
	{	
		_actionsBar.visible = true	
	}
	
	function close()
	{
		_actionsBar.visible = false
	}
}




