import QtQuick 2.12
import QtQuick.Controls 2.3

import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Window 2.3
import org.kde.mauikit 1.0 as Maui

Item
{
	id: control
	implicitWidth: _controlsLayout.implicitWidth
	property int alignment : Qt.AlignLeft
	property int orientation: Qt.Horizontal
	// 		TapHandler {
	// 			onTapped: if (tapCount === 2) toggleMaximized()
	// 			gesturePolicy: TapHandler.DragThreshold
	// 		}
	// 		DragHandler {
	// 			grabPermissions: TapHandler.CanTakeOverFromAnything
	// 			onActiveChanged: if (active) { root.startSystemMove(); }
	// 		}
	
	property Item closeButton : MouseArea
	{
		id: _closeButton
		height: 16
		width: height
		onClicked: root.close()
		hoverEnabled: true
		
		Rectangle
		{
			anchors.fill: parent
			
			color: parent.containsMouse || parent.containsPress ? "transparent" : "#f06292"
			radius: height
			border.color: Qt.darker("#f06292", 1.2)
			
			Maui.X
			{
				height: 6
				width: height
				anchors.centerIn: parent
				color: _closeButton.containsMouse || _closeButton.containsPress ? "#f06292" : "white"
			}							
		}
	}
	
	property Item minimizeButton: MouseArea
	{
		id: _minimizeButton
		height: 16
		width: height
		onClicked: root.showMinimized()
		hoverEnabled: true
		
		Rectangle
		{
			anchors.fill: parent
			
			color: parent.containsMouse || parent.containsPress ? "transparent" : "#4dd0e1"
			radius: height
			border.color: Qt.darker("#4dd0e1", 1.2)
			
			Maui.Triangle
			{
				height: 6
				width: height
				anchors.centerIn: parent
				rotation: -45
				color: _minimizeButton.containsMouse || _minimizeButton.containsPress ? "#4dd0e1" : "white"
				
			}
		}
	}
	
	property Item maximizeButton: MouseArea
	{
		id: _maximizeButton
		height: 16
		width: height
		onClicked: root.toggleMaximized()
		hoverEnabled: true
		
		Rectangle
		{
			anchors.fill: parent
			
			color: parent.containsMouse || parent.containsPress ? "transparent" : "#42a5f5"
			radius: height
			border.color: Qt.darker("#42a5f5", 1.2)
			
			Maui.Triangle
			{
				height: 6
				width: height
				anchors.centerIn: parent
				rotation: 90+45
				color: _maximizeButton.containsMouse || _maximizeButton.containsPress ? "#42a5f5" : "white"
				
			}
		}
	}
	
	RowLayout
	{
		id: _controlsLayout
		spacing: Maui.Style.space.medium
		anchors.fill: parent
		
	}
	
	Component.onCompleted:
	{		
		_controlsLayout.children= control.alignment === Qt.AlignLeft ?  [ closeButton, maximizeButton, minimizeButton] :  [ minimizeButton, maximizeButton, closeButton]
	}
}
