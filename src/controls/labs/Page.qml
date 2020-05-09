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
//import QtQml 2.14
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
        property int footerPositioning : ListView.InlineFooter
        property int headerPositioning : Kirigami.Settings.isMobile && flickable ? ListView.PullBackHeader : ListView.InlineHeader
                
        property string title
        
        property int margins: 0
        property int leftMargin : margins
        property int rightMargin: margins
        property int topMargin: margins
        property int bottomMargin: margins
        
        property bool altHeader : false
        
        property bool autoHideHeader : false
        property bool autoHideFooter : false
        
        property int autoHideHeaderMargins : Maui.Style.toolBarHeight
        property int autoHideFooterMargins : Maui.Style.toolBarHeight
        
        property int autoHideFooterDelay : 1000
        property int autoHideHeaderDelay : 1000
        
        property bool floatingHeader : control.flickable && control.flickable.contentHeight > control.height && !altHeader ? !_private.flickableAtStart  : false     
        
        property bool floatingFooter: control.flickable
        
        QtObject
        {
            id: _private
            property bool flickableAtStart : control.flickable ? true : true
            
            property int topMargin : !control.altHeader ? (control.floatingHeader ? 0 : _headerContent.height) : 0
            property int bottomMargin: control.floatingFooter && control.footerPositioning === ListView.InlineFooter  ? control.bottomMargin : control.bottomMargin + _footerContent.height
            
            Behavior on topMargin
            {
                enabled: control.header.visible && control.headerPositioning === ListView.InlineHeader && control.floatingHeader
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
            
        }
        
        Binding 
        {
            delayed: false
            when: control.floatingFooter
            target: control.flickable
            property: "bottomMargin"
            value: control.flickable && control.footer.visible && control.footerPositioning === ListView.InlineFooter ? _footerContent.height : 0
//            restoreMode: Binding.RestoreBindingOrValue
        }        
        
        Connections
        {
            target: control.flickable
            enabled: control.flickable && control.flickable.contentHeight > _content.height
            
            onAtYBeginningChanged:
            {
                
                if(control.headerPositioning !== ListView.InlineHeader || !control.header.visible || control.altHeader || control.flickable.contentHeight <= control.height)
                {
                    return
                }
                
                if(control.flickable.atYBeginning && !control.floatingHeader)
                {
                    return
                }
                
                if(!control.flickable.atYBeginning && control.floatingHeader)
                {
                    return
                }
                
                if(_private.flickableAtStart === control.flickable.atYBeginning)
                {
                    return
                }
                 
                 _private.flickableAtStart = flickable.atYBeginning 
                 
                 console.log("AT START CHANGES", _private.flickableAtStart, control.flickable.atYBeginning, control.floatingHeader)
                 
            }
        }

        property bool showTitle : true
        property alias headBar : _headBar
        property alias footBar: _footBar   
        
        Kirigami.Theme.colorSet: Kirigami.Theme.View    
        
        signal goBackTriggered()
        signal goForwardTriggered()
        
        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
        }
        
        onFlickableChanged:
        {
//             control.flickable.bottomMargin += control.floatingFooter && control.footer.visible ? _footerContent.height : 0
             returnToBounds()
        }
              
        Connections
        {
            target: control.flickable ? control.flickable : null
            enabled: control.flickable && ((control.header && control.headerPositioning === ListView.PullBackHeader) || (control.footer &&  control.footerPositioning === ListView.PullBackFooter))
            property int oldContentY
            property bool updatingContentY: false
            
            onContentYChanged:
            {
                _headerAnimation.enabled = false
                _footerAnimation.enabled = false
                
                if(!control.flickable.dragging && control.flickable.atYBeginning)
                {
                    control.returnToBounds()
                }
                
                if (updatingContentY || !control.flickable || !control.flickable.dragging)
                {
                    oldContentY = control.flickable.contentY;
                    return;
                    //TODO: merge
                    //if moves but not dragging, just update oldContentY
                }
                
                if(control.flickable.contentHeight < control.height)
                {
                    return
                }
                
                var oldFHeight
                var oldHHeight
                
                if (control.footer && control.footerPositioning === ListView.PullBackFooter && control.footer.visible)
                {
                    oldFHeight = control.footer.height
                    control.footer.height = Math.max(0,
                                                     Math.min(control.footer.implicitHeight,
                                                              control.footer.height + oldContentY - control.flickable.contentY));
                }
                
                if (control.header && control.headerPositioning === ListView.PullBackHeader && control.header.visible && !control.altHeader)
                {
                    oldHHeight = control.header.height
                    control.header.height = Math.max(0,
                                                     Math.min(control.header.implicitHeight,
                                                              control.header.height + oldContentY - control.flickable.contentY));
                }
                
                //if the implicitHeight is changed, use that to simulate scroll
                if (control.header && oldHHeight !== control.header.height && control.header.visible && !control.altHeader)
                {
                    updatingContentY = true                    
                    control.flickable.contentY -= (oldHHeight - control.header.height)
                    updatingContentY = false
                        
                } else {
                    oldContentY = control.flickable.contentY
                }
            }
            
            onMovementEnded:
            {
                if (control.header && control.header.visible && control.headerPositioning === ListView.PullBackHeader && !control.altHeader)
                {
                    _headerAnimation.enabled = true                
                    
                    if (control.header.height >= (control.header.implicitHeight/2) || control.flickable.atYBeginning )
                    {
                        control.header.height =  control.header.implicitHeight
                        
                    } else
                    {
                        control.header.height = 0
                    }                        
                }
                
                if (control.footer && control.footer.visible && control.footerPositioning === ListView.PullBackFooter)
                {
                    _footerAnimation.enabled = true
                    
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
      /*  
        Component.onCompleted:
        {
            if(control.header && control.header instanceof Maui.ToolBar)
            {
                control.header.visible = header.visibleCount > 0
            }
        }*/
        
        property Item header : Maui.ToolBar
        {
            id: _headBar
            visible: visibleCount > 0
            width: visible ? parent.width : 0
            height: visible ? implicitHeight : 0
            
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Maui.Handy.isWindows ? Kirigami.Theme.View : Kirigami.Theme.Window
                        
              /** to not break the visible binding just check the count state of the header and act upon it **/
//             readonly property bool hide : visibleCount === 0 
//             onHideChanged:
//             {
//                 if(!header.visible)
//                 {
//                     return
//                 }
//                 
//                 if(hide)
//                 {
//                     pullBackHeader()
//                 }else
//                 {
//                     pullDownHeader()
//                 }
//             }
            
//             Label
//             {
//                 visible: false
//                 color: "yellow"
//                 text: _headBar.visibleCount + " / " + _headBar.count + " - " + _headBar.height + " / " + header.height + " - " + _headBar.visible + " / " + header.visible
//             }
                        
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
                    duration: Kirigami.Units.shortDuration
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
                visible: item
                Layout.fillWidth: sourceComponent === _titleComponent
                Layout.fillHeight: sourceComponent === _titleComponent
                sourceComponent: control.title && control.showTitle ? _titleComponent : null
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
                    opacity: 0.25
                    
                    transparentBorder: false 
                    source: ShaderEffectSource
                    {
                        samples : 0
                        recursive: true
                        sourceItem: _content
                        sourceRect: Qt.rect(0, 0-control.topMargin, headBar.width, headBar.height)
                    }
                    radius: 64				
                }
            }
            
        }
        
//           Label
//             {
// //                 visible: false
//                 z: 999999999999
//                 color: "yellow"
//                 text: _footBar.visibleCount + " / " + _footBar.count + " - " + _footBar.height + " / " + footer.height + " - " + _footBar.visible + " / " + footer.visible
//             }
        
        property Item footer : Maui.ToolBar
        {
            id: _footBar
            visible: visibleCount > 0
            width: visible ? parent.width : 0
            height: visible ? implicitHeight : 0
            
            position: ToolBar.Footer
            
            Behavior on height
            {
                id: _footerAnimation
                enabled: false
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
            
            background: Rectangle
            {
                color: _footBar.Kirigami.Theme.backgroundColor
             
                Kirigami.Separator
                {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
                
                FastBlur
                {
                    anchors.fill: parent				
                    visible: control.floatingFooter
                    opacity: 0.4
                    transparentBorder: false 
                    source: ShaderEffectSource
                    {
                        samples : 0
                        recursive: true
                        sourceItem: _content
                        sourceRect: Qt.rect(0, control.height - (footBar.height), footBar.width, footBar.height)
                    }
                    radius: 64				
                }
            }
        }  
        
        states: [  State 
        {
            when: !altHeader && header.visible
            
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
                target: _headBar
                position: ToolBar.Header        
            } 
        },
        
        State 
        {
            when: altHeader && header.visible
            
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
                target: header
                height: header.implicitHeight           
            } 
            
            PropertyChanges 
            {
                target: _headBar
                position: ToolBar.Footer        
            }
        } ]
        
      
        onAutoHideHeaderChanged: pullDownHeader()
        onAutoHideFooterChanged: pullDownFooter()
        onAltHeaderChanged: pullDownHeader()
        
        
        Column
        {
            id: _headerContent
            anchors.left: parent.left
            anchors.right: parent.right
            children: header
            z: _content.z+1
        }  
        
//         Label
//         {
//             anchors.centerIn: _headerContent
//             text: header.height + "/" + _headerContent.height + " - " + _layout.anchors.topMargin
//             color: "orange"
//             z: _headerContent.z + 1
//             visible: header.visible
//         }
        
        Item
        {
            id: _layout
            anchors.fill: parent 
            
            anchors.bottomMargin: control.altHeader ? _headerContent.height : 0
            anchors.topMargin: _private.topMargin
           
            Item
            {
                id: _content
                anchors.fill: parent
                anchors.margins: control.margins
                anchors.leftMargin: control.leftMargin
                anchors.rightMargin: control.rightMargin
                anchors.topMargin: control.topMargin
                anchors.bottomMargin: _private.bottomMargin      
            }   
            
            Column
            {
                id: _footerContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                children: footer
            }
        }   
        
        Timer
        {
            id: _autoHideHeaderTimer
            interval: autoHideHeaderDelay
            onTriggered: 
            {
                if(control.autoHideHeader && !control.altHeader)
                {
                    pullBackHeader()
                }
                
                stop()
            }
        }
        
        Timer
        {
            id: _autoHideFooterTimer
            interval: control.autoHideFooterDelay
            onTriggered: 
            {
                if(control.autoHideFooter)
                {
                    pullBackFooter()
                }
                
                stop()
            }
        }
      
        Item
        {
            anchors.top: parent.top            
            anchors.left: parent.left
            anchors.right: parent.right
            height: visible ? _headerContent.height + control.autoHideHeaderMargins : 0
            z: _content.z +1
            visible: control.autoHideHeader && !control.altHeader && !Kirigami.Settings.isMobile

            HoverHandler
            {
                target: parent                
                acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus
                
                onHoveredChanged:
                {
                    if(!control.autoHideHeader || control.altHeader)
                    {
                        _autoHideHeaderTimer.stop()
                        return
                    }
                    
                    if(!hovered)
                    {
                        _autoHideHeaderTimer.start()
                        
                    }else
                    {
                        pullDownHeader()
                        _autoHideHeaderTimer.stop()
                    }
                } 
            }
        }   
        
        Item
        {
            anchors.bottom: parent.bottom            
            anchors.left: parent.left
            anchors.right: parent.right
            height: visible ? _footerContent.height + control.autoHideFooterMargins : 0
            z: _footerContent.z - 1
            visible: control.autoHideFooter && !control.altHeader && !Kirigami.Settings.isMobile 

            HoverHandler
            {
                target: parent
                
                acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus
                
                onHoveredChanged:
                {
                    if(!control.autoHideFooter)
                    {
                        return
                    }
                    
                    if(!hovered)
                    {
                        _autoHideFooterTimer.start()
                        
                    }else
                    {
                        pullDownFooter()
                        _autoHideFooterTimer.stop()
                    }
                } 
            }
        }  
        
         
        
        //         Item
        //         {
        //             anchors.fill: parent
        //             anchors.topMargin: header.height
        //             anchors.bottomMargin: footer.height
        //             z: _content.z + 9999
        //             
        //             TapHandler
        //             {
        //                 target: parent
        //                 enabled: control.autoHideHeader && !control.altHeader 
        //                 
        //                 grabPermissions: PointerHandler.TakeOverForbidden | PointerHandler.ApprovesTakeOverByHandlersOfSameType | PointerHandler.CanTakeOverFromAnything
        //                 
        //                 onSingleTapped:
        //                 {
        //                     if(!control.autoHideHeader)
        //                     {
        //                         return
        //                     }
        //                     console.log("Pgae tapped")                
        //                     header.visible = !header.visible
        //                 }
        //             }
        //         }
        
        
        
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
                pullDownHeader()
            }            
            
            if(control.footer)
            {
                pullDownFooter()        
            }   
        }
        
        function pullBackHeader()
        {
            _headerAnimation.enabled = true
            header.height= 0
        }
        
        function pullDownHeader()
        {
            _headerAnimation.enabled = true
            header.height = header.implicitHeight           
        }
        
        function pullBackFooter()
        {
            _footerAnimation.enabled = true
            footer.height= 0
        }
        
        function pullDownFooter()
        {
            _footerAnimation.enabled = true            
            footer.height = footer.implicitHeight           
        }
        
       
}
