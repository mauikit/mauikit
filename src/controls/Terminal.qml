
import QMLTermWidget 1.0
import QtQuick 2.2
import QtQuick.Controls 1.1
import org.kde.mauikit 1.0 as Maui
import "private"

Item
{
	id: terminalContainer
	
	property size virtualResolution: Qt.size(kterminal.width, kterminal.height)
	
	property real fontWidth: 1.0
	property real screenScaling: 1.0
	property real scaleTexture: 1.0
	
	property alias title: ksession.title
	property alias kterminal: kterminal
	property alias session: ksession
	property alias findBar : findBar
	property alias menu : terminalMenu.content
	
	property size terminalSize: kterminal.terminalSize
	property size fontMetrics: kterminal.fontMetrics
	
	
	Maui.Menu
	{
		id: terminalMenu
		z: 999
		
		Maui.MenuItem
		{
			text: qsTr("Copy")
			onTriggered:  kterminal.copyClipboard();
		}
		
		Maui.MenuItem
		{
			text: qsTr("Paste")
			onTriggered: kterminal.pasteClipboard()
			
		}
		
		
		Maui.MenuItem
		{
			id: searchButton
			text: qsTr("Find")
			onTriggered: findBar.visible = !findBar.visible
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
	
	
	Maui.TextField
	{
		id: findBar
		visible: false
		anchors.bottom: parent.bottom
		width: parent.width
		colorScheme.borderColor: "transparent"
		height: visible ?  iconSizes.big : 0
		placeholderText: qsTr("Find...")
		horizontalAlignment: Qt.Left
		
		onAccepted: ksession.find(text)
	}
	
	QMLTermWidget
	{
		id: kterminal	
		anchors.bottomMargin: findBar.height 
		anchors.fill: parent
		
		focus: true
		smooth: true
		
		enableBold: true
		fullCursorHeight: true
		onKeyPressedSignal: ksession.hasDarkBackground
		// 		terminalUsesMouse: true
		
		// 		colorScheme: "DarkPastels"
		
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
			}
			
			onPressAndHold: terminalMenu.popup()
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
		function startSession()
		{
			
			ksession.setShellProgram("/usr/bin/bash");
			ksession.setArgs("");
			
			
			ksession.startShellProgram();
			forceActiveFocus();
		}
		
		Component.onCompleted:
		{
			startSession()
		}
	}
}
