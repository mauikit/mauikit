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

	property alias menu : entryMenu
	signal cleared()
    signal goBackTriggered();
    signal goFowardTriggered();	
	
// 	height: implicitHeight
// 	width: implicitWidth
	z: 1
// 	topPadding: space.tiny
	bottomPadding: space.tiny
	rightPadding: clearButton.width + space.small
    selectByMouse: !isMobile
    persistentSelection: true
	focus: true
	wrapMode: TextInput.WordWrap
	
	
    onPressAndHold: !isMobile ? entryMenu.popup() : undefined
	onPressed:
	{
		if(!isMobile && event.button === Qt.RightButton)
			entryMenu.popup()
	}
	
    Keys.onBackPressed:
    {
        goBackTriggered();
        event.accepted = true
    }

    Shortcut
    {
        sequence: "Forward"
        onActivated: goFowardTriggered();
    }

    Shortcut
    {
        sequence: StandardKey.Forward
        onActivated: goFowardTriggered();
    }

    Shortcut
    {
        sequence: StandardKey.Back
        onActivated: goBackTriggered();
    }

	ToolButton
	{
		id: clearButton
		visible: control.text.length
		anchors.top: control.top
		anchors.right: control.right
		anchors.rightMargin: space.small
		anchors.verticalCenter: parent.verticalCenter
		icon.name: "edit-clear"
		icon.color: control.color   
		onClicked: 
		{
            control.clear()
            cleared()            
        }
	}
	
	Menu
	{
		id: entryMenu
		z: control.z +1
		
		MenuItem
		{
			text: qsTr("Copy")
			onTriggered: control.copy()
			enabled: control.selectedText.length
		}
		
		MenuItem
		{
			text: qsTr("Cut")			
			onTriggered: control.cut()
			enabled: control.selectedText.length
		}
		
		MenuItem
		{
			text: qsTr("Paste")
			onTriggered:
			{
				var text = control.paste()
				control.insert(control.cursorPosition, text)
			}
		}
		
		MenuItem
		{
			text: qsTr("Select all")
			onTriggered: control.selectAll()
			enabled: control.text.length
		}
		
		MenuItem
		{
			text: qsTr("Undo")
			onTriggered: control.undo()
			enabled: control.canUndo
		}
		
		MenuItem
		{
			text: qsTr("Redo")
			onTriggered: control.redo()
			enabled: control.canRedo
			
		}
	}
}
