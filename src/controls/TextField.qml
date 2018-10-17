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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Controls.impl 2.3
import QtQuick.Controls.Material.impl 2.3
import org.kde.mauikit 1.0 as Maui
import "private"

TextField
{
	id: control    
	
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
	
	property alias menu : entryMenu
	signal cleared()
	
	implicitWidth: Math.max(background ? background.implicitWidth : 0,
							placeholderText ? placeholder.implicitWidth + leftPadding + rightPadding : 0)
	|| contentWidth + leftPadding + rightPadding
	implicitHeight:  iconSizes.big
	
	height: implicitHeight
	width: implicitWidth
	z: 1
	topPadding: space.tiny
	bottomPadding: space.tiny
	rightPadding: clearButton.width + space.small
	
	color: enabled ? colorScheme.textColor : Qt.lighter(colorScheme.textColor, 1.4)
	selectionColor: highlightColor
	selectedTextColor: highlightedTextColor
	persistentSelection: true
	
	verticalAlignment: TextInput.AlignVCenter
	horizontalAlignment: Text.AlignHCenter
	
	cursorDelegate: CursorDelegate { }
	
	selectByMouse: !isMobile
	focus: true
	wrapMode: TextEdit.Wrap
	
	onPressAndHold: entryMenu.popup()
	onPressed:
	{
		if(!isMobile && event.button === Qt.RightButton)
			entryMenu.popup()
	}
	
	Maui.ToolButton
	{
		id: clearButton
		visible: control.text.length
		anchors.top: control.top
		anchors.right: control.right
		anchors.rightMargin: space.small
		anchors.verticalCenter: parent.verticalCenter
		iconName: "edit-clear"
		iconColor: color   
		onClicked: {control.clear(); cleared()}
	}
	
	Label
	{
		id: placeholder
		x: control.leftPadding
		y: control.topPadding
		width: control.width - (control.leftPadding + control.rightPadding)
		height: control.height - (control.topPadding + control.bottomPadding)
		
		text: control.placeholderText
		font: control.font
		color: Qt.lighter(colorScheme.textColor, 1.4)
		opacity: 0.4
		horizontalAlignment: control.horizontalAlignment
		verticalAlignment: control.verticalAlignment
		visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
		elide: Text.ElideRight
	}
	
	
	background: Rectangle 
	{        
		implicitWidth: unit * 120
		implicitHeight: iconSizes.big
		color: control.activeFocus ? Qt.lighter(colorScheme.backgroundColor, 1.4)
		: (control.hovered ? Qt.lighter(colorScheme.backgroundColor, 1.3) : colorScheme.backgroundColor)
		border.color: colorScheme.borderColor
		radius: radiusV
		
	}
	
	Maui.Menu
	{
		id: entryMenu
		
		Maui.MenuItem
		{
			text: qsTr("Copy")
			onTriggered: Maui.Handy.copyToClipboard(control.selectedText)
			enabled: control.selectedText.length
		}
		
		Maui.MenuItem
		{
			text: qsTr("Cut")			
			onTriggered: Maui.Handy.copyToClipboard(control.selectedText)
			enabled: control.selectedText.length
		}
		
		Maui.MenuItem
		{
			text: qsTr("Paste")
			onTriggered:
			{
				var text = Maui.Handy.getClipboard()
				control.insert(control.cursorPosition, text)
			}
		}
		
		Maui.MenuItem
		{
			text: qsTr("Select all")
			onTriggered: control.selectAll()
			enabled: control.text.length
		}
		
		Maui.MenuItem
		{
			text: qsTr("Undo")
			onTriggered: control.undo()
			enabled: control.canUndo
		}
		
		Maui.MenuItem
		{
			text: qsTr("Redo")
			onTriggered: control.redo()
			enabled: control.canRedo
			
		}
	}
}
