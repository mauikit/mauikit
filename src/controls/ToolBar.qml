/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
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

import QtQuick 2.6
import QtQuick.Controls 2.2
import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "private"

ToolBar
{
    id: control
    property int preferredHeight: Maui.Style.toolBarHeight 
    implicitHeight: preferredHeight
    implicitWidth: mainFlickable.contentWidth
    spacing: Maui.Style.space.small
    padding: 0
    
//     property alias stickyRightContent : rightRowContent.sticky
//     property alias stickyLeftContent : leftRowContent.sticky
//     property alias stickyMiddleContent : middleRowContent.sticky
    
    property bool forceCenterMiddleContent : true
    
    property alias leftContent : leftRowContent.data
    property alias middleContent : middleRowContent.data
    property alias rightContent : rightRowContent.data
    
    property alias middleLayout : middleRowContent
    property alias leftLayout : leftRowContent
    property alias rightLayout : rightRowContent
    
    property alias layout : layout
    
    readonly property alias fits : _scrollView.fits
    
    property int margins: Maui.Style.space.medium
    readonly property int count : leftContent.length + middleContent.length + rightContent.length
    readonly property int visibleCount : leftRowContent.visibleChildren.length + middleRowContent.visibleChildren.length  + rightRowContent.visibleChildren.length 
    
    property bool flickable: true
    property bool strech : true
    property bool leftSretch: strech
    property bool rightSretch: strech
    property bool middleStrech: strech
    
    //    leftPadding: Kirigami.Units.smallSpacing*2
    //    rightPadding: Kirigami.Units.smallSpacing*2
    
    // 	background: Rectangle
    // 	{
    // 		id: headBarBG
    // 		color: colorScheme.backgroundColor
    // 		implicitHeight: Maui.Style.toolBarHeightAlt
    // 		radius: floating ? Maui.Style.radiusV : 0
    // 		border.color: floating ? colorScheme.borderColor : "transparent"
    //
    // 		SequentialAnimation on radius
    // 		{
    // 			ColorAnimation { to: colorScheme.backgroundColor ; duration: 1000 }
    // 		}
    //
    // 		Kirigami.Separator
    // 		{
    // 			visible: drawBorder
    // 			color: colorScheme.borderColor
    // 			height: Maui.Style.unit
    // 			anchors
    // 			{
    // 				left: parent.left
    // 				right: parent.right
    // 				bottom: control.position == ToolBar.Footer ? undefined : parent.bottom
    // 				top: control.position == ToolBar.Footer ? parent.top : undefined
    // 			}
    // 		}
    //
    // 		layer.enabled: dropShadow
    // 		layer.effect: DropShadow
    // 		{
    // 			anchors.fill: headBarBG
    // 			horizontalOffset: 0
    // 			verticalOffset:  Maui.Style.unit * (altToolBars ? -1 : 1)
    // 			radius: 8
    // 			samples: 25
    // 			color: Qt.darker(colorScheme.backgroundColor, 1.4)
    // 			source: headBarBG
    // 		}
    // 	}
    
    
    MouseArea
    {
        id: _rightFlickRec
        width: Maui.Style.iconSizes.medium
        height: parent.height
        visible: !mainFlickable.atXEnd && !control.fits && control.flickable
        hoverEnabled: true
        anchors
        {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        
        z: 999
        
        EdgeShadow
        {
            visible: true
            parent: parent
            edge: Qt.RightEdge
            anchors
            {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            
            opacity: 1
            
            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        Maui.Triangle
        {
            visible: !Kirigami.Settings.isMobile
            anchors.centerIn: parent
            rotation: -135
            color:  _rightFlickRec.hovered ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
            width: Maui.Style.iconSizes.tiny
            height:  width 
        }
        
        enabled: !mainFlickable.atXEnd
        opacity: enabled ? 1 : 0.4
        onClicked:
        {
            if(!mainFlickable.atXEnd)
            {
                mainFlickable.contentX += Math.min( mainFlickable.contentWidth - mainFlickable.contentX,  mainFlickable.contentWidth)
            }
            
            if(mainFlickable.atXEnd)
            {
                mainFlickable.returnToBounds()
            }
        }
        
    }
    
    MouseArea
    {
        id: _leftFlickRec
        width: Maui.Style.iconSizes.medium
        height: parent.height
        visible: !mainFlickable.atXBeginning && !control.fits && control.flickable
        hoverEnabled: true
        anchors
        {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        z: 999
        
        EdgeShadow
        {
            visible: true
            parent: parent
            edge: Qt.LeftEdge
            anchors
            {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            
            opacity: 1
            
            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        Maui.Triangle
        {
            visible: !Kirigami.Settings.isMobile
            anchors.centerIn: parent
            rotation: 45
            color:  _leftFlickRec.hovered ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
            width: Maui.Style.iconSizes.tiny
            height:  width 
        }
        
        enabled: !mainFlickable.atXBeginning
        opacity: enabled ? 1 : 0.4
        onClicked:
        {
            if(!mainFlickable.atXBeginning)
                mainFlickable.contentX -= control.height
                
                if(mainFlickable.atXBeginning)
                    mainFlickable.returnToBounds()
        }
    }
    
    Kirigami.WheelHandler
    {
        id: wheelHandler
        target: mainFlickable
    }
    
    ScrollView
    {
        id: _scrollView
        property bool fits : mainFlickable.contentWidth < control.width
        onFitsChanged: mainFlickable.returnToBounds()        
        
        height: control.implicitHeight
        width: control.width
              
        contentWidth: mainFlickable.contentWidth 
        contentHeight: height        
        
        states: [State 
        {
            when: control.position === ToolBar.Header
            
            AnchorChanges 
            {
                target: _scrollView
                anchors.top: undefined
                anchors.bottom: parent.bottom  
            }
        },
        
        State 
        {
            when: control.position === ToolBar.Footer
            
            AnchorChanges 
            {
                target: _scrollView
                anchors.top: parent.top
                anchors.bottom: undefined
            }
        }
        ]
     
     
//         ScrollBar.horizontal: ScrollBar
//         {
//             parent: _scrollView
//             x: 0
//             y: _scrollView.height - height
//             width: control.width
//             height: visible ? 2: 0
//             active: _scrollView.ScrollBar.horizontal || _scrollView.ScrollBar.horizontal.active
//         }
        
        ScrollBar.horizontal: ScrollBar {parent: _scrollView; visible: false}        
        ScrollBar.vertical: ScrollBar {parent: _scrollView; visible: false}        
        
        Flickable
        {
            id: mainFlickable
           
            anchors.fill: parent

            anchors.leftMargin: control.margins
            anchors.rightMargin: control.margins
         
            flickableDirection: Flickable.HorizontalFlick
            interactive: !fits && Maui.Handy.isTouch
            contentWidth: layout.implicitWidth
            
            boundsBehavior: Kirigami.Settings.isMobile ? Flickable.DragOverBounds : Flickable.StopAtBounds
            clip: true
            
            RowLayout
            {
                id: layout
                width: mainFlickable.width 
                height: mainFlickable.height
                
                RowLayout
                {
                    id: leftRowContent
//                     onVisibleChildrenChanged: visibleCount = visibleChildren.length
                    // 					visible: control.leftSretch && implicitWidth
                    property bool sticky : false                    
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    spacing: visibleChildren.length > 1 ? control.spacing : 0
                    Layout.minimumWidth: implicitWidth
                    Layout.fillWidth: implicitWidth && control.leftSretch
                    Layout.fillHeight: true
                }
                
                Item //helper to force center middle content
                {
                    visible: control.forceCenterMiddleContent && control.leftSretch
                    Layout.minimumWidth: 0
                    Layout.fillWidth: visible
                    Layout.maximumWidth: visible ? Math.max(rightRowContent.implicitWidth - leftRowContent.implicitWidth, 0) : 0
                }
                
                RowLayout
                {
                    id: middleRowContent
//                     onVisibleChildrenChanged: visibleCount = visibleChildren.length
                    property bool sticky : false
                    Layout.alignment: Qt.AlignCenter
                    spacing: visibleChildren.length > 1 ? control.spacing : 0
                    Layout.minimumWidth: implicitWidth                    
                    Layout.fillWidth: control.middleStrech
                    Layout.fillHeight: true
                }
                
                Item //helper to force center middle content
                {
                    visible: control.forceCenterMiddleContent && control.rightSretch
                    Layout.minimumWidth: 0
                    Layout.fillWidth: visible
                    Layout.maximumWidth: visible ? Math.max(leftRowContent.implicitWidth-rightRowContent.implicitWidth, 0) : 0
                }
                
                RowLayout
                {
                    id: rightRowContent
//                     onVisibleChildrenChanged: visibleCount = visibleChildren.length                    
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    spacing: visibleChildren.length > 1 ? control.spacing : 0
                    Layout.minimumWidth: implicitWidth
                    Layout.fillWidth: implicitWidth && control.rightSretch
                    Layout.fillHeight: true
                }
            }            
        }
    }
    
}
