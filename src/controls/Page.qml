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

import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

Pane
{
    id: control
    focus: true
    
    padding: 0
    leftPadding: control.padding
    rightPadding: control.padding
    topPadding: control.padding
    bottomPadding: control.padding
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    
    default property alias content: _content.data
        property alias headerBackground : _headerBackground
        readonly property alias internalHeight : _content.height
        property Flickable flickable : null
        property int footerPositioning : ListView.InlineFooter
        property int headerPositioning : Kirigami.Settings.isMobile && flickable ? ListView.PullBackHeader : ListView.InlineHeader
        
        property string title
        property bool showTitle : true
        
        property alias headBar : _headBar
        property alias footBar: _footBar
        
        property alias footerColumn : _footerContent.data
        property alias headerColumn : _headerContent.data
        
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
        
        //    property bool floatingHeader : control.flickable && !control.flickable.atYBeginning 
        property bool floatingHeader : false
        
        property bool floatingFooter: control.flickable
        
        signal goBackTriggered()
        signal goForwardTriggered()
        
        QtObject
        {
            id: _private
            property int topMargin : !control.altHeader ? (control.floatingHeader ? 0 : _headerContent.height) : 0
            property int bottomMargin: control.floatingFooter && control.footerPositioning === ListView.InlineFooter  ? control.bottomMargin : control.bottomMargin + _footerContent.implicitHeight
        }
        
        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
        }
        
        onFlickableChanged:
        {
            flickable.bottomMargin = Qt.binding(function() { return control.floatingFooter && control.footerPositioning === ListView.InlineFooter ? _footerContent.implicitHeight : 0 })
            
            //         flickable.topMargin = Qt.binding(function() { return control.floatingHeader && this.atYBeginning && control.header.visible && control.headerPositioning === ListView.InlineHeader && !control.altHeader ? _headerContent.height: 0 })
            
            returnToBounds()
        }
        
        Connections
        {
            target: control.flickable ? control.flickable : null
            ignoreUnknownSignals: true
            enabled: control.flickable && ((control.header && control.headerPositioning === ListView.PullBackHeader) || (control.footer &&  control.footerPositioning === ListView.PullBackFooter))
            property int oldContentY
            property bool updatingContentY: false
            
            function onContentYChanged()
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
            
            function onMovementEnded()
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
        
        property Item header : Maui.ToolBar
        {
            id: _headBar
            visible: visibleCount > 0
            width: visible ? parent.width : 0
            height: visible ? implicitHeight : 0
            
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Maui.Handy.isWindows ? Kirigami.Theme.View : Kirigami.Theme.Window
            
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
            
            Component
            {
                id: _titleComponent
                Label
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: control.title
                    elide : Text.ElideRight
                    font.bold : true
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
                active: control.title && control.showTitle
                sourceComponent: _titleComponent
            }
            
            background: Rectangle
            {
                id: _headerBackground
                color: _headBar.Kirigami.Theme.backgroundColor
                
                Maui.Separator
                {
                    id: _border
                    position: Qt.Horizontal
                    color: parent.color
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
                
                FastBlur
                {
                    anchors.fill: parent
                    visible: control.floatingHeader && !altHeader
                    opacity: 0.25
                    cached: false
                    radius: 64
                    transparentBorder: false
                    source: ShaderEffectSource
                    {
                        samples : 2
                        recursive: false
                        textureSize: Qt.size(headBar.width * 0.2, headBar.height * 0.2)
                        sourceItem: _content
                        sourceRect: Qt.rect(0, 0-control.topMargin, headBar.width, headBar.height)
                    }
                    
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
                
                Maui.Separator
                {
                    position: Qt.Horizontal
                    color: parent.color
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
                
                FastBlur
                {
                    anchors.fill: parent
                    visible: control.floatingFooter
                    opacity: 0.25
                    transparentBorder: false
                    source: ShaderEffectSource
                    {
                        samples : 2
                        recursive: false
                        textureSize: Qt.size(footBar.width * 0.2, footBar.height * 0.2)
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
        
        onAutoHideHeaderChanged:
        {
            if(autoHideHeader)
            {
                _autoHideHeaderTimer.start()
            } else
            {
                pullDownHeader()
                _autoHideHeaderTimer.stop()
            }
        }
        onAutoHideFooterChanged:
        {
            if(autoHideFooter)
            {
                _autoHideFooterTimer.start()
            } else
            {
                pullDownFooter()
                _autoHideFooterTimer.stop()
            }
        }
        onAltHeaderChanged: pullDownHeader()
        
        
        //                 Label
        //                 {
        //                     anchors.centerIn: _headerContent
        //                     text: header.height + "/" + _headerContent.height + " - " + _layout.anchors.topMargin
        //                     color: "orange"
        //                     z: _headerContent.z + 1
        //                     visible: header.visible
        //                 }
        //                 
        //                    Label
        //                 {
        //                     anchors.centerIn: _footerContent
        //                     text: footer.height + "/" + _footerContent.height + " - " + _layout.anchors.topMargin
        //                     color: "orange"
        //                     z: _footerContent.z + 9999
        //                 }
        
        Column
        {
            id: _headerContent
            anchors.left: parent.left
            anchors.right: parent.right
            z: _content.z+1
        }
        
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
            }
        }
        
        Timer
        {
            id: _revealHeaderTimer
            interval: autoHideHeaderDelay
            
            onTriggered:
            {
                pullDownHeader()
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
                        _revealHeaderTimer.stop()
                        
                    }else
                    {
                        _autoHideHeaderTimer.stop()
                        _revealHeaderTimer.start()
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
        
        Component.onCompleted :
        {
            if(footer)
            {
                _footerContent.data.push(footer)
            }
            
            if(header)
            {
                _headerContent.data.push(header)
            }
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
            if(Maui.Handy.isTouch) 
                return
                
                _headerAnimation.enabled = true
                header.height = 0
        }
        
        function pullDownHeader()
        {            
            _headerAnimation.enabled = true
            header.height = header.implicitHeight
        }
        
        function pullBackFooter()
        {
            if(Maui.Handy.isTouch) 
                return
                
                _footerAnimation.enabled = true
                footer.height= 0
        }
        
        function pullDownFooter()
        {
            _footerAnimation.enabled = true
            footer.height = footer.implicitHeight
        }
}
