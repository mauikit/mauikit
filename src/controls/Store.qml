import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick 2.9

import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

import StoreModel 1.0
import StoreList 1.0

import "private"


Maui.Page
{
	id: control
	/*props*/
	property int itemSize : isMobile ? iconSizes.huge * 1.5 : iconSizes.enormous
	property int itemSpacing: isMobile ? space.medium : space.big
	property int itemRadius : unit * 6
	property bool showLabels : true
	property bool fitPreviews : false
	property bool detailsView : false
	
	property alias holder: holder
	property alias list : _storeList
	property alias model: _storeModel
	
	property alias layout : _layoutLoader.item
	
	/*signals*/
	floatingBar: false
	footBarOverlap: false
	footBar.drawBorder: false
	headBar.drawBorder: false
	altToolBars: false
	headBarExit: false
	headBar.visible: !holder.visible
	margins: control.detailsView ?  0 : space.big
	
	StoreModel
	{
		id: _storeModel
		list: _storeList
	}
	
	StoreList
	{
		id: _storeList
		limit : 20
		category: StoreList.WALLPAPERS
	}
	
	footBar.middleContent: [
	Maui.ToolButton
	{
		id: _previousPageButton
		iconName: "go-previous"
		tooltipText: qsTr("Previous")
		enabled: _storeList.contentReady
		onClicked:
		{
			_storeList.page = _storeList.page === 0 ? 0 : _storeList.page-1
		}
	},
	
	Label
	{
		color: control.colorScheme.textColor
		text: _storeList.page
		font.bold: true
		font.weight: Font.Bold
		font.pointSize: fontSizes.big
		enabled: _storeList.contentReady
		
		anchors.verticalCenter: _previousPageButton.verticalCenter
	},
	
	Maui.ToolButton
	{
		id: _nextPageButton
		iconName: "go-next"
		tooltipText: qsTr("Next")
		enabled: _storeList.contentReady
		
		onClicked:
		{
			_storeList.page = _storeList.page+1
		}
	}
	]
	
	headBar.middleContent: Maui.TextField
	{
		width: headBar.middleLayout.width * 0.8
		placeholderText: qsTr("Search...")
		onAccepted: _storeList.query = text
	}
	
	footBar.rightContent: [
	Maui.ToolButton
	{
		id:_filterButton
		iconName: "view-filter"
		iconColor: _filterDrawer.visible ? colorScheme.highlightColor : colorScheme.textColor
		onClicked: _filterDrawer.visible ? _filterDrawer.close() : _filterDrawer.open()
	}
	]
	
	footBar.leftContent: [
	Maui.ToolButton
	{
		
		iconName: control.detailsView ? "view-list-icons" : "view-list-details"
		onClicked: control.detailsView = !control.detailsView
	}, 
	
	Maui.ToolButton
	{
		id:_sortButton
		iconName: "view-sort"
	}
	]
	
	
	Maui.Holder
	{
		id: holder
		visible: _storeList.contentEmpty
		
		emojiSize: iconSizes.huge
		emoji: if(!_storeList.contentReady)
		"qrc:/assets/animat-diamond-color.gif"
		else
			"qrc:/assets/ElectricPlug.png"
			
			isGif: !_storeList.contentReady
			isMask: false
			title : if(!_storeList.contentReady)
			qsTr("Loading content!")
			else
				qsTr("Nothing here")
				
				body: if(!_storeList.contentReady)
				qsTr("Almost ready!")
				else
					qsTr("Make sure you're online and your cloud account is working")
	}
	
	Component
	{
		id: gridDelegate
		
		StoreDelegate
		{
			id: delegate
			isDetails: control.detailsView
			showDetailsInfo: control.detailsView
			showLabel: control.showLabels
			height: control.detailsView ? control.itemSize * 0.5 : layout.cellHeight * 0.9
			width: control.detailsView ? control.width : layout.cellWidth * 0.9
			
			Connections
			{
				target: delegate
				
				onClicked:
				{
					layout.currentIndex = index
					_previewerDialog.open()
				}
			}
		}
	}
	
	Component
	{
		id: listViewBrowser
		
		Maui.ListBrowser
		{
			showEmblem: false
			leftEmblem: "list-add"
			showDetailsInfo: true
			model: _storeModel
			delegate: gridDelegate
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
			height: parent.height
			width: parent.width
			adaptContent: true
			itemSize: control.itemSize
			spacing: control.itemSpacing
			cellWidth: control.itemSize
			cellHeight: control.itemSize
			
			model: _storeModel
			delegate: gridDelegate
		}
	}
	
	Loader
	{
		id: _layoutLoader
		anchors.fill: parent
		sourceComponent: control.detailsView ? listViewBrowser : gridViewBrowser
	}
	
	
	Maui.Popup
	{
		id: _filterDrawer
		parent: control
		height: unit * 500
		width: 200
		x: _filterButton.x
		y: _filterButton.y
		ListView
		{
			id: _filterList
			anchors.fill: parent
			anchors.margins: space.medium
			model: ListModel{id: _filterModel}
			delegate: Maui.ListDelegate
			{
				id: delegate
				radius: radiusV
				
				Connections
				{
					target: delegate
					onClicked:
					{
						_filterList.currentIndex = index
					}
				}
			}
			
			focus: true
			interactive: true
			highlightFollowsCurrentItem: true
			highlightMoveDuration: 0
		}
	}
	
	Component.onCompleted:
	{
		var list = _storeList.getCategoryList()
		
		for(var i in list)
			_filterModel.append(list[i])		
	}
	
	
	Maui.Dialog
	{
		id: _previewerDialog
		maxHeight: unit * 500
		maxWidth: maxHeight
		
		ColumnLayout
		{
			anchors.fill: parent
			
			ListView
			{
				id: _previewerList
				
				
				
				Layout.fillWidth: true
				Layout.preferredHeight: parent.height * 0.5
				
				orientation: ListView.Horizontal
				clip: true
				focus: true
				interactive: true
// 				currentIndex: currentTrackIndex
				highlightFollowsCurrentItem: true
				highlightMoveDuration: 0
				snapMode: ListView.SnapOneItem
				
				model: ListModel
				{
					id: _previewerModel
				}
				
				delegate: ItemDelegate
				{					
					id: delegate
					
					height: _previewerList.height
					width: _previewerList.width
					
					Image
					{
						clip: true
					anchors.centerIn: parent
					source: model.thumbnail
					height: Math.min( parent.height, sourceSize.height)
					width: Math.min( parent.width, sourceSize.width)
// 					sourceSize.width: Math.min(width, sourceSize.width)
// 					sourceSize.height:  Math.min(height, sourceSize.height)
					horizontalAlignment: Qt.AlignHCenter
					verticalAlignment: Qt.AlignVCenter
					fillMode: Image.PreserveAspectCrop
					cache: false
					asynchronous: true		
					}
					
					Rectangle
					{
						height: iconSizes.medium
						width: height
						anchors
						{
							horizontalCenter: parent.horizontalCenter
							bottom: parent.bottom
							margins: space.big
						}
						
						color: viewBackgroundColor
						radius: Math.max(height, width)
						
						Label
						{
							anchors.fill: parent
							text: index
							horizontalAlignment: Qt.AlignHCenter
							verticalAlignment: Qt.AlignVCenter
							color: textColor
							font.bold: true
							font.weight: bold
							font.pointSize: fontSizes.big
						}
					}
								
				}
			}
		}
		
		onOpened:
		{
			var item = _storeList.get(layout.currentIndex)			
			var list = [item.url, item.thumbnail, item.thumbnail_1, item.thumbnail_2 , item.thumbnail_3]
			_previewerModel.clear()
			
			for(var i in list)
				_previewerModel.append({thumbnail : list[i]})
		}
	}
}
