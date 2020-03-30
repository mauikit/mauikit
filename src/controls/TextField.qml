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
	property alias actions : _actions
	
	signal cleared()
    signal goBackTriggered();
    signal goFowardTriggered();	
    signal contentDropped(var drop)

//	bottomPadding: Maui.Style.space.tiny
	rightPadding: _actions.implicitWidth + Maui.Style.space.small
    selectByMouse: !Kirigami.Settings.isMobile
    persistentSelection: true
	focus: true
	wrapMode: TextInput.NoWrap	
	
    onPressAndHold: !Kirigami.Settings.isMobile ? entryMenu.popup() : undefined
	onPressed:
	{
		if(!Kirigami.Settings.isMobile && event.button === Qt.RightButton)
			entryMenu.popup()
	}
	
    Keys.onBackPressed:
    {
        goBackTriggered();
    }    
   	
	Shortcut
	{
		sequence: StandardKey.Quit
		context: Qt.ApplicationShortcut
		onActivated: control.clear()
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

    Row
    {
		id: _actions	
		z: parent.z + 1
		anchors.right: control.right
		anchors.verticalCenter: parent.verticalCenter
		
		ToolButton
		{
			id: clearButton
			visible: control.text.length			
			icon.name: "edit-clear"
			icon.color: control.color   
			onClicked: 
			{
				control.clear()
				cleared()            
			}
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
			text: qsTr("Select All")
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
	
	DropArea
	{
        anchors.fill: parent
        
        onDropped: 
        {
            console.log(drop.text, drop.html)
            if (drop.hasText) 
            {
                  control.text += drop.text
                
            }else if(drop.hasUrls)
            {
                control.text = drop.urls
            } 
            
            control.contentDropped(drop)
        }        
    }
}
