import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
	id: control
	
	property Maui.FMList currentFMList : null
	property alias currentView : viewLoader.item
	property int viewType : Maui.FMList.LIST_VIEW
	
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
	
	Component
	{
		id: listViewBrowser
		
		
		Maui.ListBrowser
		{
			property alias currentFMList : _listViewFMList
			showPreviewThumbnails: modelList.preview
			keepEmblemOverlay: selectionMode
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "list-add"
			showDetailsInfo: true			
			
			Maui.FMList
			{
				id: _listViewFMList
				preview: true
				path: currentPath
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
			
			model: Maui.BaseModel
			{
				id: _browserModel
				list: _listViewFMList
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
			property alias currentFMList : _gridViewFMList
			itemSize : thumbnailsSize + fontSizes.default
			keepEmblemOverlay: selectionMode
			showPreviewThumbnails: modelList.preview
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "list-add"
			
			Maui.FMList
			{
				id: _gridViewFMList
				preview: true
				path: currentPath
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
			
			model: Maui.BaseModel
			{
				id: _browserModel
				list: _gridViewFMList
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
				
				orientation: ListView.Horizontal
				snapMode: ListView.SnapToItem
				
				onCurrentItemChanged: 
				{
					_millerControl.currentFMList = currentItem.currentFMList
					control.setCurrentFMList()				
				}
				highlightFollowsCurrentItem: true 
				
				Maui.PathList
				{
					id: _millerList
					path: currentPath
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
					
					ListView.onAdd: _millerColumns.positionViewAtEnd()
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
						preview: modelList.preview
						path: model.path
						foldersFirst: modelList.foldersFirst
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
						
						showPreviewThumbnails: modelList.preview
						keepEmblemOverlay: selectionMode
						rightEmblem: isMobile ? "document-share" : ""
						leftEmblem: "list-add"
						showDetailsInfo: true
						currentIndex : _millerControl.currentIndex						
						
						onItemClicked: 
						{
							_millerColumns.currentIndex = _index
							_millerControl.itemClicked(index)
							
							console.log(" ITEM CLICKED ", _index, index)
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
}
