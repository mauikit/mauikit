import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.14
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "private" as Private

/**
 * ToolActions
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Rectangle
{
    id: control
    implicitWidth: _loader.item ? _loader.item.implicitWidth : 0
    implicitHeight: Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.12)
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    
    /**
     * actions : list<Action>
     */
    default property list<Action> actions
    
    /**
     * autoExclusive : bool
     */
    property bool autoExclusive: true
    
    /**
     * checkable : bool
     */
    property bool checkable: true
    
    /**
     * display : int
     */
    property int display: ToolButton.IconOnly
    
    /**
     * cyclic : bool
     */
    property bool cyclic: false
    
    /**
     * count : int
     */
    readonly property int count : actions.length
    
    /**
     * currentAction : Action
     */
    property Action currentAction : control.autoExclusive ? actions[0] : null
    
    /**
     * currentIndex : int
     */
    property int currentIndex : -1
    onCurrentIndexChanged:
    {
        if(control.autoExclusive)
        {
            control.currentAction = actions[control.currentIndex]
        }
    }
    
    /**
     * expanded : bool
     */
    property bool expanded : true
    
    /**
     * defaultIconName : string
     */
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
    
    /**
     * 
     */
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
    
    Item
    {
        id: _container
        anchors.fill: parent
        Loader
        {
            id: _loader
            height: parent.height
            sourceComponent: control.expanded ? _rowComponent : _menuComponent
        } 
        
        layer.enabled: true
        layer.effect: OpacityMask
        {
            maskSource: Item
            {
                width: Math.floor(_container.width)
                height: Math.floor(_container.height)
                
                Rectangle
                {
                    anchors.fill: parent
                    radius: control.radius
                }
            }
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
                
                Private.BasicToolButton
                {
                    id: _buttonMouseArea
                    action : modelData
                    checkable: control.checkable
                    rec.radius: 0
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
            implicitWidth: _defaultButtonLayout.implicitWidth
            
            function triggerAction()
            {
                if(control.cyclic && control.autoExclusive)
                {
                    const index = control.currentIndex + 1
                    control.currentIndex = index >= control.actions.length ? 0 : index
                    control.currentAction.triggered()
                    return
                }
                
                if(!_menu.visible)
                {
                    _menu.popup(control, 0, control.height)
                    
                }else
                {
                    _menu.close()
                }
            }
            
            onClicked: triggerAction()
            
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
                id: _defaultButtonLayout
                height: parent.height
                spacing: 0
                
                Private.BasicToolButton
                {
                    id: _defaultButtonIcon
                    Layout.fillHeight: true
                    
                    onClicked: triggerAction()
                    
                    icon.width: Maui.Style.iconSizes.small
                    icon.height: Maui.Style.iconSizes.small
                    icon.color: buttonAction() ? (buttonAction().icon.color && buttonAction().icon.color.length ? buttonAction().icon.color : ( _defaultButtonMouseArea.containsPress ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor)) :  control.Kirigami.Theme.textColor
                    
                    icon.name: buttonAction() ? buttonAction().icon.name : control.defaultIconName
                    
                    enabled: buttonAction() ? buttonAction().enabled : true
                    
                    function buttonAction()
                    {
                        if(control.cyclic && control.autoExclusive)
                        {
                            const index = control.currentIndex + 1
                            return control.actions[index >= control.actions.length ? 0 : index]
                        }else
                        {
                            return control.currentAction
                        }
                    }
                }
                
                Kirigami.Separator
                {
                    visible: !control.cyclic
                    color: control.border.color
                    Layout.fillHeight: true
                }
                
                Item
                {
                    visible: !control.cyclic
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
