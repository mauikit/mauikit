import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.14

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "private" as Private

Rectangle
{
    id: control
    implicitWidth: _loader.item ? _loader.item.implicitWidth : 0
    implicitHeight: Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.12)
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    default property list<Action> actions
    
    property bool autoExclusive: true
    property bool checkable: true
    property int display: ToolButton.IconOnly
    
    property Action currentAction : control.autoExclusive ? actions[0] : null
    property int currentIndex : -1
    onCurrentIndexChanged:
    {
        if(control.autoExclusive)
        {
            control.currentAction = actions[control.currentIndex]
        }
    }
    
    property bool expanded : true
    property string defaultIconName: "application-menu"
    
    border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
    radius: Maui.Style.radiusV
    color: enabled ? Kirigami.Theme.backgroundColor : "transparent"
//    Kirigami.Theme.colorSet: Kirigami.Theme.View
//    Kirigami.Theme.inherit: false
    
    Component.onCompleted:
    {
        if(control.checkable && control.autoExclusive && control.currentIndex >= 0 && control.currentIndex < control.actions.length)
        {
            control.actions[control.currentIndex].checked = true
        }        
    }
    
    function uncheck(except)
    {
        for(var i in control.actions)
        {
            if(control.actions[i] === except)
            {
                continue
            }
            
            control.actions[i].checked = false
        }
    }
    
    Loader
    {
        id: _loader
        height: parent.height
        sourceComponent: control.expanded ? _rowComponent : _menuComponent
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
                
                Private.BasicToolButton
                {
                    id: _buttonMouseArea
                    action : modelData
                    checkable: control.checkable
                    Binding on checked
                    {
                        when: autoExclusive
                        value: control.currentIndex === index
                    }
                    autoExclusive: control.autoExclusive
                    width: implicitWidth
                    height: parent.height
                    enabled: action.enabled
                    opacity: enabled ? 1 : 0.5
                    display: control.autoExclusive ? (checked && control.enabled ? control.display : ToolButton.IconOnly) : control.display
                    icon.name: action.icon.name
                    icon.width:  action.icon.width ?  action.icon.width : Maui.Style.iconSizes.small
                    icon.height:  action.icon.height ?  action.icon.height : Maui.Style.iconSizes.small
                    
                    rec.border.color: "transparent"                    
                   
                    onClicked:
                    {
                        if(autoExclusive)
                            control.currentIndex = index
                    }
                    
                    Kirigami.Separator
                    {
                        color: control.border.color
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        visible: index < _repeater.count-1
                        anchors.topMargin:1
                        anchors.bottomMargin: 1
                    }
                }
            }
        }
    }
    
    Component
    {
        id: _menuComponent
        
        MouseArea
        {
            id: _defaultButtonMouseArea
            hoverEnabled: true
            width: implicitWidth
            implicitWidth: height + Maui.Style.space.tiny + Maui.Style.iconSizes.small

            onClicked:
            {
                if(!_menu.visible)
                {
                    _menu.popup(control, 0, control.height)

                }else
                {
                    _menu.close()
                }
            }

            Menu
            {
                id: _menu
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                Repeater
                {
                    model: control.actions

                    MenuItem
                    {
                        text: modelData.text
                        icon.name: modelData.icon.name
                        autoExclusive: control.autoExclusive
                        checked: index === control.currentIndex && control.checkable
                        checkable: control.checkable
                        onTriggered:
                        {
                            control.currentIndex = index
                            modelData.triggered()
                        }
                    }
                }
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

                    Private.BasicToolButton
                    {
                        id: _defaultButtonIcon
                        onClicked:
                        {
                            if(!_menu.visible)
                            {
                               _menu.popup(control, 0, control.height)

                            }else
                            {
                                _menu.close()
                            }
                        }

                        anchors.centerIn: parent
                        icon.width: Maui.Style.iconSizes.small
                        icon.height: Maui.Style.iconSizes.small
                        icon.color: control.currentAction ? (control.currentAction.icon.color && control.currentAction.icon.color.length ? control.currentAction.icon.color : ( _defaultButtonMouseArea.containsPress ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor)) :  control.Kirigami.Theme.textColor

                        icon.name: control.currentAction ? control.currentAction.icon.name : control.defaultIconName

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
                        color: _defaultButtonIcon.icon.color
                        width: Maui.Style.iconSizes.tiny-3
                        height:  width
                    }
                }
            }
        }
    }
}
