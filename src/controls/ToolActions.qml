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
    implicitHeight: Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.12)
    
    default property list<Action> actions
    
    property bool autoExclusive: true	
    property bool checkable: true
    
    property Action currentAction : actions[0]
    property int currentIndex : 0	
    onCurrentIndexChanged:
    {
        control.currentAction = actions[control.currentIndex]
    }
    
    property bool expanded : true	
    
    border.color:  Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
    radius: Maui.Style.radiusV
    color: expanded ? Kirigami.Theme.backgroundColor : "transparent"
       
    Row
    {
        id: _layout
        height: parent.height
        spacing: 0
        
        MouseArea
        {
            id: _defaultButtonMouseArea
            hoverEnabled: true
            width: height + Maui.Style.space.tiny + Maui.Style.iconSizes.small
            height: parent.height
            
            visible: !control.expanded
            anchors.verticalCenter: parent.verticalCenter
            onClicked: 
            {
                if(!_loader.item.visible)
                    _loader.item.popup(control, 0, control.height)
                    else
                        _loader.item.close()
            }  
            
            Rectangle
            {
                anchors.fill: parent
                color: control.currentAction ? (control.currentAction.enabled && (_defaultButtonMouseArea.containsMouse || _defaultButtonMouseArea.containsPress) ? Kirigami.Theme.highlightColor : "transparent") : "transparent"
                opacity: 0.15
                radius: control.radius
            }
            
            RowLayout
            {
                anchors.fill: parent
                spacing: 0
                Item
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    Kirigami.Icon
                    {
                        id: _defaultButtonIcon
                        
                        anchors.centerIn: parent
                        width: Maui.Style.iconSizes.medium
                        height: width
                        color: control.currentAction ? (control.currentAction .icon.color && control.currentAction.icon.color.length ? control.currentAction.icon.color : ( _defaultButtonMouseArea.containsPress ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor)) :  control.Kirigami.Theme.textColor
                        
                        source: control.currentAction ? control.currentAction.icon.name : "application-menu"
                        
                        enabled: control.currentAction ? control.currentAction.enabled : true
                    }  
                }
                
                Kirigami.Separator
                {
                    color: control.border.color
                    Layout.fillHeight: true
                    visible: _defaultButtonMouseArea.visible
                }
                
                Item
                {
                    visible: _defaultButtonMouseArea.visible
                    Layout.fillHeight: true
                    Layout.preferredWidth: visible ? Maui.Style.iconSizes.small : 0
                    
                    Maui.Triangle
                    {
                        anchors.centerIn: parent
                        rotation: -45
                        color: _defaultButtonIcon.color
                        width: Maui.Style.iconSizes.tiny-3
                        height:  width 
                    }	
                }
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
                    property bool checked: control.checkable && control.autoExclusive ? control.currentIndex === index : action.checked
                    hoverEnabled: true
                    width: height + Maui.Style.space.tiny
                    height: parent.height
                    enabled: action.enabled
                    opacity: enabled ? 1 : 0.5

                    onClicked: 
                    {
                        control.currentIndex = index	
                        if(control.checkable && !control.autoExclusive)
                        {
                            checked = !checked
                        }
                        
                        action.triggered()
                    }
                    
                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible:  (_buttonMouseArea.containsMouse || _buttonMouseArea.containsPress) && modelData.text
                    ToolTip.text: modelData.text
                    
                    Rectangle
                    {
                        anchors.fill: parent
                        color: action.enabled && (_buttonMouseArea.checked || _buttonMouseArea.containsMouse || _buttonMouseArea.containsPress) ? Kirigami.Theme.highlightColor : "transparent"
                        opacity: 0.15
                    }
                    
                    Kirigami.Icon
                    {
                        anchors.centerIn: parent
                        width: Maui.Style.iconSizes.medium
                        height: width
                        color: (action.icon.color && action.icon.color.length ) ? action.icon.color : ( (_buttonMouseArea.checked || _buttonMouseArea.containsPress) && enabled ) ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                        source: action.icon.name
                        enabled: action.enabled
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
