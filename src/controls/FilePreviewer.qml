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

	property bool isFav : false
    property bool isDir : false
    property bool showInfo: true

    property alias infoModel : _infoModel
    property alias tagBar : _tagsBar

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
            openFile(control.currentUrl)
			control.close()
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
        text: qsTr("Info")

        checkable: true
        checked: control.showInfo
        onClicked: control.showInfo = !control.showInfo
    }
    
    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Label
        {
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.big
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
            visible: !control.showInfo
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Kirigami.ScrollablePage
        {
            id: _infoContent
            visible: control.showInfo
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Maui.Style.space.big

            Kirigami.Theme.backgroundColor: "transparent"
            padding: 0
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

        Maui.TagsBar
        {
            id: _tagsBar
            position: ToolBar.Footer
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
		if(previewLoader.item && previewLoader.item.player != null)
            previewLoader.item.player.stop()
			
			previewLoader.source = ""
    }

    function show(path)
    {
        control.iteminfo = Maui.FM.getFileInfo(path)
        control.initModel()
        
        control.isDir = iteminfo.isdir == "true"          
		control.currentUrl = path
		control.isFav =  _tagsBar.list.contains("fav")
		
		var source;
		switch(iteminfo.mime)
		{
			case "audio/mpeg" :
			case "audio/mp4" :
			case "audio/flac" :
			case "audio/ogg" :
			case "audio/wav" :
				source = "private/AudioPreview.qml"
				break
			case "video/mp4" :
			case "video/x-matroska" :
			case "video/webm" :
			case "video/avi" :
			case "video/flv" :
			case "video/mpg" :
			case "video/wmv" :
			case "video/mov" :
			case "video/ogg" :
			case "video/mpeg" :
			case "video/jpeg" :
				source = "private/VideoPreview.qml"
				break
			case "text/x-c++src" :
			case "text/x-c++hdr" :
			case "text/css" :
			case "text/html" :
			case "text/plain" :
			case "text/richtext" :
			case "text/scriptlet" :
			case "text/x-vcard" :
			case "text/x-go" :
			case "text/x-cmake" :
			case "text/x-qml" :
			case "application/xml" :
			case "application/javascript" :
			case "application/json" :
			case "application/pgp-keys" :
			case "application/x-shellscript" :
			case "application/x-kicad-project" :
				source = "private/TextPreview.qml"
				break
			case "image/png" :
			case "image/gif" :
			case "image/jpeg" :
			case "image/web" :
			case "image/svg" :
			case "image/svg+xml" :
				source = "private/ImagePreview.qml"
				break
			case "application/pdf":			
			case "application/rtf":			
			case "application/doc":			
			case "application/odf":			
				source = "private/DocumentPreview.qml"
				break			
			case "inode/directory" :
			default:
				source = "private/DefaultPreview.qml"
		}
		
		console.log("previe mime", iteminfo.mime)
		previewLoader.source = source
		control.showInfo = source === "private/DefaultPreview.qml"
		open()
    }

    function initModel()
    {
        control.infoModel.clear()
        control.infoModel.append({key: "Type", value: iteminfo.mime})
        control.infoModel.append({key: "Date", value: iteminfo.date})
        control.infoModel.append({key: "Modified", value: iteminfo.modified})
        control.infoModel.append({key: "Last read", value: iteminfo.lastread})
        control.infoModel.append({key: "Owner", value: iteminfo.owner})
        control.infoModel.append({key: "Group", value: iteminfo.group})
        control.infoModel.append({key: "Size", value: Maui.FM.formatSize(iteminfo.size)})
		control.infoModel.append({key: "Symlink", value: iteminfo.symlink})
        control.infoModel.append({key: "Path", value: iteminfo.path})
        control.infoModel.append({key: "Icon name", value: iteminfo.icon})
    }
}
