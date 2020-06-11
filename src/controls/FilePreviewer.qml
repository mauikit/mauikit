import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
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
                        anchors.fill: parent
                        visible: control.showInfo
                        
                        Kirigami.Theme.backgroundColor: "transparent"
                        padding:  0
                        leftPadding: padding
                        rightPadding: padding
                        topPadding: padding
                        bottomPadding: padding
                        
                        ColumnLayout
                        {
                            width: parent.width
                            spacing: 0
                            
                            Rectangle
                            {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100
                                color: Qt.darker(Kirigami.Theme.backgroundColor, 1.1)
                                
                                Kirigami.Icon
                                {
                                    height: Maui.Style.iconSizes.large
                                    width: height
                                    anchors.centerIn: parent
                                    source: iteminfo.icon                                    
                                }
                            }
                            
                            Kirigami.Separator
                            {
                                Layout.fillWidth: true
                            }
                            
                            ListView
                            {
                                Layout.preferredHeight: contentHeight
                                Layout.fillWidth: true
                                Layout.margins: 0
                                spacing: 0
                                model: ListModel { id: _infoModel }
                                delegate: Maui.AlternateListItem
                                {
                                    visible: model.value.length
                                    width: visible ? parent.width : 0
                                    height: visible ? _delegateColumnInfo.implicitHeight + Maui.Style.space.large : 0
                                    alt: index % 2 === 0
                                   
                                    Maui.ListItemTemplate
                                    {
                                        id: _delegateColumnInfo
                                        width: parent.width
                                        
                                        iconSource: "documentinfo"
                                        iconSizeHint: Maui.Style.iconSizes.medium
                                        
                                        anchors.centerIn: parent
                                        anchors.margins: Maui.Style.space.medium
                                        
                                        label1.text: model.key
                                        label1.font.weight: Font.Bold
                                        label1.font.bold: true
                                        label2.text: model.value
                                        label2.elide: Qt.ElideMiddle
                                        label2.wrapMode: Text.Wrap
                                        label2.font.weight: Font.Light
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
