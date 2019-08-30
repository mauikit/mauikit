import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami
import DocumentHandler 1.0 
import "private"

Item
{
	id: control
	
	property bool showLineCount : true
	property bool stickyHeadBar : true
	property alias body : body
	property alias document : document
	property alias scrollView: _scrollView
	
	property alias text: body.text
	property alias uppercase: document.uppercase
	property alias underline: document.underline
	property alias italic: document.italic
	property alias bold: document.bold
	property alias canRedo: body.canRedo	
	property alias headBar: _editorToolBar	
	
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
	
	Row
	{
		z: _scrollView.z +1
		visible: showLineCount
		anchors
		{
			right: parent.right
			bottom: parent.bottom
			margins: space.big
		}
		
		width: implicitWidth
		height: implicitHeight
		
		Label
		{
			text: body.length + " / " + body.lineCount
			color: Kirigami.Theme.textColor
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
	
	ScrollView
	{
		id: _scrollView
		anchors.fill: parent
		
		TextArea
		{
			id: body
			/*
			width: parent.width
			height: parent.height*/
			topPadding: _editorToolBar.visible ?  _editorToolBar.height : 0
//			topInset: stickyHeadBar ? 0 : topPadding
			Maui.ToolBar
			{
				id: _editorToolBar
				visible: !body.readOnly
				parent: stickyHeadBar ? body : control
				anchors
				{
					left: parent.left
					right: parent.right
					top: parent.top
				}
				
				leftContent: [	
				
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
					icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
					checkable: false
					checked: document.bold
					onClicked: document.bold = !document.bold
				},
				
				ToolButton
				{
					icon.name: "format-text-italic"
					icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
					focusPolicy: Qt.TabFocus
					checkable: false
					checked: document.italic
					onClicked: document.italic = !document.italic
				},
				
				ToolButton
				{
					icon.name: "format-text-underline"
					icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
					focusPolicy: Qt.TabFocus
					checkable: true
					checked: document.underline
					onClicked: document.underline = !document.underline
				},
				
				ToolButton
				{
					icon.name: "format-text-uppercase"
					icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
					focusPolicy: Qt.TabFocus
					checkable: true
					checked: document.uppercase
					onClicked: document.uppercase = !document.uppercase
				}
				]
				
				background: Rectangle
				{
					color: "transparent"					
				}				
			}
			
			
			placeholderText: qsTr("Body")
			Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor
			selectByKeyboard :!isMobile
			selectByMouse : !isMobile
			textFormat : TextEdit.AutoText
			
			color: control.Kirigami.Theme.textColor
			
			font.pointSize: fontSizes.large
			wrapMode: TextEdit.WrapAnywhere
			
			activeFocusOnPress: true
			activeFocusOnTab: true
			persistentSelection: true
			
			background: Rectangle
			{
				color: Kirigami.Theme.backgroundColor
				implicitWidth: 200
				implicitHeight: 22
			}
			
// 			onPressAndHold: isMobile ? documentMenu.popup() : undefined
			
			onPressed:
			{
				if(!isMobile && event.button === Qt.RightButton)
					documentMenu.popup()
			}			
		}
		ScrollBar.vertical.height: _scrollView.height - body.topPadding
		ScrollBar.vertical.y: body.topPadding
	}
}
