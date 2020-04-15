/*
 *   Copyright 2019 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Pane
{
    id: control
    focus: true
    
    padding: 0
    leftPadding: control.padding
    rightPadding: control.padding
    topPadding: control.padding
    bottomPadding: control.padding
    
    default property alias content: _content.data
        property alias headerBackground : _headerBackground
        readonly property alias internalHeight : _content.height
        property Flickable flickable : null
        property int footerPositioning : Kirigami.Settings.isMobile && flickable ? ListView.PullBackHeader : ListView.InlineFooter
        property int headerPositioning : Kirigami.Settings.isMobile && flickable ? ListView.PullBackHeader : ListView.InlineHeader
        
        property string title
        
        property int margins: 0
        property int leftMargin : margins
        property int rightMargin: margins
        property int topMargin: margins
        property int bottomMargin: margins
        
        property bool altHeader : false
        property bool autoHideHeader : false
        onAutoHideHeaderChanged: header.opacity = 1
        property bool floatingHeader : false    
        property bool showTitle : true
        
        Kirigami.Theme.colorSet: Kirigami.Theme.View    
        
        signal goBackTriggered()
        signal goForwardTriggered()
        
        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
        }
        
        onFlickableChanged: returnToBounds()
        
        Connections
        {
            target: control.flickable ? control.flickable : null
            enabled: control.flickable && ((control.header && control.headerPositioning === ListView.PullBackHeader) || (control.footer &&  control.footerPositioning === ListView.PullBackFooter))
            property int oldContentY
            property bool updatingContentY: false
            
            onContentYChanged:
            {
                _headerAnimation.enabled = false
                if(!control.flickable.dragging && control.flickable.atYBeginning)
                    control.returnToBounds()
                    
                    if (updatingContentY || !control.flickable || !control.flickable.dragging)
                    {
                        oldContentY = control.flickable.contentY;
                        return;
                        //TODO: merge
                        //if moves but not dragging, just update oldContentY
                    }
                    
                    if(control.flickable.contentHeight < control.height)
                        return
                        
                        var oldFHeight
                        var oldHHeight
                        
                        if (control.footer && control.footerPositioning === ListView.PullBackFooter)
                        {
                            oldFHeight = control.footer.height
                            control.footer.height = Math.max(0,
                                                             Math.min(control.footer.implicitHeight,
                                                                      control.footer.height + oldContentY - control.flickable.contentY));
                        }
                        
                        if (control.header && control.headerPositioning === ListView.PullBackHeader)
                        {
                            oldHHeight = control.header.height
                            control.header.height = Math.max(0,
                                                             Math.min(control.header.implicitHeight,
                                                                      control.header.height + oldContentY - control.flickable.contentY));
                        }
                        
                        //if the implicitHeight is changed, use that to simulate scroll
                        if ((control.footer && oldFHeight !== control.footer.height) || ( control.header && oldHHeight !== control.header.height))
                        {
                            updatingContentY = true
                            
                            if(control.header && oldHHeight !== control.header.height)
                                control.flickable.contentY -= (oldHHeight - control.header.height)
                                updatingContentY = false
                                
                        } else {
                            oldContentY = control.flickable.contentY
                        }
            }
            
            onMovementEnded:
            {
                _headerAnimation.enabled = true
                if (control.headerPositioning === ListView.PullBackHeader  && control.header)
                {
                    if (control.header.height >= (control.header.implicitHeight/2) || control.flickable.atYBeginning )
                    {
                        control.header.height =  control.header.implicitHeight
                        
                    } else
                    {
                        control.header.height = 0
                    }
                    
                }
                
                if (control.footerPositioning === ListView.PullBackFooter  && control.footer)
                {
                    if (control.footer.height >= (control.footer.implicitHeight/2) ||  control.flickable.atYEnd)
                    {
                        if(control.flickable.atYEnd)
                        {
                            control.footer.height =  control.footer.implicitHeight
                            
                            control.flickable.contentY = control.flickable.contentHeight - control.flickable.height
                            oldContentY = control.flickable.contentY
                        }else
                        {
                            control.footer.height =  control.footer.implicitHeight
                            
                        }
                        
                    } else
                    {
                        control.footer.height = 0
                    }
                }
            }
        }
        
        property alias headBar : _headBar
        property alias footBar: _footBar        
        
        property Item header : Maui.ToolBar
        {
            id: _headBar
            visible: count > 1
            width: visible ? parent.width : 0
            height: visible ? implicitHeight : 0
            position: ToolBar.Header
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            
            Behavior on height
            {
                id: _headerAnimation
                enabled: false
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
            
            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            
            Component
            {
                id: _titleComponent
                Label
                {
                    text: control.title
                    elide : Text.ElideRight
                    font.bold : false
                    font.weight: Font.Bold
                    color : Kirigami.Theme.textColor
                    font.pointSize: Maui.Style.fontSizes.big
                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment :  Text.AlignVCenter
                }
            }
            
            middleContent: Loader
            {
                Layout.fillWidth: sourceComponent === _titleComponent
                Layout.fillHeight: sourceComponent === _titleComponent
                sourceComponent: control.title && control.showTitle ? _titleComponent : undefined
            }
            
            background: Rectangle
            {
                id: _headerBackground
                color: _headBar.Kirigami.Theme.backgroundColor
                
                Kirigami.Separator
                {
                    id: _border  
                    opacity: 0.6
                    color: Qt.darker(parent.color, 2)                    
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
                
                Kirigami.Separator
                {
                    id: _border2  
                    opacity: 0.4             
                    color: Qt.lighter(parent.color, 2.5)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottomMargin: 1
                }
                
                FastBlur
                {
                    anchors.fill: parent				
                    visible: control.floatingHeader && !altHeader
                    opacity: 0.2
                    
                    transparentBorder: false 
                    source: ShaderEffectSource
                    {
                        //                                         cullMode: ShaderEffect.FrontFaceCulling 
                        //                     hideSource: true
                        samples : 0
                        recursive: true
                        sourceItem: _content
                        sourceRect: Qt.rect(0, 0-control.topMargin, headBar.width, headBar.height)
                        // 					textureSize: Qt.size(headBar.width,headBar.height) 
                    }
                    radius: 64				
                }
            }
            
        }
        
        property Item footer : Maui.ToolBar
        {
            id: _footBar
            visible: count
            position: ToolBar.Footer
            width: visible ? parent.width : 0
            height: visible ? implicitHeight : 0
        }     
        
        Item
        {
            id: _headerContent
            anchors.left: parent.left
            anchors.right: parent.right
            height: header && header.visible ? header.height : 0
            data: header ? [header] : []
            z: _content.z+1
        }    
        
        states: [  State 
        {
            name: "topHeader"
            when: !altHeader
            
            AnchorChanges 
            {
                target: _headerContent
                anchors.top: parent.top
                anchors.bottom: undefined  
            }
            
            AnchorChanges 
            {
                target: _border
                anchors.top: undefined
                anchors.bottom: parent.bottom
            }
            
            AnchorChanges 
            {
                target: _border2
                anchors.top: undefined
                anchors.bottom: parent.bottom
            }
            
            PropertyChanges 
            {
                target: _layout
                anchors.topMargin: control.floatingHeader ? 0 : _headerContent.height 
                anchors.bottomMargin: 0           
            }    
            
            PropertyChanges 
            {
                target: _headBar
                position: ToolBar.Header        
            } 
        },
        
        State 
        {
            name: "bottomHeader"
            when: altHeader
            
            AnchorChanges 
            {
                target: _headerContent
                anchors.top: undefined
                anchors.bottom: parent.bottom
            }    
            
            AnchorChanges 
            {
                target: _border
                anchors.top: parent.top
                anchors.bottom: undefined
            }
            
            AnchorChanges 
            {
                target: _border2
                anchors.top: parent.top
                anchors.bottom: undefined
            }
            
            PropertyChanges 
            {
                target: _layout
                anchors.topMargin: 0
                anchors.bottomMargin: _headerContent.height            
            } 
            
            PropertyChanges 
            {
                target: _headBar
                position: ToolBar.Footer        
            } 
                        
        } ]
        
        //        transitions: Transition {
        //         // smoothly reanchor myRect and move into new position
        //         AnchorAnimation { duration: 1000 }
        //     }
        
        
        
        ColumnLayout
        {
            id: _layout
            anchors.fill: parent            
            spacing: 0       
            
            Item
            {
                id: _content
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: control.margins
                Layout.leftMargin: control.leftMargin
                Layout.rightMargin: control.rightMargin
                Layout.topMargin: control.topMargin
                Layout.bottomMargin: control.bottomMargin
            }   
            
            Item
            {
                id: _footerContent
                Layout.fillWidth: true
                Layout.preferredHeight:  footer && footer.visible ? footer.height : 0
                visible: footer && footer.visible
                data: footer ? [footer] : []
            }
        }   
        
        Timer
        {
            id: _timer
            interval: 1000
            onTriggered: 
            {
                if(control.autoHideHeader)
                {
                    header.visible = false
                }
                
                stop()
            }
        }
        
        HoverHandler
        {
            target: parent
            enabled: control.autoHideHeader && !control.altHeader && !Kirigami.Settings.isMobile
            acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus
            
            onHoveredChanged:
            {
                if(!control.autoHideHeader)
                {
                    return
                }
                
                if(!hovered)
                {
                    _timer.start()
                    
                }else
                {
                    header.visible = true
                    _timer.stop()
                }
            } 
        }
        
        TapHandler
        {
            enabled: control.autoHideHeader && !control.altHeader 
            
            grabPermissions: PointerHandler.TakeOverForbidden | PointerHandler.ApprovesTakeOverByHandlersOfSameType | PointerHandler.CanTakeOverFromAnything
            
            onSingleTapped:
            {
                if(!control.autoHideHeader)
                {
                    return
                }
                console.log("Pgae tapped")                
                header.visible = !header.visible
            }
        }
        
        Keys.onBackPressed:
        {
            control.goBackTriggered();
        }
        
        Shortcut
        {
            sequence: "Forward"
            onActivated: control.goForwardTriggered();
        }
        
        Shortcut
        {
            sequence: StandardKey.Forward
            onActivated: control.goForwardTriggered();
        }
        
        Shortcut
        {
            sequence: StandardKey.Back
            onActivated: control.goBackTriggered();
        }
        
        function returnToBounds()
        {
            if(control.header)
            {
                control.header.height = control.header.implicitHeight
            }            
            
            if(control.footer)
            {
                control.footer.height = control.footer.implicitHeight            
            }           
        }
}
