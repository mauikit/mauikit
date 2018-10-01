import QtQuick 2.6
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.0 as Kirigami
import "private"

Maui.ToolButton
{
	id: control
	z: 1
	
	/* Controlc color scheming */
	ColorScheme 
	{
		id: colorScheme
	}
	
	property alias colorScheme : colorScheme
	/***************************/
	
	property int alignment : Qt.AlignLeft
	
	property int barHeight : 0
	property int maxWidth :  ApplicationWindow.overlay.width *( isMobile ? 1 : 0.5)
	
	property alias content : content.middleContent
	
	onClicked: popup.visible ? close(): open()
	
	layer.enabled: true
	clip: true
	
	Popup
	{
		id: popup
		height: barHeight
		width: content.middleLayout.implicitWidth + space.big > maxWidth ? maxWidth : (content.middleLayout.implicitWidth > ApplicationWindow.overlay.width ? ApplicationWindow.overlay.width  : content.middleLayout.implicitWidth + space.big)		
		padding: 0
		margins: 0
		x: (control.x - width) - space.big
		y:  parent.height / 2 - height / 2
		
		background: Rectangle
		{
			radius: radiusV
			color: colorScheme.backgroundColor
			border.color: colorScheme.borderColor
		}
		
		onFocusChanged: !activeFocus || !focus ? close() : undefined
	
// 	enter: Transition 
// 	{
// 		NumberAnimation { property: "width"; from: 0.0; to: popup.implicitWidth }
// 	}
// 	exit: Transition 
// 	{
// 		NumberAnimation { property: "width"; from: popup.implicitWidth; to: 0.0 }
// 	}
	
		Maui.ToolBar
		{
			id: content
			anchors.fill: parent
			implicitHeight: parent.height
			spacing: space.enormous
			colorScheme.backgroundColor: "transparent"
		}
	}
	
	
	
	function open()
	{	
		 popup.open()		
	}
	
	function close()
	{
		popup.close()
	}
}
