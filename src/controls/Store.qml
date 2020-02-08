import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick 2.9

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import StoreModel 1.0
import StoreList 1.0

import "private"


Maui.Page
{
	id: control
	/*props*/
	property int itemSize : Kirigami.Settings.isMobile ? Maui.Style.iconSizes.huge * 1.5 : Maui.Style.iconSizes.enormous
	property int itemSpacing: Kirigami.Settings.isMobile ? Maui.Style.space.medium : Maui.Style.space.big
	property int itemRadius : Maui.Style.unit * 6
	property bool showLabels : true
	property bool fitPreviews : false
	property bool detailsView : false
	
	property alias holder: holder
	property alias list : _storeList
	property alias model: _storeModel
	
	property alias layout : _layoutLoader.item
	
	/*signals*/
	signal openFile(string filePath)
	signal fileReady(var item)
	
	headBar.visible: !holder.visible
	padding: control.detailsView ?  0 : Maui.Style.space.big
	
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
			notify("dialog-information", "Download ready...", qsTr("%1 is ready to use.\nFile has been saved in your machine at:\n %2", item.label, item.path), function()
			{
				openFile(item.path)
			})
			
			fileReady(item)
		}
	}
	
	footBar.middleContent: [
	ToolButton
	{
		id: _previousPageButton
		icon.name: "go-previous"
		text: qsTr("Previous")
		enabled: _storeList.contentReady
		onClicked:
		{
			_storeList.page = _storeList.page === 0 ? 0 : _storeList.page-1
		}
	},
	
	Label
	{
		color: Kirigami.Theme.textColor
		text: _storeList.page
		font.bold: true
		font.weight: Font.Bold
		font.pointSize: Maui.Style.fontSizes.big
		enabled: _storeList.contentReady
		
		anchors.verticalCenter: _previousPageButton.verticalCenter
	},
	
	ToolButton
	{
		id: _nextPageButton
		icon.name: "go-next"
		text: qsTr("Next")
		enabled: _storeList.contentReady
		
		onClicked:
		{
			_storeList.page = _storeList.page+1
		}
	}
	]
	
	headBar.middleContent: Maui.TextField
	{
		Layout.fillWidth: true
		placeholderText: qsTr("Search...")
		onAccepted: _storeList.query = text
		onCleared: _storeList.query = ""
	}
	
	footBar.rightContent: [
	ToolButton
	{
		id:_filterButton
		icon.name: "view-filter"
		icon.color: _filterDrawer.visible ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
		onClicked: _filterDrawer.visible ? _filterDrawer.close() : _filterDrawer.open()
	}
	]
	
	footBar.leftContent: [
	ToolButton
	{		
		icon.name: control.detailsView ? "view-list-icons" : "view-list-details"
		onClicked: control.detailsView = !control.detailsView
	}, 
	
	ToolButton
	{
		id:_sortButton
		icon.name: "view-sort"
		
		onClicked: sortMenu.popup()
		
		Menu
		{
			id: sortMenu			
			MenuItem
			{
				text: qsTr("Title")
				checkable: true
				checked: _storeList.sortBy === StoreList.LABEL
				onTriggered: _storeList.sortBy = StoreList.LABEL
			}
			
			MenuItem
			{
				text: qsTr("Rating")
				checkable: true
				checked: _storeList.sortBy === StoreList.RATE
				onTriggered: _storeList.sortBy = StoreList.RATE
			}
			
			MenuItem
			{
				text: qsTr("Downloads")
				checkable: true
				checked: _storeList.sortBy === StoreList.COUNT
				onTriggered: _storeList.sortBy = StoreList.COUNT
			}
			
			MenuItem
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
		
		emojiSize: Maui.Style.iconSizes.huge
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
				labelTxt.font.pointSize: Maui.Style.fontSizes.big
				
				isSection: true
				boldLabel: true
				height: Maui.Style.toolBarHeightAlt
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
	
	
	Kirigami.OverlayDrawer
	{
		id: _filterDrawer
		y: 0
// 		height: parent.height - footBar.implicitHeight - headBar.implicitHeight
		edge: Qt.RightEdge
// 		parent: control
		height: parent.height - (footBar.height)
		ListView
		{
			id: _filterList
			anchors.fill: parent
			anchors.margins: Maui.Style.space.medium
			model: ListModel{id: _filterModel}
			delegate: Maui.ListDelegate
			{
				id: delegate
				radius: Maui.Style.radiusV
				
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
		maxWidth: Maui.Style.unit * 800
		page.padding: 0
		
		acceptButton.text: qsTr("Download")
		rejectButton.visible: false
	
		
		footBar.rightContent: Button
		{
			id: _openButton
			text: qsTr("Open...")
			onClicked:
			{
				openFile(_storeList.itemLocalPath(layout.currentIndex))
				_previewerDialog.close()
			}
		}
		
		footBar.leftContent: [		
		
			ToolButton
			{
				id: _linkButton
				icon.name: "view-links"
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
					
					Maui.ImageViewer
					{
						clip: true
						anchors.top: parent.top
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						
						image.source: model.thumbnail
						image.horizontalAlignment: Qt.AlignHCenter
						image.verticalAlignment: Qt.AlignVCenter
						image.fillMode: Image.PreserveAspectCrop
						image.cache: false
						image.asynchronous: true	
						
						height: Math.min( parent.height, image.sourceSize.height)
						width: Math.min( parent.width, image.sourceSize.width)
						// 					sourceSize.width: Math.min(width, sourceSize.width)
						// 					sourceSize.height:  Math.min(height, sourceSize.height)
							
					}
					
					Rectangle
					{
						height: Maui.Style.iconSizes.medium
						width: height
						anchors
						{
							horizontalCenter: parent.horizontalCenter
							bottom: parent.bottom
							margins: Maui.Style.space.big
						}
						
						color: Kirigami.Theme.backgroundColor
						radius: Math.max(height, width)
						
						Label
						{
							anchors.fill: parent
							text: index
							horizontalAlignment: Qt.AlignHCenter
							verticalAlignment: Qt.AlignVCenter
							color: Kirigami.Theme.textColor
							font.bold: true
							font.weight: Font.bold
							font.pointSize: Maui.Style.fontSizes.big
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
				color: Kirigami.Theme.textColor
				font.bold: true
				font.weight: Font.bold
				font.pointSize: Maui.Style.fontSizes.big				
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
				color: Kirigami.Theme.textColor
				font.pointSize: Maui.Style.fontSizes.small
				opacity: 0.5
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.leftMargin: Maui.Style.space.big
				
				Layout.preferredHeight: rowHeightAlt
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Rating: ") + _previewerDialog.currentItem.rate
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: Kirigami.Theme.textColor
				font.pointSize: Maui.Style.fontSizes.small		
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.leftMargin: Maui.Style.space.big
				
				Layout.preferredHeight: rowHeightAlt
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Downloads: ") + _previewerDialog.currentItem.count
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: Kirigami.Theme.textColor
				font.pointSize: Maui.Style.fontSizes.small				
			}
			
// 			Label
// 			{
// 				Layout.fillWidth: true
// 				Layout.leftMargin: Maui.Style.space.big
// 				
// 				Layout.preferredHeight: rowHeightAlt
// 				wrapMode: Text.Wrap
// 				elide: Qt.ElideRight
// 				text: qsTr("License: ") + _previewerDialog.currentItem.license
// 				horizontalAlignment: Qt.AlignLeft
// 				verticalAlignment: Qt.AlignVCenter
// 				color: textColor
// 				font.pointSize: Maui.Style.fontSizes.small				
// 			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.leftMargin: Maui.Style.space.big
				
				Layout.preferredHeight: rowHeightAlt
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Date: ") + _previewerDialog.currentItem.date
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: Kirigami.Theme.textColor
				font.pointSize: Maui.Style.fontSizes.small				
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.preferredHeight: rowHeightAlt
				Layout.leftMargin: Maui.Style.space.big
				
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				text: qsTr("Tags: ") + _previewerDialog.currentItem.tag
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: Kirigami.Theme.textColor
				font.pointSize: Maui.Style.fontSizes.small				
			}
			
			Label
			{
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: Maui.Style.space.big
				text: _previewerDialog.currentItem.description
				horizontalAlignment: Qt.AlignLeft
				verticalAlignment: Qt.AlignVCenter
				color: Kirigami.Theme.textColor
				wrapMode: Text.Wrap
				elide: Qt.ElideRight
				font.pointSize: Maui.Style.fontSizes.default
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
