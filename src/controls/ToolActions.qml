import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.1

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Item
{
	id: control
	implicitWidth: _layout.implicitWidth
	implicitHeight: parent.height
	
	default property list<Action> actions
	
	property bool autoExclusive: true	
	
	property Action currentAction : actions[0]
	property int currentIndex : 0	
	onCurrentIndexChanged:
	{
        control.currentAction = actions[control.currentIndex]
    }
	
	property bool expanded : true
	
	Row
	{
		id: _layout
		height: parent.height
		spacing: Maui.Style.space.small
		
		ToolButton
		{			
			visible: !control.expanded
            icon.name: control.currentAction.icon.name
            onClicked: 
            {
				if(!_loader.item.visible)
					_loader.item.popup(control, 0, control.height)
					else
						_loader.item.close()
			}
            
            indicator: Maui.Triangle
            {
                anchors
                {
                    //            rightMargin: 5
                    right: parent.right
                    // 			bottom: parent.bottom
                    verticalCenter: parent.verticalCenter
                }
                rotation: -45
                color: control.Kirigami.Theme.textColor
                width: Maui.Style.iconSizes.tiny-3
                height:  width 
            }	
        }         
		
		
		Loader
		{
			id: _loader
			height: parent.height
			width: control.expanded ? implicitWidth : 0
			sourceComponent: control.expanded ? _rowComponent : _menuComponent
		}
		
	}
	
	Component
	{
		id: _rowComponent
		
		Row
		{
			id: _row
			spacing: Maui.Style.space.small
			height: parent.height
			
			clip: true
			
			Behavior on width
			{
				
				NumberAnimation
				{
					duration: Kirigami.Units.longDuration
					easing.type: Easing.InOutQuad
				}
			}
			
			Repeater
			{
				model: control.actions
				
				ToolButton
				{
					ToolTip.delay: 1000
					ToolTip.timeout: 5000
					ToolTip.visible: hovered
					ToolTip.text: modelData.text
					action: modelData
					checked: control.currentIndex === index
					autoExclusive: control.autoExclusive
					anchors.verticalCenter: parent.verticalCenter
					onClicked: control.currentIndex = index		
					display: ToolButton.IconOnly
				}
			}
		}
		
	}
	
	Component
	{
		id: _menuComponent
		
		Menu
		{
			closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
			
			Repeater
			{
				model: control.actions
				
				MenuItem
				{
					text:modelData.text
                    icon.name: modelData.icon.name
					autoExclusive: control.autoExclusive
					checked: index === control.currentIndex
					checkable: true
					onTriggered: 
					{
                        control.currentIndex = index
                    }
                }
			}
		}
	}
	
}
