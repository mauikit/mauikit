import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import DocumentHandler 1.0 
import "private"

Maui.Page
{
	id: control
	
	property bool showLineCount : true
	
	property alias body : body
	property alias document : document
	
	property alias text: body.text
	property alias uppercase: document.uppercase
	property alias underline: document.underline
	property alias italic: document.italic
	property alias bold: document.bold
	property alias canRedo: body.canRedo
	
	
	headBarExit: false

	headBar.leftContent: [	
	
	Maui.ToolButton
	{
		iconName: "edit-undo"
		enabled: body.canUndo
		onClicked: body.undo()
		opacity: enabled ? 1 : 0.5
		
	},
	
	Maui.ToolButton
	{
		iconName: "edit-redo"
		enabled: body.canRedo
		onClicked: body.redo()
		opacity: enabled ? 1 : 0.5
	},
	
	Maui.ToolButton
	{
		iconName: "format-text-bold"
		focusPolicy: Qt.TabFocus
		iconColor: checked ? highlightColor : textColor
		checkable: true
		checked: document.bold
		onClicked: document.bold = !document.bold
	},
	
	Maui.ToolButton
	{
		iconName: "format-text-italic"
		iconColor: checked ? highlightColor : textColor
		focusPolicy: Qt.TabFocus
		checkable: true
		checked: document.italic
		onClicked: document.italic = !document.italic
	},
	
	Maui.ToolButton
	{
		iconName: "format-text-underline"
		iconColor: checked ? highlightColor : textColor
		focusPolicy: Qt.TabFocus
		checkable: true
		checked: document.underline
		onClicked: document.underline = !document.underline
	},
	
	Maui.ToolButton
	{
		iconName: "format-text-uppercase"
		iconColor: checked ? highlightColor : textColor
		focusPolicy: Qt.TabFocus
		checkable: true
		checked: document.uppercase
		onClicked: document.uppercase = !document.uppercase
	}
	]
	
	DocumentHandler
	{
		id: document
		document: body.textDocument
		cursorPosition: body.cursorPosition
		selectionStart: body.selectionStart
		selectionEnd: body.selectionEnd
		// textColor: TODO
		//            onLoaded: {
		//                body.text = text
		//            }
		onError:
		{
			body.text = message
			body.visible = true
		}
	}
	
	ScrollView
	{
		anchors.fill: parent
		
		TextArea
		{
			id: body
			
			width: parent.width
			height: parent.height
			
			placeholderText: qsTr("Body")
			
			selectByKeyboard :!isMobile
			selectByMouse : !isMobile
			textFormat : TextEdit.AutoText
			
			color: control.colorScheme.textColor
			
			font.pointSize: fontSizes.large
			wrapMode: TextEdit.WrapAnywhere
			
			activeFocusOnPress: true
			activeFocusOnTab: true
			persistentSelection: true
			
			background: Rectangle
			{
				color: "transparent"
			}
			
			onPressAndHold: isMobile ? documentMenu.popup() : undefined
			onPressed:
			{
				if(!isMobile && event.button === Qt.RightButton)
					documentMenu.popup()
			}
			
			Row
			{
				visible: showLineCount
				anchors
				{
					right: parent.right
					bottom: parent.bottom
				}
				
				width: implicitWidth
				height: implicitHeight
				
				Label
				{
					text: body.length + " / " + body.lineCount
					color: textColor
					opacity: 0.5
					font.pointSize: fontSizes.medium
				}
				
			}
			
			Maui.Menu
			{
				id: documentMenu
				z: 999
				
				Maui.MenuItem
				{
					text: qsTr("Copy")
					onTriggered: body.copy()
				}
				
				Maui.MenuItem
				{
					text: qsTr("Cut")
					onTriggered: body.cut()					
				}
				
				Maui.MenuItem
				{
					text: qsTr("Paste")
					onTriggered: body.paste()
					
				}
				
				Maui.MenuItem
				{
					text: qsTr("Select all")
					onTriggered: body.selectAll()
				}
				
				Maui.MenuItem
				{
					text: qsTr("Web search")
					onTriggered: Maui.FM.openUrl("https://www.google.com/search?q="+body.selectedText)
				}
			}
		}
	}
}
