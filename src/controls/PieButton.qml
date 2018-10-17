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

import QtQuick 2.6
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.0 as Kirigami
import "private"

Maui.ToolButton
{
	id: control
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
	
	property int alignment : Qt.AlignLeft
	
	property int barHeight : 0
	property int maxWidth :  ApplicationWindow.overlay.width *( isMobile ? 1 : 0.5)
	
	property alias content : content.middleContent
	
	onClicked: popup.visible ? close(): open()
	
	layer.enabled: true
	clip: true
		z: 1

	Popup
	{
		id: popup
		height: barHeight
		implicitWidth: content.middleLayout.implicitWidth + space.big + space.small
		width: implicitWidth > maxWidth ? maxWidth : (content.middleLayout.implicitWidth > ApplicationWindow.overlay.width ? ApplicationWindow.overlay.width  : implicitWidth)		
		padding: 0
		margins: 0
		x: alignment === Qt.AlignLeft ? (control.x - width) - space.big : (control.x + control.width) + space.big
		y:  parent.height / 2 - height / 2
		background: Rectangle
		{
			radius: radiusV
			color: colorScheme.backgroundColor
			border.color: colorScheme.borderColor		
		}
		
		onFocusChanged: !activeFocus || !focus ? close() : undefined
	
	enter: Transition 
	{
		// grow_fade_in
		NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
		NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
	}
	
	exit: Transition 
	{
		// shrink_fade_out
		NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
		NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
	}
	
		Maui.ToolBar
		{
			id: content
			anchors.fill: parent
			implicitHeight: parent.height
			spacing: space.enormous
			colorScheme.backgroundColor: "transparent"
			drawBorder: false
		}
	}
	
	function open()
	{	
		 popup.open()		
	}
	
	function close()
	{
		popup.close()
	}
}
