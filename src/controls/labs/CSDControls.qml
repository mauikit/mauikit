import QtQuick 2.12
import QtQuick.Controls 2.3

import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Window 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Item
{
	id: control
	readonly property bool maskButtons: Maui.App.theme.maskButtons
	
	implicitWidth: _controlsLayout.implicitWidth
	property var order : []
	// 		TapHandler {
	// 			onTapped: if (tapCount === 2) toggleMaximized()
	// 			gesturePolicy: TapHandler.DragThreshold
	// 		}
	// 		DragHandler {
	// 			grabPermissions: TapHandler.CanTakeOverFromAnything
	// 			onActiveChanged: if (active) { root.startSystemMove(); }
	// 		}
	
	property Component closeButton : Item
	{
		signal clicked()		
		onClicked: root.close()	
		
		Kirigami.Icon
		{
			anchors.centerIn: parent
			height: 16
			width: height
			color: isMask ? (hovered ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor) : "transparent"		
			isMask: control.maskButtons
			source: Maui.App.theme.buttonAsset("Close", hovered ? "Hover" : "Normal")
		}
	}	
	
	property Component minimizeButton: Item
	{
		signal clicked()
		
		onClicked: root.showMinimized()
		Kirigami.Icon
		{
			anchors.centerIn: parent			
			height: 16
			width: height
			color: isMask ? (hovered ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.textColor) : "transparent"		
			isMask: control.maskButtons
			source: Maui.App.theme.buttonAsset("Minimize", hovered ? "Hover" : "Normal")
		}
	}	
	
	property Component maximizeButton: Item
	{	
		signal clicked()
		onClicked: root.toggleMaximized()
	
		Kirigami.Icon
		{
			anchors.centerIn: parent
			height: 16
			width: height
			color: isMask ? (hovered ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor) : "transparent"		
			isMask: control.maskButtons
			source: Maui.App.theme.buttonAsset(Window.window.visibility === Window.Maximized ? "Restore" : "Maximize", hovered ? "Hover" : "Normal")
		}
	}
	
	Row
	{
		id: _controlsLayout
		spacing: Maui.Style.space.medium
		width: parent.width
		height: parent.height
		
		Repeater
		{
			model: control.order
			delegate: MouseArea
			{
				id: _delegate
				height: 18
				width: height
				anchors.verticalCenter: parent.verticalCenter
				hoverEnabled: true
				onClicked: _loader.item.clicked()
				
				Loader
				{
					id: _loader
					property bool hovered : parent.containsMouse || parent.containsPress
					signal clicked()
					
					anchors.fill: parent
					sourceComponent: mapControl(modelData)					
				}
			}
		}
	}
	
	function mapControl(key)
	{
		switch(key)
		{
			case "X": return closeButton;
			case "I": return minimizeButton;
			case "A": return maximizeButton;
			default: return null;			
		}
	}
}
