import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.1

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

MouseArea
{
	id: control
	implicitWidth: _layout.implicitWidth +  Maui.Style.space.medium
	implicitHeight: parent.height
	
	default property list<Action> actions
	property bool autoExclusive: true
	
	property int direction : Qt.Vertical
	
	property Action currentAction : actions[0]
	
	property bool expanded : false
	
	// 	Rectangle
	// 	{
	// 		anchors.fill: parent
	// 		color: control.expanded ? "#333" : "transparent"
	// 		opacity: 0.1
	// 		radius: Math.min(Maui.Style.radiusV, height)
	// 		
	// 		Behavior on color
	// 		{
	// 			ColorAnimation
	// 			{
	// 				duration: Kirigami.Units.longDuration
	// 			}
	// 		}
	// 	}
	
	onClicked: 
	{
		control.expanded = !control.expanded
	}
	
	Row
	{
		id: _layout
		height: parent.height
		spacing: Maui.Style.space.small
		anchors.centerIn: parent
		
		
		ToolButton
		{
			icon.name:  control.currentAction.icon.name
			text: " "
			onClicked: 		control.expanded = !control.expanded 
			
			Kirigami.Icon
			{
				anchors
				{
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				color: control.Kirigami.Theme.textColor
				source: "qrc://assets/arrow-down.svg"
				width: Maui.Style.iconSizes.small
				height: width
				isMask: true
			}	
		}         
		
		
		Loader
		{
			id: _loader
			height: parent.height
			sourceComponent: control.direction ===  Qt.Horizontal ? _rowComponent : (control.direction === Qt.Vertical ?  _menuComponent : "")
		}
		
	}
	
	Component
	{
		id: _rowComponent
		
		Row
		{
			id: _row
			width: control.expanded ? implicitWidth : 0
			spacing: Maui.Style.space.medium
			clip: true
			height: parent.height
			
			Behavior on width
			{
				
				NumberAnimation
				{
					duration: Kirigami.Units.longDuration
					easing.type: Easing.InOutQuad
				}
			}
			
			Kirigami.Separator
			{
				width: 1
				height: parent.height * 0.7
				anchors.verticalCenter: parent.verticalCenter
			}			
			
			Repeater
			{
				model: control.actions
				
				ToolButton
				{
					action: modelData
					autoExclusive: control.autoExclusive
					anchors.verticalCenter: parent.verticalCenter
					onClicked: 
					{
						control.currentAction = action
						control.expanded = false
					}
				}
			}
		}
		
	}
	
	Component
	{
		id: _menuComponent
		
		Menu
		{
			id: _actionsMenu
			Connections
			{
				target: control
				onExpandedChanged:
				{
					if(control.expanded)
						_actionsMenu.popup(0, parent.height)
						else
							_actionsMenu.close()
				}
			}
			
			onClosed: control.expanded = false
			closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
			
			Repeater
			{
				model: control.actions
				
				MenuItem
				{
					action: modelData
					
					autoExclusive: control.autoExclusive
					Connections
					{
						target: modelData
						onTriggered: control.currentAction = action
					}
				}
			}
		}
	}
	
}
