
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Maui.Dialog
{
	id: control
	
	colorScheme.backgroundColor: "#2d2d2d"
	colorScheme.textColor: "#fafafa"
	
	property string currentUrl: ""
	property var iteminfo : ({})
	property bool isDir : false
	property string mimetype : ""
	property bool showInfo: true
	
	signal shareButtonClicked(string url)
	
	maxHeight: unit * 800
	maxWidth: unit * 500
	defaultButtons: false
		
		footBar.leftContent: Maui.ToolButton
		{
			iconColor: control.colorScheme.textColor
			iconName: "document-open"
            text: qsTr("Open")
			onClicked:
			{
				if(typeof(previewLoader.item.player) !== "undefined")
					previewLoader.item.player.stop()
					openFile(currentUrl)
			}
		}
		
		footBar.middleContent: [
		
		Maui.ToolButton
		{
			visible: !isDir
			iconColor: control.colorScheme.textColor
			iconName: "document-share"
                text: qsTr("Share")

			onClicked:
			{
				shareButtonClicked(currentUrl)
				close()
			}
		},
		
		Maui.ToolButton
		{
			iconName: "love"
			iconColor: control.colorScheme.textColor
                text: qsTr("Fav")

			
        }
		

		]
		
        footBar.rightContent:  Maui.ToolButton
        {
            iconName: "documentinfo"
            text: qsTr("Info")

            checkable: true
            checked: showInfo
            onClicked: showInfo = !showInfo
            iconColor: control.colorScheme.textColor

        }

		Component
		{
			id: imagePreview
			ImagePreview
			{
				id: imagePreviewer
			}
		}
		
		Component
		{
			id: defaultPreview
			DefaultPreview
			{
				id: defaultPreviewer
			}
		}
		
		Component
		{
			id: audioPreview
			AudioPreview
			{
				id: audioPreviewer
			}
		}
		
		Component
		{
			id: videoPreview
			
			VideoPreview
			{
				id: videoPreviewer
			}
		}
		
		ColumnLayout
		{
			anchors.fill: parent
			spacing: 0
			clip: true
			
			
				Label
				{		
					Layout.fillWidth: true
					Layout.margins: space.medium
					horizontalAlignment: Qt.AlignHCenter
					verticalAlignment: Qt.AlignVCenter
					elide: Qt.ElideRight
					wrapMode: Text.Wrap
					font.pointSize: fontSizes.big
					font.weight: Font.Bold
					font.bold: true
					text: iteminfo.name
					color: colorScheme.textColor
					
				}
			
			
			Loader
			{
				id: previewLoader
				Layout.fillWidth: true
				Layout.fillHeight: true
				sourceComponent: switch(mimetype)
				{
					case "audio" :
						audioPreview
						break
					case "video" :
						videoPreview
						break
					case "text" :
						defaultPreview
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
				// 				height: 64
				list.urls: [control.currentUrl]
				allowEditMode: true
				clip: true
				onTagRemovedClicked: list.removeFromUrls(index)
				onTagsEdited: list.updateToUrls(tags)
// 				colorScheme: control.colorScheme
				Kirigami.Theme.textColor: control.colorScheme.textColor
				Kirigami.Theme.backgroundColor: control.colorScheme.backgroundColor
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
			
			showInfo = mimetype === "image" || mimetype === "video" ? false : true
			
			console.log("MIME TYPE FOR PREVEIWER", mimetype, iteminfo.icon)
			open()
		}
}
