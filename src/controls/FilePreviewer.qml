import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Maui.Dialog
{
	id: control	
	
	property url currentUrl: ""
	
	property alias model : _listView.model
	property bool isFav : false
	property bool isDir : false
	property bool showInfo: true	
	
	property alias tagBar : _tagsBar
	
	property Maui.TagsDialog tagsDialog : null
	
	signal shareButtonClicked(url url)
	signal openButtonClicked(url url)
	
	maxHeight: Maui.Style.unit * 800
	maxWidth: Maui.Style.unit * 500
	
	defaultButtons: false
		
		page.padding: 0
		
		footBar.visible: true
		footBar.leftContent: ToolButton
		{
			icon.name: "document-open"
			onClicked:
			{
				openButtonClicked(control.currentUrl)
				control.close()
			}
		}
		
		footBar.middleContent: [
		
		ToolButton
		{
			visible: !isDir
			icon.name: "document-share"
			onClicked:
			{
				shareButtonClicked(control.currentUrl)
				control.close()
			}
		},
		
		ToolButton
		{
			icon.name: "love"
			checkable: true
			checked: control.isFav
			onClicked:
			{
				if(control.isFav)
					_tagsBar.list.removeFromUrls("fav")
					else
						_tagsBar.list.insertToUrls("fav")
						
						control.isFav = !control.isFav
			}
		}
		]
		
		footBar.rightContent: ToolButton
		{
			icon.name: "documentinfo"
			checkable: true
			checked: control.showInfo
			onClicked: control.showInfo = !control.showInfo
		}
		
		ColumnLayout
		{
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: 0
			
			ListView
			{
				id: _listView
				Layout.fillWidth: true
				Layout.fillHeight: true
				
				orientation: ListView.Horizontal
				clip: true
				focus: true
				interactive: true
				highlightFollowsCurrentItem: true
				highlightMoveDuration: 0
				highlightResizeDuration : 0
				snapMode: ListView.SnapOneItem
				cacheBuffer: 0
				keyNavigationEnabled : true
				keyNavigationWraps : true
				onMovementEnded: currentIndex = indexAt(contentX, contentY) 
				
				delegate: Maui.Page
				{
					id: _delegate
					property bool isCurrentItem : ListView.isCurrentItem
					property url currentUrl: model.path
					property var iteminfo : model
					
					property alias infoModel : _infoModel
					height: _listView.height
					width: _listView.width
					
					title: model.label
					headBar.visible: true
					autoHideHeader: true
                    floatingHeader: false //TODO needs some upstream fixes to work properly

					Loader
					{
						id: previewLoader
						active: _delegate.isCurrentItem && control.visible
						visible: !control.showInfo
						anchors.fill: parent
						clip: false
						onActiveChanged: if(active) show(currentUrl)
					}
					
					Kirigami.ScrollablePage
					{
						id: _infoContent
						visible: control.showInfo
						anchors.fill: parent
						
						Kirigami.Theme.backgroundColor: "transparent"
						padding:  Maui.Style.space.big
						leftPadding: padding
						rightPadding: padding
						topPadding: padding
						bottomPadding: padding
						
						ColumnLayout
						{
							width: parent.width
							spacing: Maui.Style.space.large
							
							Repeater
							{
								model: ListModel { id: _infoModel }
								
								Column
								{
									spacing: Maui.Style.space.small
									width: parent.width
									
									Label
									{
										width: parent.width
										visible: _valueLabel.visible
										text: model.key
										color: Kirigami.Theme.textColor
										
										elide: Text.ElideRight
										wrapMode: Text.NoWrap
										
										horizontalAlignment: Qt.AlignLeft
										
										font.weight: Font.Bold
										font.bold: true
									}
									
									Label
									{
										id: _valueLabel
										
										width: parent.width
										visible: text.length
										text: model.value
										color: Kirigami.Theme.textColor
										
										elide: Qt.ElideMiddle
										wrapMode: Text.Wrap
										
										horizontalAlignment: Qt.AlignLeft
										
										font.weight: Font.Light
									}
								}
							}							
						}
					}
					
					function show(path)
					{
						initModel()
						
						control.isDir = model.isdir == "true"
						control.currentUrl = path
						control.isFav =  _tagsBar.list.contains("fav")
						
						var source = "private/DefaultPreview.qml"
						if(Maui.FM.checkFileType(Maui.FMList.AUDIO, iteminfo.mime))
						{
							source = "private/AudioPreview.qml"
						}
						
						if(Maui.FM.checkFileType(Maui.FMList.VIDEO, iteminfo.mime))
						{
							source = "private/VideoPreview.qml"
						}
						
						if(Maui.FM.checkFileType(Maui.FMList.TEXT, iteminfo.mime))
						{
							source = "private/TextPreview.qml"
						}
						
						if(Maui.FM.checkFileType(Maui.FMList.IMAGE, iteminfo.mime))
						{
							source = "private/ImagePreview.qml"
						}
						
						if(Maui.FM.checkFileType(Maui.FMList.DOCUMENT, iteminfo.mime) && !isAndroid)
						{
							source = "private/DocumentPreview.qml"
						}
						
						console.log("previe mime", iteminfo.mime)
						previewLoader.source = source
						control.showInfo = source === "private/DefaultPreview.qml"
					}
					
					function initModel()
					{
						infoModel.clear()
						infoModel.append({key: "Type", value: iteminfo.mime})
						infoModel.append({key: "Date", value: iteminfo.date})
						infoModel.append({key: "Modified", value: iteminfo.modified})
						infoModel.append({key: "Last Read", value: iteminfo.lastread})
						infoModel.append({key: "Owner", value: iteminfo.owner})
						infoModel.append({key: "Group", value: iteminfo.group})
						infoModel.append({key: "Size", value: Maui.FM.formatSize(iteminfo.size)})
						infoModel.append({key: "Symbolic Link", value: iteminfo.symlink})
						infoModel.append({key: "Path", value: iteminfo.path})
						infoModel.append({key: "Icon Name", value: iteminfo.icon})
					} 
				}                
			}			
			
			Maui.TagsBar
			{
				id: _tagsBar
				position: ToolBar.Footer
				Layout.fillWidth: true
				Layout.margins: 0
				list.urls: [control.currentUrl]
				list.strict: false
				allowEditMode: true
				onTagRemovedClicked: list.removeFromUrls(index)
				onTagsEdited: list.updateToUrls(tags)
				Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
				Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor
			}
		}  
		
		function show(model, index)
		{
			control.model = model
			_listView.currentIndex = index
			_listView.positionViewAtIndex(index,ListView.Center )
			open()            
			_listView.forceActiveFocus()
		}		
}
