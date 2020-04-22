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
import QtQuick.Controls 2.9
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import QtQuick.Layouts 1.3

Maui.Dialog
{
	id: control
	maxHeight: Kirigami.Settings.isMobile ? parent.height * 0.95 : Maui.Style.unit * 500
	maxWidth: Maui.Style.unit * 700
	page.padding: 0
	
	property alias currentPath : browser.currentPath
	
	readonly property alias browser : browser
	readonly property alias selectionBar: _selectionBar
	
	property alias singleSelection : _selectionBar.singleSelection
	
	property string suggestedFileName : ""
	
	readonly property alias settings : browser.settings
	
	property bool searchBar : false
	onSearchBarChanged: if(!searchBar) browser.quitSearch()
	
	readonly property var modes : ({OPEN: 0, SAVE: 1})
	property int mode : modes.OPEN
	
	property var callback : ({})
	
	property alias textField: _textField
	
	signal urlsSelected(var urls)
	
	rejectButton.text: qsTr("Cancel")
	acceptButton.text: control.mode === modes.SAVE ? qsTr("Save") : qsTr("Open")

    footBar.visible: control.mode === modes.SAVE
    footBar.middleContent: Maui.TextField
	{
		id: _textField
		Layout.fillWidth: true
		placeholderText: qsTr("File name...")
		text: suggestedFileName
	}
	
	onRejected: control.close()
    
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
	
	Component
	{
		id: _pathBarComponent
		
		Maui.PathBar
		{
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
			placeholderText: qsTr("Search for files... ")
			onAccepted: browser.search(text)
			onCleared: browser.quitSearch()
			onGoBackTriggered:
			{
				searchBar = false
				clear()
			}
			
			background: Rectangle
			{
				border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
				radius: Maui.Style.radiusV
				color: Kirigami.Theme.backgroundColor
			}
		}
	}
	
	headBar.visible: true
	headBar.leftContent: ToolButton
	{
		icon.name: "application-menu"
		checked: pageRow.currentIndex === 0
		onClicked: pageRow.currentIndex = !pageRow.currentIndex
	}
	
	headBar.middleContent: Loader
	{            
        Layout.fillWidth: true
        Layout.preferredHeight: Maui.Style.iconSizes.big
        sourceComponent: searchBar ? _searchFieldComponent : _pathBarComponent
    }    
	
	headBar.rightContent: ToolButton
	{
		id: searchButton
		icon.name: "edit-find"
		onClicked: searchBar = !searchBar
		checked: searchBar
	}	
	
	Maui.Dialog
	{
		id: _confirmationDialog
		
		acceptButton.text: qsTr("Yes")
		rejectButton.text: qsTr("No")
		
		title: qsTr("A file named %1 already exists!").arg(textField.text)
		message: qsTr("This action will overwrite %1. Are you sure you want to do this?").arg(textField.text)	
		
		onAccepted: control.done()
		onRejected: close()
	}	
	
	Kirigami.PageRow
	{
        id: pageRow
        Layout.fillHeight: true
        Layout.fillWidth: true
        clip: true
        
        separatorVisible: wideMode
        initialPage: [sidebar, _browserLayout]
        defaultColumnWidth:  Kirigami.Units.gridUnit * (Kirigami.Settings.isMobile? 15 : 8)		
            
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
			
			ColumnLayout
			{
				id: _browserLayout
				spacing: 0
				
				Maui.Page
				{
					Layout.fillWidth: true
					Layout.fillHeight: true
					
					headBar.visible: true
					headBar.rightContent:[ Maui.ToolButtonMenu
					{
						icon.name: "view-sort"
						
						MenuItem
						{
							text: qsTr("Show Folders First")
							checked: browser.currentFMList.foldersFirst
							checkable: true
							onTriggered: browser.currentFMList.foldersFirst = !browser.currentFMList.foldersFirst
						}
						
						MenuSeparator {}
						
						MenuItem
						{
							text: qsTr("Type")
							checked: browser.currentFMList.sortBy === Maui.FMList.MIME
							checkable: true
							onTriggered: browser.currentFMList.sortBy = Maui.FMList.MIME
							autoExclusive: true
						}
						
						MenuItem
						{
							text: qsTr("Date")
							checked: browser.currentFMList.sortBy === Maui.FMList.DATE
							checkable: true
							onTriggered: browser.currentFMList.sortBy = Maui.FMList.DATE
							autoExclusive: true
						}
						
						MenuItem
						{
							text: qsTr("Modified")
							checkable: true
							checked: browser.currentFMList.sortBy === Maui.FMList.MODIFIED
							onTriggered: browser.currentFMList.sortBy = Maui.FMList.MODIFIED
							autoExclusive: true
						}
						
						MenuItem
						{
							text: qsTr("Size")
							checkable: true
							checked: browser.currentFMList.sortBy === Maui.FMList.SIZE
							onTriggered: browser.currentFMList.sortBy = Maui.FMList.SIZE
							autoExclusive: true
						}
						
						MenuItem
						{
							text: qsTr("Name")
							checkable: true
							checked: browser.currentFMList.sortBy === Maui.FMList.LABEL
							onTriggered: browser.currentFMList.sortBy = Maui.FMList.LABEL
							autoExclusive: true
						}
						
						MenuSeparator{}
						
						MenuItem
						{
							id: groupAction
							text: qsTr("Group")
							checkable: true
							checked: browser.settings.group
							onTriggered:
							{
								browser.settings.group = !browser.settings.group
							}
						}
					},
					
					ToolButton
					{
						id: _optionsButton
						icon.name: "overflow-menu"
                        enabled: browser.currentFMList.pathType !== Maui.FMList.TAGS_PATH && browser.currentFMList.pathType !== Maui.FMList.TRASH_PATH && browser.currentFMList.pathType !== Maui.FMList.APPS_PATH
						onClicked:
						{
							if(browser.browserMenu.visible)
								browser.browserMenu.close()
								else
									browser.browserMenu.show(_optionsButton, 0, height)
						}
						checked: browser.browserMenu.visible
						checkable: false
					}
					]
					
					headBar.leftContent: [
					Maui.ToolActions
					{
                        expanded: true
                        autoExclusive: false
                        checkable: false
                        
                        Action
                        {
                            icon.name: "go-previous"
                            onTriggered : browser.goBack()
                        }
                        
                        Action
                        {
                            icon.name: "go-next"
                            onTriggered: browser.goNext()
                        }
                    },                    
					
					Maui.ToolActions
					{
						id: _viewTypeGroup
						expanded: false
						currentIndex: browser.settings.viewType
						onCurrentIndexChanged: 
						{
							if(browser)
								browser.settings.viewType = currentIndex
								
								Maui.FM.saveSettings("VIEW_TYPE", currentIndex, "BROWSER")
						}
						
						Action
						{
							icon.name: "view-list-icons"
							text: qsTr("Grid")
							shortcut: "Ctrl+G"
						}
						
						Action
						{
							icon.name: "view-list-details"
							text: qsTr("List")
							shortcut: "Ctrl+L"
						}
						
						Action
						{
							icon.name: "view-file-columns"
							text: qsTr("Columns")
							shortcut: "Ctrl+M"
						}
					}					
					]
					
					Maui.FileBrowser
					{
						id: browser
						anchors.fill: parent				
						
						selectionBar: _selectionBar
						
						currentPath: Maui.FM.homePath()
						selectionMode: control.mode === modes.OPEN
						onItemClicked:
						{
							if(currentFMList.get(index).isdir == "true")
							{
								openItem(index)
							}
							
							switch(control.mode)
							{	
								case modes.OPEN :
								{	
									addToSelection(currentFMList.get(index))
									break
								}
								case modes.SAVE:
								{
									textField.text = currentFMList.get(index).label
									break
								}				
							}
						}
					
					onCurrentPathChanged:
					{                        
						sidebar.currentIndex = -1
						
						for(var i = 0; i < sidebar.count; i++)
						{
							if(String(browser.currentPath) === sidebar.list.get(i).path)
							{
								sidebar.currentIndex = i
								return;
							}
						}
					}					
				}	
				}				
				
				MauiLab.SelectionBar
				{
					id: _selectionBar
					Layout.alignment: Qt.AlignCenter
					onExitClicked: 
					{
						_selectionBar.clear()
					}					
				}
			}			
	}
	
	
	function show(cb)
    {
        if(cb)
        {
            callback = cb	
        }		
        open()
    }
	
	function closeIt()
	{
		browser.clearSelection()
		close()
	}
	
	function done()
    {
        var paths = browser.selectionBar && browser.selectionBar.visible ? browser.selectionBar.uris : [browser.currentPath]
        
        if(control.mode === modes.SAVE)
        {  
            for(var i in paths)
            {
                paths[i] = paths[i] + "/" + textField.text 
            }           
        }
        
        if(callback instanceof Function)
        {
            callback(paths)	
        }
        
        control.urlsSelected(paths)        
        control.closeIt()
	}
}
