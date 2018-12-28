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
	signal openFile(string filePath)
	
	
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
		onDownloadReady:
		{
			notify("dialog-information", "Download ready...", item.label + " is ready to use.\nFile has been saved in your machine at:\n"+item.path, function()
			{
				Maui.FM.openUrl(item.path)
			})
		}
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
		onCleared: _storeList.query = ""
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
		
		onClicked: sortMenu.popup()
		
		Maui.Menu
		{
			id: sortMenu			
			Maui.MenuItem
			{
				text: qsTr("Title")
				checkable: true
				checked: _storeList.sortBy === StoreList.LABEL
				onTriggered: _storeList.sortBy = StoreList.LABEL
			}
			
			Maui.MenuItem
			{
				text: qsTr("Rating")
				checkable: true
				checked: _storeList.sortBy === StoreList.RATE
				onTriggered: _storeList.sortBy = StoreList.RATE
			}
			
			Maui.MenuItem
			{
				text: qsTr("Downloads")
				checkable: true
				checked: _storeList.sortBy === StoreList.COUNT
				onTriggered: _storeList.sortBy = StoreList.COUNT
			}
			
			Maui.MenuItem
			{
				text: qsTr("Newest")
				checkable: true
				checked: _storeList.sortBy === StoreList.DATE
				onTriggered: _storeList.sortBy = StoreList.DATE
			}			
		}
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
			fitImage: control.fitPreviews
			
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
	
	
	Maui.Drawer
	{
		id: _filterDrawer
		y: 0
// 		height: parent.height - footBar.implicitHeight - headBar.implicitHeight
		edge: Qt.RightEdge
		bg: control
// 		parent: control
		height: parent.height - (footBar.height)
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
		
		property var currentItem : ({})
		
		maxHeight: parent.height
		maxWidth: unit * 800
		page.margins: 0
		
		acceptButton.text: qsTr("Download")
		rejectButton.visible: false
	
		
		footBar.rightContent: Maui.Button
		{
			id: _openButton
			text: qsTr("Open...")
			onClicked: openFile(_storeList.itemLocalPath(layout.currentIndex))
		}
		
		footBar.leftContent: [
		
		
			Maui.ToolButton
			{
				id: _linkButton
				iconName: "view-links"
				onClicked: Maui.FM.openUrl(_previewerDialog.currentItem.source)
			}			
		]
		
		
		onAccepted:
		{
			_storeList.download(layout.currentIndex)
			_previewerDialog.close()
		}
		
		
		ColumnLayout
		{
			anchors.fill: parent
			spacing: 0
			
			ListView
			{
				id: _previewerList	
				Layout.fillWidth: true
				Layout.preferredHeight: parent.height * 0.5
				Layout.margins: 0
				
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
					
					
					background: Rectangle
					{
						
					}
					
					Image
					{
						clip: true
						anchors.top: parent.top
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						
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
							font.weight: Font.bold
							font.pointSize: fontSizes.big
						}
					}
								
				}
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.preferredHeight: rowHeight
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: _previewerDialog.currentItem.label
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				color: textColor
				font.bold: true
				font.weight: Font.bold
				font.pointSize: fontSizes.big				
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.preferredHeight: rowHeightAlt
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: _previewerDialog.currentItem.owner
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				color: textColor
				font.pointSize: fontSizes.small
				opacity: 0.5
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.leftMargin: space.big
				
				Layout.preferredHeight: rowHeightAlt
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Rating: ") + _previewerDialog.currentItem.rate
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: textColor
				font.pointSize: fontSizes.small		
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.leftMargin: space.big
				
				Layout.preferredHeight: rowHeightAlt
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Downloads: ") + _previewerDialog.currentItem.count
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: textColor
				font.pointSize: fontSizes.small				
			}
			
// 			Label
// 			{
// 				Layout.fillWidth: true
// 				Layout.leftMargin: space.big
// 				
// 				Layout.preferredHeight: rowHeightAlt
// 				wrapMode: Text.Wrap
// 				elide: Qt.ElideRight
// 				text: qsTr("License: ") + _previewerDialog.currentItem.license
// 				horizontalAlignment: Qt.AlignLeft
// 				verticalAlignment: Qt.AlignVCenter
// 				color: textColor
// 				font.pointSize: fontSizes.small				
// 			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.leftMargin: space.big
				
				Layout.preferredHeight: rowHeightAlt
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Date: ") + _previewerDialog.currentItem.date
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: textColor
				font.pointSize: fontSizes.small				
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.preferredHeight: rowHeightAlt
				Layout.leftMargin: space.big
				
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Tags: ") + _previewerDialog.currentItem.tag
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: textColor
				font.pointSize: fontSizes.small				
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: space.big
				text: _previewerDialog.currentItem.description
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: textColor
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				font.pointSize: fontSizes.default
			}
			
		}
		
		onOpened:
		{			
			_openButton.visible = _storeList.fileExists(layout.currentIndex)
			
			var item = _storeList.get(layout.currentIndex)	
			
			_previewerDialog.currentItem = item
			
			var list = [item.url, item.thumbnail, item.thumbnail_1, item.thumbnail_2 , item.thumbnail_3]
			_previewerModel.clear()
			
			for(var i in list)
				_previewerModel.append({thumbnail : list[i]})
		}
	}
}
