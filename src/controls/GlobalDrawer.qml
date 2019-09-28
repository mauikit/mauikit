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

import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import QtGraphicalEffects 1.0
import "private"

Kirigami.GlobalDrawer
{
    id: control
//     Kirigami.Theme.backgroundColor: viewBackgroundColor
    
    property Item bg
    
//     property alias handleButton : _handleButton

z:  modal ? ApplicationWindow.overlay.z + 1  : ApplicationWindow.z
//     handleVisible: false
//     y: altToolBars ? 0 : headBar.height
//     height: parent.height - (floatingBar && altToolBars ? 0 : headBar.height)
//     modal: true
    
    
    implicitHeight: root.height - root.header.height - root.footer.height
    height: root.height - root.header.height - root.footer.height
//     ApplicationWindow.height -ApplicationWindow.header.height - ApplicationWindow.footer.height
    y: root.header.height


    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0 
    
    onModalChanged:
    {
		if(!modal)
			visible = true
	}

//    FastBlur
//    {
//        id: blur
//        height: parent.height
//        width: parent.width
//        radius: 90
//        opacity: 0.5
//        source: ShaderEffectSource
//        {
//            sourceItem: bg
//            sourceRect:Qt.rect(bg.width-(control.position * control.width),
//                               0,
//                               control.width,
//                               control.height)
//        }
//    }
    
//     background: Rectangle 
//     {
// 		color: control.colorScheme.backgroundColor
// 		
// 		Item
// 		{
// 			parent: control.handle
// 			anchors.fill: parent
// 			anchors.margins: Maui.Style.space.huge
// 			
// 			DropShadow 
// 			{
// 				anchors.fill: handleGraphics
// 				horizontalOffset: 0
// 				verticalOffset: Kitrigami.Units.devicePixelRatio
// 				radius: Kitrigami.Units.gridUnit /2
// 				samples: 16
// 				color: Qt.rgba(0, 0, 0, control.handle.pressed ? 0.6 : 0.4)
// 				source: handleGraphics
// 			}
// 			
// 			Rectangle
// 			{
// 				id: handleGraphics
// 				anchors.centerIn: parent
// 				
// 				color: control.handle.pressed ? control.colorScheme.highlightColor : control.colorScheme.accentColor
// 				width: iconSizes.medium + Maui.Style.space.medium * 2
// 				height: width
// 				radius: Maui.Style.radiusV
// 				
// 				Maui.ToolButton
// 				{
// 					id: _handleButton
// 					anchors.centerIn: parent
// 					size: iconSizes.medium
// 				}
// 				
// 				Behavior on color
// 				{
// 					ColorAnimation {
// 						duration: Kirigami.Units.longDuration
// 						easing.type: Easing.InOutQuad
// 					}
// 				}
// 			}
// 		}
// 		
// 		
// 		EdgeShadow
// 		{
// 			z: -2
// 			edge: control.edge
// 			anchors
// 			{
// 				right: control.edge == Qt.RightEdge ? parent.left : (control.edge == Qt.LeftEdge ? undefined : parent.right)
// 				left: control.edge == Qt.LeftEdge ? parent.right : (control.edge == Qt.RightEdge ? undefined : parent.left)
// 				top: control.edge == Qt.TopEdge ? parent.bottom : (control.edge == Qt.BottomEdge ? undefined : parent.top)
// 				bottom: control.edge == Qt.BottomEdge ? parent.top : (control.edge == Qt.TopEdge ? undefined : parent.bottom)
// 			}
// 			
// 			opacity: control.position == 0 ? 0 : 1
// 			
// 			Behavior on opacity {
// 				NumberAnimation {
// 					duration: Units.longDuration
// 					easing.type: Easing.InOutQuad
// 				}
// 			}
// 		}
// 	}
}
