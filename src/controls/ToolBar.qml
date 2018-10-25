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
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "private"

ToolBar
{
    id: control    
    
    /* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
    
    clip: true
    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
	implicitHeight: floatingFootBar ? toolBarHeightAlt : toolBarHeight
	
	width: floatingFootBar ?  implicitWidth : parent.width
    height: implicitHeight
    
	property alias leftContent : leftRowContent.data
    property alias middleContent : middleRowContent.data
    property alias rightContent : rightRowContent.data
    property alias middleLayout : flickableLayout
    property alias layout : layout
    
    property int margins: space.medium
    spacing: space.big
    property int count : leftContent.length + middleContent.length + rightContent.length
    
    property bool dropShadow: false
    property bool drawBorder: false
    property bool floatingFootBar: false
 
    padding: 0    
    //    leftPadding: Kirigami.Units.smallSpacing*2
    //    rightPadding: Kirigami.Units.smallSpacing*2
    
    
    background: Rectangle
    {
		id: headBarBG
		color: colorScheme.backgroundColor
		implicitHeight: toolBarHeightAlt  
		radius: floatingFootBar ? radiusV : 0   
		border.color: floatingFootBar ? colorScheme.borderColor : "transparent"
		
		Kirigami.Separator
		{
			visible: drawBorder
			color: colorScheme.borderColor
			height: unit
			anchors
			{
				left: parent.left
				right: parent.right
				bottom: control.position == ToolBar.Footer ? undefined : parent.bottom
				top: control.position == ToolBar.Footer ? parent.top : undefined
			}
		}
		
		layer.enabled: dropShadow
		layer.effect: DropShadow
		{
			anchors.fill: headBarBG
			horizontalOffset: 0
			verticalOffset:  unit * (altToolBars ? -1 : 1)
			radius: 8
			samples: 25
			color: Qt.darker(colorScheme.backgroundColor, 1.4)
			source: headBarBG
		}
	}
    
    Rectangle
    {
        width: parent.height 
        height: iconSizes.tiny
        visible: !mainFlickable.atXEnd && mainFlickable.interactive
        rotation: 270
        opacity: 0.2
        anchors 
        {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        z: 999
        
        gradient: Gradient
        {
            GradientStop
            {
                position: 0.0
                color: "transparent"
            }
            GradientStop 
            {
                position: 1.0
                color: colorScheme.textColor
            }
        }        
    }
    
    Rectangle
    {
        width: parent.height
        height: iconSizes.tiny
        visible: !mainFlickable.atXBeginning && mainFlickable.interactive
        rotation: 270
        opacity: 0.2
        anchors 
        {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        z: 999
        
        gradient: Gradient 
        {
            GradientStop
            {
                position: 0.0
                color: colorScheme.textColor
            }
            
            GradientStop
            {
                position: 1.0
                color: "transparent"
            }
        }            
    }
    
    
    Flickable
    {
        id: mainFlickable       
                
        flickableDirection: Flickable.HorizontalFlick
        anchors.fill: parent
        interactive: layout.implicitWidth > control.width
        contentWidth: layout.implicitWidth
        boundsBehavior: isMobile ? Flickable.DragOverBounds : Flickable.StopAtBounds
        clip: true
        
        RowLayout
        {
            id: layout
            width: control.width
            height: control.height
            
            Row
            {
                id: leftRowContent
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.leftMargin: leftContent.length > 0 ? margins : 0
                spacing: leftContent.length > 0 ? control.spacing : 0
                Layout.minimumWidth: 0
                clip: true
            }
            
            Kirigami.Separator
            {
                Layout.fillHeight: true
                Layout.margins: 0
                Layout.topMargin: space.big
                Layout.bottomMargin: space.big
                width: unit
                opacity: 0.2
                visible: leftContent.length > 0 && flickable.interactive
                color: colorScheme.textColor    
                
                gradient: Gradient
                {
                    GradientStop
                    {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop 
                    {
                        position: 0.5
                        color: colorScheme.textColor
                    }
                    
                    GradientStop 
                    {
                        position: 1.0
                        color: "transparent"
                    }
                }
                
            }
            
            Item
            {
                id: flickableItem
                Layout.fillHeight: true
                Layout.fillWidth: true
//                 Layout.minimumWidth: control.width * 0.3
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.rightMargin: middleContent.length === 1 ? 0 : margins
                Layout.leftMargin: middleContent.length === 1 ? 0 : margins
                
                Flickable
                {
                    id: flickable
                    
                    anchors.fill: parent
                    flickableDirection: Flickable.HorizontalFlick
                    
                    interactive: middleRowContent.implicitWidth > width
                    contentWidth: middleRowContent.implicitWidth
                    
                    boundsBehavior: isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds
                    
                    clip: true
                    
                    RowLayout
                    {
                        id: flickableLayout
                        width: flickableItem.width
                        height: flickableItem.height
                        
                        Item
                        {
							Layout.fillWidth: !flickable.interactive
                            Layout.minimumHeight: 0
                            Layout.minimumWidth: 0
                        }
                        
                        Row
                        {
                            id: middleRowContent
                            clip: true
                            spacing: middleContent.length === 1 ? 0 : control.spacing
//                             Layout.maximumWidth: control.width - leftRowContent.implicitWidth - rightRowContent.implicitWidth
                            
                        }
                        
                        Item
                        {
							Layout.fillWidth: !flickable.interactive
							Layout.minimumHeight: 0
                            Layout.minimumWidth: 0
                        }
                    }
                    
                    ScrollBar.horizontal: ScrollBar { visible: false }
                }
                
            }
            
            Kirigami.Separator
            {
                Layout.fillHeight: true
                Layout.margins: 0
                Layout.topMargin: space.big
                Layout.bottomMargin: space.big
                width: unit
                opacity: 0.2
                visible: rightContent.length > 0 && flickable.interactive
                color: colorScheme.textColor
                
                gradient: Gradient
                {
                    GradientStop
                    {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop 
                    {
                        position: 0.5
                        color: colorScheme.textColor
                    }
                    
                    GradientStop 
                    {
                        position: 1.0
                        color: "transparent"
                    }
                }                
            }
            
            Row
            {
                id: rightRowContent
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                spacing: rightContent.length > 0 ? control.spacing : 0
                Layout.rightMargin: rightContent.length > 0 ? margins : 0
                Layout.minimumWidth: 0
                clip: true
            }
        }
        
        ScrollBar.horizontal: ScrollBar { visible: false}        
    }
}
