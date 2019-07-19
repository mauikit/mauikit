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
	property alias scrollView: _scrollView
	
	property alias text: body.text
	property alias uppercase: document.uppercase
	property alias underline: document.underline
	property alias italic: document.italic
	property alias bold: document.bold
	property alias canRedo: body.canRedo
	
	
	headBarExit: false
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
	
	ToolButton
	{
		icon.name: "format-text-bold"
		focusPolicy: Qt.TabFocus
		icon.color: checked ? highlightColor : textColor
		checkable: false
		checked: document.bold
		onClicked: document.bold = !document.bold
	},
	
	ToolButton
	{
		icon.name: "format-text-italic"
		icon.color: checked ? highlightColor : textColor
		focusPolicy: Qt.TabFocus
		checkable: false
		checked: document.italic
		onClicked: document.italic = !document.italic
	},
	
	ToolButton
	{
		icon.name: "format-text-underline"
		icon.color: checked ? highlightColor : textColor
		focusPolicy: Qt.TabFocus
		checkable: true
		checked: document.underline
		onClicked: document.underline = !document.underline
	},
	
	ToolButton
	{
		icon.name: "format-text-uppercase"
		icon.color: checked ? highlightColor : textColor
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
		
		onLoaded:
		{
			body.text = text
		}
	}
	
	ScrollView
	{
		id: _scrollView
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
			
// 			background: Rectangle
// 			{
// 				color: "transparent"
// 			}
			
// 			onPressAndHold: isMobile ? documentMenu.popup() : undefined
			
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
					text: qsTr("Select all")
					onTriggered: body.selectAll()
				}
				
				MenuItem
				{
					text: qsTr("Web search")
					onTriggered: Maui.FM.openUrl("https://www.google.com/search?q="+body.selectedText)
					enabled: body.selectedText.length
					
				}
			}
		}
	}
}
