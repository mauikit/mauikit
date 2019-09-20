
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
	property var iteminfo : ({})
	
	property bool isDir : false
	property string mimetype : ""
	property bool showInfo: true
	
	signal shareButtonClicked(url url)
	
	maxHeight: Maui.Style.unit * 800
	maxWidth: Maui.Style.unit * 500
	
	defaultButtons: false
		
		page.padding: 0
		
		footBar.leftContent: ToolButton
		{
			icon.name: "document-open"
			text: qsTr("Open")
			onClicked:
			{
				if(typeof(previewLoader.item.player) !== "undefined")
					previewLoader.item.player.stop()
					control.openFile(currentUrl)
			}
		}
		
		footBar.middleContent: [
		
		ToolButton
		{
			visible: !isDir
			icon.name: "document-share"
			text: qsTr("Share")
			onClicked:
			{
				shareButtonClicked(currentUrl)
				close()
			}
		},
		
		ToolButton
		{
			icon.name: "love"
			text: qsTr("Fav")
		}

		]
		
        footBar.rightContent:  ToolButton
        {
            icon.name: "documentinfo"
            text: qsTr("Info")

            checkable: true
            checked: control.showInfo
            onClicked: control.showInfo = !control.showInfo
        }

		Component
		{
			id: imagePreview
			ImagePreview {}
		}
		
		Component
		{
			id: defaultPreview
			DefaultPreview {}
		}
		
		Component
		{
			id: audioPreview
			AudioPreview {}
		}
		
		Component
		{
			id: videoPreview			
			VideoPreview {}
		}
		
		Component
		{
			id: textPreview
			TextPreview {}
		}		
		
		ColumnLayout
		{
			anchors.fill: parent
			spacing: 0
			
			Label
			{		
				Layout.fillWidth: true
				Layout.margins: Maui.Style.space.medium
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				elide: Qt.ElideMiddle
				wrapMode: Text.Wrap
				font.pointSize: Maui.Style.fontSizes.big
				font.weight: Font.Bold
				font.bold: true
				text: iteminfo.name
				color: Kirigami.Theme.textColor
			}			
			
			Loader
			{
				id: previewLoader
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.margins: Maui.Style.space.big
				
				sourceComponent: switch(mimetype)
				{
					case "audio" :
						audioPreview
						break
					case "video" :
						videoPreview
						break
					case "text" :
						textPreview
						break
					case "image" :
						imagePreview
						break
					case "inode" :
					default:
						defaultPreview
				}
			}
			
			Maui.TagsBar
			{
				id: _tagsBar
				Layout.fillWidth: true
				Layout.margins: 0
				list.urls: [control.currentUrl]
				allowEditMode: true
				onTagRemovedClicked: list.removeFromUrls(index)
				onTagsEdited: list.updateToUrls(tags)
				Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
				Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor
				onAddClicked:
				{
					dialogLoader.sourceComponent = tagsDialogComponent
					dialog.composerList.urls = [control.currentUrl]
					dialog.open()
				}
			}
		}
		
		onClosed:
		{
			if(previewLoader.item.player)
				previewLoader.item.player.stop()
		}
		
		function show(path)
		{
			control.currentUrl = path
			control.iteminfo = Maui.FM.getFileInfo(path)
			if(iteminfo.mime.indexOf("/"))
			control.mimetype = iteminfo.mime.slice(0, iteminfo.mime.indexOf("/"))
			else control.mimetype = ""
			control.isDir = mimetype === "inode"
			
			showInfo = mimetype === "image" || mimetype === "video" || mimetype === "text"? false : true
			
			console.log("MIME TYPE FOR PREVEIWER", mimetype, iteminfo.icon)
			open()
		}
}
