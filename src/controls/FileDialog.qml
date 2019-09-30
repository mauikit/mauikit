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
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

Maui.Dialog
{
	id: control
	maxHeight: Kirigami.Settings.isMobile ? parent.height * 0.95 : Maui.Style.unit * 500
	maxWidth: Maui.Style.unit * 700
	page.padding: 0
	
	property string initPath
	property string suggestedFileName : ""
	
	property alias settings : browser.settings
	property bool searchBar : false
	
	readonly property var modes : ({OPEN: 0, SAVE: 1})
	property int mode : modes.OPEN
	
	property var callback : ({})
	
	property alias textField: _textField
	property alias singleSelection : browser.singleSelection
	
	
	rejectButton.visible: false
	acceptButton.text: control.mode === modes.SAVE ? qsTr("Save") : qsTr("Open")
	footBar.leftSretch: false
	footBar.middleContent: Maui.TextField
	{
		id: _textField
		visible: control.mode === modes.SAVE
		Layout.fillWidth: true
		placeholderText: qsTr("File name")
		text: suggestedFileName
	}
	
	onAccepted:  
	{									
		console.log("CURRENT PATHb", browser.currentPath+"/"+textField.text)
		if(control.mode === modes.SAVE && Maui.FM.fileExists(browser.currentPath+"/"+textField.text))
		{
			_confirmationDialog.open()
		}else
		{
			done()
		}
	}
	
	
	Maui.Dialog
	{
		id: _confirmationDialog
		
		acceptButton.text: qsTr("Accept")
		rejectButton.text: qsTr("Cancel")
		
		title: qsTr(textField.text+" already exists!")
		message: qsTr("If you are sure you want to replace the existing file click on Accept, otherwise click on cancel and change the name of the file to something different...")	
		
		onAccepted: control.done()
		onRejected: close()
	}
	
	Maui.Page
	{
		id: page
		anchors.fill: parent
		leftPadding: 0
		rightPadding: leftPadding
		topPadding: leftPadding
		bottomPadding: leftPadding
		headBar.implicitHeight: Maui.Style.toolBarHeight + Maui.Style.space.medium
		Component
		{
			id: _pathBarComponent
			
			Maui.PathBar
			{
				anchors.fill: parent
				//        colorScheme.backgroundColor: "#fff"
				//        colorScheme.textColor: "#333"
				//        colorScheme.borderColor: Qt.darker(headBarBGColor, 1.4)
				onPathChanged: browser.openFolder(path)
				url: browser.currentPath
				onHomeClicked: browser.openFolder(Maui.FM.homePath())
				onPlaceClicked: browser.openFolder(path)
			}
		}
		
		Component
		{
			id: _searchFieldComponent
			
			Maui.TextField
			{
				anchors.fill: parent
				placeholderText: qsTr("Search for files... ")
				onAccepted: browser.openFolder("search://"+text)
				//            onCleared: browser.goBack()
				onGoBackTriggered:
				{
					searchBar = false
					clear()
					//                browser.goBack()
				}
				
				background: Rectangle
				{
					border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
					radius: Maui.Style.radiusV
					color: Kirigami.Theme.backgroundColor
				}
			}
		}
		
		headBar.middleContent: Item
		{
			id: _pathBarLoader
			Layout.fillWidth: true
			Layout.margins: Maui.Style.space.medium
			height: Maui.Style.iconSizes.big
			Loader
			{
				anchors.fill: parent
				sourceComponent: searchBar ? _searchFieldComponent : _pathBarComponent
				
			}
		}
		
		headBar.rightContent: ToolButton
		{
			id: searchButton
			icon.name: "edit-find"
			onClicked: searchBar = !searchBar
			checked: searchBar
		}
		
		
		Kirigami.PageRow
		{
			id: pageRow
			anchors.fill: parent
			clip: true
			
			separatorVisible: wideMode
			initialPage: [sidebar, browser]
			defaultColumnWidth:  Kirigami.Units.gridUnit * (isMobile? 15 : 8)		
				
				Maui.PlacesListBrowser
				{
					id: sidebar	
					onPlaceClicked: 
					{
						pageRow.currentIndex = 1
						browser.openFolder(path)
					}
					
					list.groups: control.mode === modes.OPEN ? [
					Maui.FMList.PLACES_PATH,
					Maui.FMList.CLOUD_PATH,
					Maui.FMList.REMOTE_PATH,
					Maui.FMList.DRIVES_PATH,
					Maui.FMList.TAGS_PATH] : 
					[Maui.FMList.PLACES_PATH,
					Maui.FMList.REMOTE_PATH,                                                
					Maui.FMList.CLOUD_PATH,
					Maui.FMList.DRIVES_PATH]
				}
				
				
				Maui.FileBrowser
				{
					id: browser
					
					previewer.parent: ApplicationWindow.overlay
					selectionMode: control.mode === modes.OPEN
					
					onNewBookmark: 
					{
						for(var index in paths)
							sidebar.list.addPlace(paths[index])
					}
					
					onItemClicked: 
					{
						switch(control.mode)
						{	
							case modes.OPEN :
							{								
								openItem(index)
								break
							}
							case modes.SAVE:
							{
								if(Maui.FM.isDir(currentFMList.get(index).path))
									openItem(index)
									else
										textField.text = currentFMList.get(index).label
										break
							}				
						}
					}
					
					onCurrentPathChanged:
					{
						for(var i=0; i < sidebar.count; i++)
							if(currentPath === sidebar.list.get(i).path)
								sidebar.currentIndex = i
					}
				}			
		}
	}
	
	function show(cb)
	{
		if(cb)
			callback = cb			
			browser.openFolder(initPath ? initPath :browser.currentPath)
			open()
	}
	
	function closeIt()
	{
		browser.clean()
		close()
	}
	
	function done()
	{
		var paths = browser.selectionBar && browser.selectionBar.visible ? browser.selectionBar.selectedPaths : browser.currentPath
		
		if(control.mode === modes.SAVE)
		{
			if (typeof paths == 'string')
			{
				paths = paths + "/" + textField.text
			}else
			{
				for(var i in paths)
					paths[i] = paths[i] + "/" + textField.text
			}
		}
		
		if(callback)
			callback(paths)	
			
			control.closeIt()
	}
}
