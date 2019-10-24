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
	
	Rectangle
	{
		anchors.fill: parent
		color: control.expanded ? "#333" : "transparent"
		opacity: 0.1
		radius: Math.min(Maui.Style.radiusV, )
		
		Behavior on color
		{
			ColorAnimation
			{
				duration: Kirigami.Units.longDuration
			}
		}
	}
	
	onClicked: 
	{
		control.expanded = !control.expanded
	}
	
	Row
	{
		id: _layout
		height: parent.height
        spacing: 0
		anchors.centerIn: parent
		
        Item
        {
            visible: control.direction === Qt.Vertical || (control.direction === Qt.Horizontal && !control.expanded)

            width: parent.height
            height: width
            Kirigami.Icon
            {
                source:  control.currentAction.icon.name
                width: Maui.Style.iconSizes.medium
                height: width
                anchors.centerIn: parent
            }

        }

// 		Label
// 		{
// 			visible:  control.direction === Qt.Vertical || (control.direction === Qt.Horizontal && !control.expanded)
// 			text: control.currentAction.text
// 			height: parent.height
// 		}
		
        Rectangle
        {
            color:/* control.expanded  && control.direction === Qt.Horizontal? Kirigami.Theme.highlightColor :*/ "transparent"
            height: parent.height
            width: control.expanded && control.direction === Qt.Horizontal? height : Maui.Style.iconSizes.small
            radius: Maui.Style.radiusV
            Kirigami.Icon
            {
                source: control.direction === Qt.Horizontal ? ( control.expanded ? "go-previous" : "go-next") : (control.direction === Qt.Vertical ? "arrow-down" : "")
                width: Maui.Style.iconSizes.small
                height: width
                anchors.centerIn: parent
            }			
        }
		
		Loader
		{
			id: _loader
			height: parent.height
			sourceComponent: control.direction ===  Qt.Horizontal ? _rowComponent : (control.direction === Qt.Vertical ?  _menuComponent : null)
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
			closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutsideParent
			
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
