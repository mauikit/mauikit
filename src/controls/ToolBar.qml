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
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "private"

ToolBar
{
	id: control    
	
	implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
	implicitHeight: visible ? (floating ? toolBarHeightAlt : toolBarHeight) : 0
	
	width: floating ? implicitWidth : parent.width
	height:  implicitHeight 
	
	property alias stickyRightContent : rightRowContent.sticky
	property alias stickyLeftContent : leftRowContent.sticky
	property alias stickyMiddleContent : middleRowContent.sticky
	
	property alias leftContent : leftRowContent.data
	property alias middleContent : middleRowContent.data
	property alias rightContent : rightRowContent.data
	
	property alias middleLayout : middleRowContent
	property alias leftLayout : leftRowContent
	property alias rightLayout : rightRowContent
	
	property alias layout : layout
	
	property int margins: space.medium
	spacing: space.medium
	property int count : leftContent.length + middleContent.length + rightContent.length
	
	property bool dropShadow: false
	property bool drawBorder: false
	property bool floating: false
	property bool plegable: false //deprecrated
	property bool folded : false //deprecrated
	property bool flickable: true
	property bool strech : true
	property bool leftSretch: strech
	property bool rightSretch: strech
	property bool middleStrech: strech
	padding: 0    
	//    leftPadding: Kirigami.Units.smallSpacing*2
	//    rightPadding: Kirigami.Units.smallSpacing*2
	signal unfolded()
	
// 	onPlegableChanged: folded = plegable
// 	onVisibleChanged: 
// 	{
// 		if(control.visible)
// 			control.height= implicitHeight
// 			else
// 				control.height= 0
// 				
// 	}
	
// 	background: Rectangle
// 	{
// 		id: headBarBG
// 		color: colorScheme.backgroundColor
// 		implicitHeight: toolBarHeightAlt  
// 		radius: floating ? radiusV : 0   
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
// 			height: unit
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
// 			verticalOffset:  unit * (altToolBars ? -1 : 1)
// 			radius: 8
// 			samples: 25
// 			color: Qt.darker(colorScheme.backgroundColor, 1.4)
// 			source: headBarBG
// 		}
// 	}

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
				color: Kirigami.Theme.textColor
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
				color: Kirigami.Theme.textColor
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
			anchors.fill: parent
			anchors.leftMargin: margins
			anchors.rightMargin: margins
			
			flickableDirection: Flickable.HorizontalFlick
			interactive: (contentWidth > control.width) && control.flickable
			contentWidth: ((control.margins * 2) + space.medium) 
			+ (control.stickyLeftContent ? leftRowContent.implicitWidth : leftRowContent.width) 
			+ (control.stickyMiddleContent ? middleRowContent.implicitWidth : middleRowContent.width) 
			+ (control.stickyRightContent ? rightRowContent.implicitWidth : rightRowContent.width)
			
			
			boundsBehavior: isMobile ? Flickable.DragOverBounds : Flickable.StopAtBounds
			clip: true
			
			RowLayout
			{
				id: layout
				height: mainFlickable.height
				width: mainFlickable.width
				
				RowLayout
				{
					id: leftRowContent
					property bool sticky : false
					Layout.leftMargin: rightRowContent.implicitWidth && implicitWidth === 0 && middleRowContent.implicitWidth && control.leftSretch ? rightRowContent.implicitWidth : undefined
					Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
					spacing: leftContent.length > 0 ? control.spacing : 0
					Layout.minimumWidth: !sticky ? undefined : implicitWidth
					Layout.fillWidth: control.leftSretch && implicitWidth
					Layout.fillHeight: true

				}
				
				RowLayout
				{
					id: middleRowContent				
					property bool sticky : false
					
					Layout.alignment: Qt.AlignCenter					
					spacing: middleContent.length === 1 ? 0 : control.spacing
					Layout.minimumWidth: !sticky ? undefined : implicitWidth
					
					//                             Layout.maximumWidth: control.width - leftRowContent.implicitWidth - rightRowContent.implicitWidth
					Layout.fillWidth: control.middleStrech
					Layout.fillHeight: true
				}
				
				RowLayout
				{
					id: rightRowContent
					
					property bool sticky : false
					Layout.rightMargin: leftRowContent.implicitWidth && implicitWidth === 0 && middleRowContent.implicitWidth && control.rightSretch ? leftRowContent.implicitWidth : undefined
					Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
					spacing: rightContent.length > 0 ? control.spacing : 0
					Layout.minimumWidth: implicitWidth
					Layout.fillWidth: false
					Layout.fillHeight: true
				}           
			}
			
// 			ScrollBar.horizontal: ScrollBar { visible: false}        
		}		
	
}
