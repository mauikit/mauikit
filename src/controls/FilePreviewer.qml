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
