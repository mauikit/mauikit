import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.1

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Rectangle
{
	id: control
	implicitWidth: _layout.implicitWidth
	implicitHeight: _dummy.height - 2
	
	default property list<Action> actions
	Kirigami.Theme.inherit: false
	Kirigami.Theme.colorSet: Kirigami.Theme.Button
	
	property bool autoExclusive: true	
	
	property Action currentAction : actions[0]
	property int currentIndex : 0	
	onCurrentIndexChanged:
	{
        control.currentAction = actions[control.currentIndex]
    }
	
	property bool expanded : true	

	border.color: expanded ? Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7)) : "transparent"
    radius: Maui.Style.radiusV
    color: expanded ? Kirigami.Theme.backgroundColor : "transparent"
    
    ToolButton {id: _dummy}
    
	Row
	{
		id: _layout
		height: parent.height
		spacing: Maui.Style.space.small
		
		ToolButton
		{			
			visible: !control.expanded
			icon.name: control.currentAction ? control.currentAction.icon.name : "application-menu"
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
			spacing: 0
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
                id: _repeater
                model: control.actions
                
                MouseArea
                {
                    id: _buttonMouseArea
                    property Action action : modelData
                    property bool checked: control.currentIndex === index
                    property bool autoExclusive: control.autoExclusive
                    hoverEnabled: true
                    width: height + Maui.Style.space.medium
                    height: parent.height
                    
                    onClicked: 
                    {
                        control.currentIndex = index	
                        action.triggered()
                    }
                    
                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible:  _buttonMouseArea.containsMouse || _buttonMouseArea.containsPress
                    ToolTip.text: modelData.text
                    
                    Rectangle
                    {
                        anchors.fill: parent
                        color: checked || _buttonMouseArea.containsMouse || _buttonMouseArea.containsPress ? Kirigami.Theme.highlightColor : "transparent"
                        opacity: 0.15
                    }
                    
                    Kirigami.Icon
                    {
                        anchors.centerIn: parent
                        width: Maui.Style.iconSizes.medium
                        height: width
                        color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        source: action.icon.name
                    }
                    
                    Kirigami.Separator
                    {
                        color: control.border.color
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        visible: index < _repeater.count-1
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
                        modelData.triggered()                        
                    }
                }
			}
		}
	}
	
}
