
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Maui.Dialog
{
	id: control
	
	property string currentUrl: ""
	property var iteminfo : ({})
	property bool isDir : false
	property string mimetype : ""
	maxHeight: unit * 800
	maxWidth: unit * 500
	defaultButtons: false
		
		footBar.leftContent: Maui.ToolButton
		{
			visible: !isDir
			
			iconName: "document-share"
			onClicked:
			{
				isAndroid ? Maui.Android.shareDialog(currentUrl) :
				shareDialog.show([currentUrl])
				close()
			}
		}
		
		footBar.middleContent:   [
		Maui.ToolButton
		{
			iconName: "love"
		},
		Maui.ToolButton
		{
			
			iconName: "document-open"
			onClicked:
			{
				if(typeof(previewLoader.item.player) !== "undefined")
					previewLoader.item.player.stop()
					openFile(currentUrl)
			}
		}
		]
		
		footBar.rightContent:  Maui.ToolButton
		{
			iconName: "archive-remove"
			onClicked:
			{
				close()
				remove([currentUrl])
			}
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
		
		ScrollView
		{
			id: scrollView
			anchors.fill:parent
			contentHeight: previewLoader.item.height
			
			clip: true
			
			Loader
			{
				id: previewLoader
				height : control.height
				width: control.width
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
			control.mimetype = iteminfo.mime.slice(0, iteminfo.mime.indexOf("/"))
			control.isDir = mimetype === "inode"
			console.log("MIME TYPE FOR PREVEIWER", mimetype, iteminfo.icon)
			open()
		}
}
