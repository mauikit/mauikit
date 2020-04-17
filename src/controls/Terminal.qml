
import QMLTermWidget 1.0
import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.7 as Kirigami

import org.kde.mauikit 1.0 as Maui
import "private"

Maui.Page
{
	id: control

	property size virtualResolution: Qt.size(kterminal.width, kterminal.height)
	
	property real fontWidth: 1.0
	property real screenScaling: 1.0
	property real scaleTexture: 1.0
	
	title: ksession.title
	showTitle: false
	
	property alias kterminal: kterminal
	property alias session: ksession
	property alias findBar : findBar
	property alias menu : terminalMenu.contentData
	
	property size terminalSize: kterminal.terminalSize
	property size fontMetrics: kterminal.fontMetrics
	focus: true	
	
	signal urlsDropped(var urls)
	signal keyPressed(var event)
	signal clicked()
    
	Keys.enabled: true

	//Actions
	Action
	{
		id: _copyAction
		text: qsTr("Copy")
		icon.name: "edit-copy"
		onTriggered:  kterminal.copyClipboard();	
		shortcut: "Ctrl+Shift+C"
	}
	
	Action
	{
		id: _pasteAction
		text: qsTr("Paste")
		icon.name: "edit-paste"
		onTriggered: kterminal.pasteClipboard()
		shortcut: "Ctrl+Shift+V"			
	}
	
	Action
	{
		id: _findAction
		text: qsTr("Find")
		icon.name: "edit-find"
		shortcut: "Ctrl+Shift+F"
		onTriggered: footBar.visible = !footBar.visible
	}
	
	Menu
	{
		id: terminalMenu
		
		MenuItem
		{
			action: _copyAction	
		}
		
		MenuItem		
		{
			action: _pasteAction
		}
		
		
		MenuItem		
		{
			action: _findAction
		}
	}	
	
	
	function correctDistortion(x, y)
	{
		x = x / width;
		y = y / height;
		
		var cc = Qt.size(0.5 - x, 0.5 - y);
		var distortion = 0;
		
		return Qt.point((x - cc.width  * (1+distortion) * distortion) * kterminal.width,
						(y - cc.height * (1+distortion) * distortion) * kterminal.height)
	}	
	
	function updateSources()
	{
		kterminal.update();
	}	
	
	footBar.visible: false	
	footBar.middleContent: Maui.TextField
	{
		id: findBar
		Layout.fillWidth: true
		placeholderText: qsTr("Find...")
		horizontalAlignment: Qt.Left		
		onAccepted: ksession.find(text)
	}
	
// 			Keys.enabled: true	
// 			Keys.onPressed:
// 			{
// 				console.log("key poress", event.key)
// 				if((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
// 				{
// 					kterminal.pasteClipboard()
// 				}
// 			}
	
	QMLTermWidget
	{
		id: kterminal	
		anchors.fill: parent
				
		enableBold: true
		fullCursorHeight: true
// 		onKeyPressedSignal: console.log(e.key)		
		
		font.family: "Monospace"
		font.pixelSize: 12
		
		onTerminalUsesMouseChanged: console.log(terminalUsesMouse);		
		
		Keys.enabled: true
		Keys.onPressed: control.keyPressed(event)
		
		session: QMLTermSession
		{
			id: ksession
			initialWorkingDirectory: "$HOME"
			onFinished: Qt.quit()
			
			// 			onMatchFound: 
			// 			{
			// 				console.log("found at: %1 %2 %3 %4".arg(startColumn).arg(startLine).arg(endColumn).arg(endLine));
			// 			}
			// 			onNoMatchFound:
			// 			{
			// 				console.log("not found");
			// 			}
			function find(query)
			{
				ksession.search(query)
			}			
		}		
		
		MouseArea
		{
			anchors.fill: parent
			propagateComposedEvents: true
			cursorShape: kterminal.terminalUsesMouse ? Qt.ArrowCursor : Qt.IBeamCursor
			acceptedButtons:  Qt.RightButton | Qt.LeftButton
			
			onDoubleClicked:
			{
				var coord = correctDistortion(mouse.x, mouse.y);
				kterminal.simulateMouseDoubleClick(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers);
			}
			
			onPressed: 
			{
				if((!kterminal.terminalUsesMouse || mouse.modifiers & Qt.ShiftModifier) && mouse.button == Qt.RightButton) 
				{
					terminalMenu.popup();
				} else 
				{
					var coord = correctDistortion(mouse.x, mouse.y);
					kterminal.simulateMousePress(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers)
				}
			}
			
			onReleased: 
			{
				var coord = correctDistortion(mouse.x, mouse.y);
				kterminal.simulateMouseRelease(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers);
			}
			
			onPositionChanged:
			{
				var coord = correctDistortion(mouse.x, mouse.y);
				kterminal.simulateMouseMove(coord.x, coord.y, mouse.button, mouse.buttons, mouse.modifiers);
			}
			
			onClicked:
			{
				if(mouse.button === Qt.RightButton)
					terminalMenu.popup()
					else if(mouse.button === Qt.LeftButton)
						kterminal.forceActiveFocus()
                        
                        control.clicked()
			}
			
			onPressAndHold: 
			{
                if(Maui.Handy.isTouch)
                    terminalMenu.popup()
            }
		}		
		
		QMLTermScrollbar
		{
			id: kterminalScrollbar
			terminal: kterminal
			anchors.margins: width * 0.5
			width: terminal.fontMetrics.width * 0.75
			Rectangle
			{
				anchors.fill: parent
				anchors.topMargin: 1
				anchors.bottomMargin: 1
				color: "white"
				radius: width * 0.25
				opacity: 0.7
			}
		}
		//        function handleFontChange(fontSource, pixelSize, lineSpacing, screenScaling, fontWidth){
		//            fontLoader.source = fontSource;
		
		//            kterminal.antialiasText = !appSettings.lowResolutionFont;
		//            font.pixelSize = pixelSize;
		//            font.family = fontLoader.name;
		
		//            terminalContainer.fontWidth = fontWidth;
		//            terminalContainer.screenScaling = screenScaling;
		//            scaleTexture = Math.max(1.0, Math.floor(screenScaling * appSettings.windowScaling));
		
		//            kterminal.lineSpacing = lineSpacing;
		//        }
		
		Component.onCompleted:
		{
			ksession.startShellProgram();
			forceActiveFocus()
		}
	}
	
	opacity: _dropArea.containsDrag ? 0.5 : 1

    DropArea
    {
		id: _dropArea
		anchors.fill: parent
		onDropped:
		{
			if(drop.urls) 
				control.urlsDropped(drop.urls)
        }
    }
	
	Component.onCompleted: control.forceActiveFocus();	
}
