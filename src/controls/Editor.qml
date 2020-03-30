import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import "private"

Maui.Page
{
	id: control
	Kirigami.Theme.inherit: false
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	
	property bool showLineCount : true
	property bool showSyntaxHighlighting: true
	
	property alias body : body
	property alias document : document
	property alias scrollView: _scrollView
	
	property alias text: body.text
	property alias uppercase: document.uppercase
	property alias underline: document.underline
	property alias italic: document.italic
	property alias bold: document.bold
	property alias canRedo: body.canRedo
	
	property alias fileUrl : document.fileUrl
	
    focus: true
    title: document.fileName

    Maui.DocumentHandler
	{
		id: document
		document: body.textDocument
		cursorPosition: body.cursorPosition
		selectionStart: body.selectionStart
		selectionEnd: body.selectionEnd
// 		textColor: control.Kirigami.Theme.textColor
		backgroundColor: control.Kirigami.Theme.backgroundColor
// 		
		onError:
		{
			body.text = message
			body.visible = true
		}
	}
	
	Row
	{
		z: _scrollView.z +1
		visible: showLineCount
		anchors
		{
			right: parent.right
			bottom: parent.bottom
			margins: Maui.Style.space.big
		}
		
		width: implicitWidth
		height: implicitHeight
		
		Label
		{
			text: body.length + " / " + body.lineCount
			color: control.Kirigami.Theme.textColor
			opacity: 0.5
			font.pointSize: Maui.Style.fontSizes.medium
		}		
	}
	
	Menu
	{
		id: documentMenu
		z: 999
		
		MenuItem
		{
			text: qsTr("Copy")
			onTriggered: body.copy()
			enabled: body.selectedText.length
		}
		
		MenuItem
		{
			text: qsTr("Cut")
			onTriggered: body.cut()	
			enabled: !body.readOnly && body.selectedText.length					
		}
		
		MenuItem
		{
			text: qsTr("Paste")
			onTriggered: body.paste()
			enabled: !body.readOnly					
		}
		
		MenuItem
		{
			text: qsTr("Select All")
			onTriggered: body.selectAll()
		}
		
		MenuItem
		{
			text: qsTr("Search Selected Text on Google...")
			onTriggered: Qt.openUrlExternally("https://www.google.com/search?q="+body.selectedText)
			enabled: body.selectedText.length			
		}
	}	
	
	
	headBar.visible: !body.readOnly
	
	headBar.leftContent: [				
	
	ToolButton
	{
		icon.name: "edit-undo"
		enabled: body.canUndo
		onClicked: body.undo()
		opacity: enabled ? 1 : 0.5			
	},
	
	ToolButton
	{
		icon.name: "edit-redo"
		enabled: body.canRedo
		onClicked: body.redo()
		opacity: enabled ? 1 : 0.5
	},
	
	Row
	{
		id: _editingActions
		visible: (document.isRich || body.textFormat === Text.RichText) && !body.readOnly
		
		ToolButton
		{
			icon.name: "format-text-bold"
			focusPolicy: Qt.TabFocus
			icon.color: checked ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
			checkable: false
			checked: document.bold
			onClicked: document.bold = !document.bold
		}
		
		ToolButton
		{
			icon.name: "format-text-italic"
			icon.color: checked ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
			focusPolicy: Qt.TabFocus
			checkable: false
			checked: document.italic
			onClicked: document.italic = !document.italic
		}
		
		ToolButton
		{
			icon.name: "format-text-underline"
			icon.color: checked ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
			focusPolicy: Qt.TabFocus
			checkable: true
			checked: document.underline
			onClicked: document.underline = !document.underline
		}
		
		ToolButton
		{
			icon.name: "format-text-uppercase"
			icon.color: checked ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
			focusPolicy: Qt.TabFocus
			checkable: true
			checked: document.uppercase
			onClicked: document.uppercase = !document.uppercase
		}					
	}
	]		
	
	// 	footBar.visible: !body.readOnly
	footBar.rightContent: [
	ToolButton
	{
		icon.name: "zoom-in"
		onClicked: zoomIn()
	},
	
	ToolButton
	{
		icon.name: "zoom-out"
		onClicked: zoomOut()
	},
	
	ComboBox
	{
		visible: control.showSyntaxHighlighting
		model: document.getLanguageNameList()
		currentIndex: -1
		onCurrentIndexChanged: document.formatName = model[currentIndex]		
	}	
	]
	
	ColumnLayout
	{
		anchors.fill: parent
		spacing: 0
		
		Repeater
		{
			model: document.alerts
			
			Maui.ToolBar
			{
				id: _alertBar
				property var alert : model.alert
				readonly property int index_ : index
				Layout.fillWidth: true
				
				Kirigami.Theme.backgroundColor: 
				{
					switch(alert.level)
					{
						case 0: return Kirigami.Theme.positiveTextColor
						case 1: return Kirigami.Theme.neutralTextColor
						case 2: return Kirigami.Theme.negativeTextColor							
					}
				}
				
				leftContent: Maui.ListItemTemplate
				{
					Layout.fillWidth: true
					Layout.fillHeight: true
					
					label1.text: alert.title
					label2.text: alert.body
				}
				
				rightContent: Repeater
				{
					model: alert.actionLabels()
					
					Button
					{
						id: _alertAction						
						property int index_ : index						
						text: modelData
						onClicked: alert.triggerAction(_alertAction.index_, _alertBar.index_)
						
						Kirigami.Theme.backgroundColor: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.2)
						Kirigami.Theme.textColor: Kirigami.Theme.textColor
					}
				}
			}
		}
		
        PinchArea
        {
            id: pinchArea
            Layout.fillWidth: true
            Layout.fillHeight: true
// 			enabled: Maui.Handy.hasTouch
            property real minScale: 1.0
            property real maxScale: 3.0

// 			anchors.fill: parent
            pinch.minimumScale: minScale
            pinch.maximumScale: maxScale
            pinch.dragAxis: Pinch.XandYAxis
			
            onPinchFinished:
            {
                console.log("pinch.scale", pinch.scale)
				
                if(pinch.scale > 1.5)
                    control.zoomIn()
                    else control.zoomOut()
            }
			
            MouseArea{ anchors.fill: parent}
			
            Kirigami.ScrollablePage
			{
				id: _scrollView
                focus: true
                anchors.fill: parent
                flickable.interactive: true

				contentWidth: control.width
				contentHeight: body.height
				
				leftPadding: 0
				rightPadding: 0
				topPadding: 0
				bottomPadding: 0				
				
				TextArea
				{
					id: body
					implicitWidth: control.width
					text: document.text
// 					font.family: "Source Code Pro"
					placeholderText: qsTr("Body")
                    selectByKeyboard: !Kirigami.Settings.isMobile
                    selectByMouse : !Kirigami.Settings.isMobile
					textFormat: TextEdit.AutoText			
// 					font.pointSize: Maui.Style.fontSizes.large
					wrapMode: TextEdit.WrapAnywhere
					
					activeFocusOnPress: true
					activeFocusOnTab: true
					persistentSelection: true
					
					background: Rectangle
					{
						color: document.backgroundColor
						implicitWidth: body.implicitWidth
						implicitHeight: control.height
					}				
					
					onPressed:
					{
						if(!Kirigami.Settings.isMobile && event.button === Qt.RightButton)
							documentMenu.popup()
					}
				}
			}
			// 		ScrollBar.vertical.height: _scrollView.height - body.topPadding
			// 		ScrollBar.vertical.y: body.topPadding
        }
	}
	
	
	
	function zoomIn()
	{
		body.font.pointSize = body.font.pointSize *1.5
	}
	
	function zoomOut()
	{
		body.font.pointSize = body.font.pointSize / 1.5
		
	}
}
