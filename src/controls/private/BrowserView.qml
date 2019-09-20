import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
	id: control
	focus: true
	property url path
	property Maui.FMList currentFMList 
	
	property alias currentView : viewLoader.item
	property int viewType : Maui.FM.loadSettings("VIEW_TYPE", "BROWSER", Maui.FMList.LIST_VIEW)
	
	onViewTypeChanged: Maui.FM.saveSettings("VIEW_TYPE", viewType, "BROWSER")	
	
	height: _browserList.height
	width: _browserList.width
	
	function setCurrentFMList()
	{
		console.log("SETTING CURRENT FM LIST")
		control.currentFMList = currentView.currentFMList	
	}
	
	Loader
	{
		id: viewLoader
		anchors.fill: parent
		sourceComponent: switch(control.viewType)
		{
			case Maui.FMList.ICON_VIEW: return gridViewBrowser
			case Maui.FMList.LIST_VIEW: return listViewBrowser
			case Maui.FMList.MILLERS_VIEW: return millerViewBrowser
		}	
		
		onLoaded: setCurrentFMList()
	}
	
	Maui.FMList
	{
		id: _commonFMList
		preview: true
		path: control.path
		foldersFirst: true
		onSortByChanged: if(group) groupBy()
		onContentReadyChanged: console.log("CONTENT READY?", contentReady)
		onWarning:
		{			
			notify("dialog-information", "An error happened", message)
		}
		
		onProgress:
		{
			if(percent === 100)
				_progressBar.value = 0
				else
					_progressBar.value = percent/100
		}
	}
	
	Component
	{
		id: listViewBrowser		
		
		Maui.ListBrowser
		{
			property alias currentFMList : _browserModel.list
			showPreviewThumbnails: _listViewFMList.preview
			keepEmblemOverlay: selectionMode
			leftEmblem: "list-add"
			showDetailsInfo: true
		
			model: Maui.BaseModel
			{
				id: _browserModel
				list: _commonFMList
			}
			
			section.delegate: Maui.LabelDelegate
			{
				id: delegate
				label: section
				labelTxt.font.pointSize: fontSizes.big
				
				isSection: true
				boldLabel: true
				height: toolBarHeightAlt
			}
		}
	}
	
	Component
	{
		id: gridViewBrowser
		
		Maui.GridBrowser
		{
			property alias currentFMList : _browserModel.list
			itemSize : thumbnailsSize + fontSizes.default
			keepEmblemOverlay: selectionMode
			showPreviewThumbnails: _gridViewFMList.preview
			leftEmblem: "list-add"			
			model: Maui.BaseModel
			{
				id: _browserModel
				list: _commonFMList
			}
		}
	}
	
	Component
	{
		id: millerViewBrowser
		
		Item
		{
			id: _millerControl			
			property Maui.FMList currentFMList
			property int currentIndex
			
			signal itemClicked(int index)
			signal itemDoubleClicked(int index)
			signal itemRightClicked(int index)
			
			signal rightEmblemClicked(int index)
			signal leftEmblemClicked(int index)
			
			signal areaClicked(var mouse)
			signal areaRightClicked()	
			
			ListView
			{
				id: _millerColumns
				anchors.fill: parent
				
				boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
				
				keyNavigationEnabled: true
				interactive: Kirigami.Settings.isMobile
				highlightFollowsCurrentItem: true
				
				orientation: ListView.Horizontal
				snapMode: ListView.SnapToItem
				
				ScrollBar.horizontal: ScrollBar { }
				
				onCurrentItemChanged: 
				{
					_millerControl.currentFMList = currentItem.currentFMList
					control.setCurrentFMList()				
				}
				
				onCurrentIndexChanged: positionViewAtEnd()
				
				Maui.PathList
				{
					id: _millerList
					path: control.path
				}
				
				model: Maui.BaseModel
				{
					id: _millerModel
					list: _millerList
				}				
				
				delegate: ItemDelegate
				{
					property alias currentFMList : _millersFMList
					property int _index : index
					
					width: Math.min(Kirigami.Units.gridUnit * 22, control.width)
					height: parent.height
					
					background: Rectangle
					{
						color: "transparent"
					}
					
					ListView.onAdd: _millerColumns.currentIndex = _millerColumns.count-1	
					
					Kirigami.Separator
					{
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						anchors.right: parent.right
						width: 1	
						z: 999
					}
					
					Maui.FMList
					{	
						id: _millersFMList
						preview: true
						path: model.path
						foldersFirst: true
						onWarning:
						{			
							notify("dialog-information", "An error happened", message)
						}
						
						onProgress:
						{
							if(percent === 100)
								_progressBar.value = 0
								else
									_progressBar.value = percent/100
						}
					}
					
					Maui.ListBrowser
					{
						id: _millerListView
						anchors.fill: parent
						
						showPreviewThumbnails: _millersFMList.preview
						keepEmblemOverlay: selectionMode
						rightEmblem: isMobile ? "document-share" : ""
						leftEmblem: "list-add"
						showDetailsInfo: true
						currentIndex : _millerControl.currentIndex						
						
						onItemClicked: 
						{
							_millerColumns.currentIndex = _index
							_millerControl.itemClicked(index)							
						}
						
						onItemDoubleClicked: 
						{
							_millerColumns.currentIndex = _index
							_millerControl.itemDoubleClicked(index)
						}
						
						onItemRightClicked: 
						{
							_millerColumns.currentIndex = _index
							_millerControl.itemRightClicked(index)
						}
						
						onRightEmblemClicked:
						{
							_millerColumns.currentIndex = _index
							_millerControl.rightEmblemClicked(index)
						}
						
						onLeftEmblemClicked: 
						{
							_millerColumns.currentIndex = _index
							_millerControl.leftEmblemClicked(index)
						}
						
						onAreaClicked:
						{
							_millerColumns.currentIndex = _index
							_millerControl.areaClicked(mouse)
						}
						
						onAreaRightClicked:
						{
							_millerColumns.currentIndex = _index
							_millerControl.areaRightClicked()							
						}
						
						model: Maui.BaseModel
						{							
							list: _millersFMList
						}
						
						section.delegate: Maui.LabelDelegate
						{
							id: delegate
							label: section
							labelTxt.font.pointSize: fontSizes.big
							
							isSection: true
							boldLabel: true
							height: toolBarHeightAlt
						}
					}
				}				
			}			
		}
	}
	
	
	
	Maui.Holder
	{
		id: holder
		anchors.fill : parent
		z: -1
		visible: !control.currentFMList.pathExists || control.currentFMList.pathEmpty || !control.currentFMList.contentReady
		emoji: 
		{
			if(control.currentFMList.pathExists && control.currentFMList.pathEmpty)
				"qrc:/assets/folder-add.svg" 
				else if(!control.currentFMList.pathExists)
					"qrc:/assets/dialog-information.svg"
					else if(!control.currentFMList.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
						"qrc:/assets/edit-find.svg"
						else if(!control.currentFMList.contentReady)
							"qrc:/assets/view-refresh.svg"
		}
		
		//                     isGif: !control.currentFMList.contentReady			
		//                     isMask: false
		title :
		{
			if(control.currentFMList.pathExists && control.currentFMList.pathEmpty)
				qsTr("Folder is empty!")
				else if(!control.currentFMList.pathExists)
					qsTr("Folder doesn't exists!")
					else if(!control.currentFMList.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
						qsTr("Searching for content!")
						else if(!control.currentFMList.contentReady)
							qsTr("Loading content!")					
							
		}
		
		body:
		{
			if(control.currentFMList.pathExists && control.currentFMList.pathEmpty)
				qsTr("You can add new files to it")
				else if(!control.currentFMList.pathExists)
					qsTr("Create Folder?")
					else if(!control.currentFMList.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
						qsTr("This might take a while!")
						else if(!control.currentFMList.contentReady)
							qsTr("Almost ready!")	
		}
		
		emojiSize: Maui.Style.iconSizes.huge
		
		onActionTriggered:
		{
			if(!control.currentFMList.pathExists)
			{
				Maui.FM.createDir(control.path.slice(0, control.path.lastIndexOf("/")), control.path.split("/").pop())
				openFolder(control.currentFMList.parentPath)				
			}
		}
	}
	
	
	
}
