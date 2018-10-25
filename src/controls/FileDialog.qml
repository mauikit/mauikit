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
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import FMList 1.0 

Maui.Dialog
{
	id: control
	maxHeight: unit * 500
	maxWidth: unit * 700
	page.margins: 0
	defaultButtons: false
		
	property string initPath
	
	property var filters: []
	property bool onlyDirs : false
	property int sortBy: FMList.MODIFIED
	
	property bool multipleSelection: false
	
	property bool saveDialog : false
	property bool openDialog : true
	
	property var callback : ({})
	
	signal placeClicked (string path)
	signal selectionReady(var paths)
	
	
	Maui.Page
	{
		id: page
		anchors.fill: parent
		leftPadding: 0
		margins: 0
		rightPadding: leftPadding
		topPadding: leftPadding
		bottomPadding: leftPadding
		headBarExit: false
		
		headBarTitleVisible: false
		headBar.height: headBar.implicitHeight * 1.1
		
		headBar.middleContent: Maui.PathBar
		{
			id: pathBar
			height: iconSizes.big
			width: page.headBar.middleLayout.width * 0.9
			url: browser.currentPath
			onPathChanged: browser.openFolder(path)
			onHomeClicked:
			{
				if(pageRow.currentIndex !== 0 && !pageRow.wideMode)
					pageRow.currentIndex = 0
					
					browser.openFolder(Maui.FM.homePath())
			}
			
			onPlaceClicked: browser.openFolder(path)
		}
	
		
		Kirigami.PageRow
		{
			id: pageRow
			anchors.fill: parent
			clip: true
			
			property int sidebarWidth: sidebar.isCollapsed ? sidebar.iconSize * 2 :
			Kirigami.Units.gridUnit * (isMobile? 15 : 8)
			
			separatorVisible: wideMode
			initialPage: [sidebar, content]
			defaultColumnWidth: sidebarWidth
				interactive: currentIndex === 1
				
				Maui.SideBar
				{
					id: sidebar
					focus: true
					width: isCollapsed ? iconSize*2 : parent.width
					height: parent.height
					section.property :  !sidebar.isCollapsed ? "type" : ""
					section.criteria: ViewSection.FullString
					
					section.delegate: Maui.LabelDelegate
					{
						id: delegate
						label: section
						labelTxt.font.pointSize: fontSizes.big
						
						isSection: true
						boldLabel: true
						height: toolBarHeightAlt
					}
					
					onItemClicked:
					{
						browser.openFolder(item.path)
						placeClicked(item.path)
						
						if(pageRow.currentIndex === 0 && !pageRow.wideMode)
							pageRow.currentIndex = 1
					}
					
					function populate()
					{
						sidebar.model.clear()
						var places = Maui.FM.getDefaultPaths()
						places.push(Maui.FM.getBookmarks())
						places.push(Maui.FM.getDevices())
						
						if(places.length > 0)
							for(var i in places)
							{	
								console.log("SIODEBARPLACE: ", places[i].label)
								sidebar.model.append(places[i])
								
							}
					}
				}
				
				ColumnLayout
				{
					id: content
					
					Maui.FileBrowser
					{
						id: browser
						Layout.fillWidth: true
						Layout.fillHeight: true
						
						previewer.parent: ApplicationWindow.overlay
						
						selectionMode: control.openDialog && control.multipleSelection
						list.onlyDirs: control.onlyDirs
						list.filters: control.filters
						list.sortBy: control.sortBy
						
						onItemClicked: 
						{
							if(control.openDialog && !control.multipleSelection)
								callback([list.get(index).path])
								
							openItem(index)
						}
					}
					
					Maui.ToolBar
					{
						id: _bottomBar
						position: ToolBar.Footer
						drawBorder: true
						Layout.fillWidth: true
						leftContent: TextField
						{
							visible: saveDialog							
							width: _bottomBar.middleLayout.width * 0.9
							placeholderText: qsTr("File name")
						}
						
						rightContent: Row
						{
							spacing: space.big
							Maui.Button
							{
								id: _rejectButton
								colorScheme.textColor: dangerColor
								colorScheme.borderColor: dangerColor
								colorScheme.backgroundColor: "transparent"
								
								text: rejectText
								onClicked: control.closeIt()
								
							}
							
							Maui.Button
							{
								id: _acceptButton			
								colorScheme.backgroundColor: infoColor
								colorScheme.textColor: "white"
								text: acceptText
								onClicked: control.callback(browser.selectionBar.selectedPaths)
							}
						} 
					}
				}
		}
	}
	
	function show(cb)
	{
		callback = cb
		sidebar.populate()
		
		if(initPath)
			browser.openFolder(initPath)
			else
				browser.openFolder(browser.currentPath)
				
				open()
	}
	
	function closeIt()
	{
		browser.clearSelection()
		close()
	}
	
}
