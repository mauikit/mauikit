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
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"


Drawer
{
	id: control
	
	position: Qt.Left
	
	default property alias content : _content.data
		
		property alias hovered : _mouseArea.containsMouse
		property alias model : _listBrowser.model
		property alias section : _listBrowser.section
		property alias currentIndex: _listBrowser.currentIndex
		
		property int iconSize : Maui.Style.iconSizes.small
		property bool showLabels: !collapsed  || !privateProperties.isCollapsed 
		
		property bool collapsible: false
		
		property bool collapsed: false
		onCollapsedChanged :
		{
			if(!collapsed && modal)
			{
				modal = false
				
			}
			
			if(!modal && !collapsed)
			{
				privateProperties.isCollapsed = true
				
			}
		}
		
		property int collapsedSize: Maui.Style.iconSizes.medium + (Maui.Style.space.medium*4)
		property int preferredWidth : Kirigami.Units.gridUnit * 12
		
		implicitWidth: privateProperties.isCollapsed && collapsed && collapsible  ? collapsedSize : preferredWidth
		visible: true
		modal: false
		interactive: false
		rightMargin: 100
		onPositionChanged:
		{
			console.log("position changed", position)
		}
		
		onModalChanged:
		{
			visible = true
		}
		
		
		property QtObject privateProperties : QtObject{
			
			property bool isCollapsed: control.collapsed		
			
		}
		
		//     onModalChanged:
		//     {
		// 		_mouseArea.containsMouse = true
		// 		control.focus = true
		// 	}
		
		contentItem: Item
		{
			id: _content
			anchors.fill: parent	
			data: Maui.ListBrowser
			{
				id: _listBrowser
				anchors.fill: parent
				Rectangle
				{
					anchors.fill: parent
					z: -1
					color: Kirigami.Theme.backgroundColor
				}
				
				delegate: Maui.ListDelegate
				{
					id: itemDelegate
					iconSize: control.iconSize
					labelVisible: control.showLabels   
					
					leftPadding:  Maui.Style.space.tiny
					rightPadding:  Maui.Style.space.tiny
					
					Connections
					{
						target: itemDelegate
						onClicked:
						{
							control.currentIndex = index
							itemClicked(index)
						}
						
						onRightClicked:
						{
							control.currentIndex = index
							itemRightClicked(index)
						}
						
						onPressAndHold:
						{
							control.currentIndex = index
							itemRightClicked(index)
						}
					}
				}
			}
		}
		
		MouseArea
		{
			id: _mouseArea	
			anchors.fill: parent
			hoverEnabled: true
			propagateComposedEvents: false
			preventStealing: true
			// 		parent: ApplicationWindow.overlay.parent
			z: 10000000
			onClicked: 
			{
				console.log("clickedddddddd")
			}
			onEntered:
			{
// 				if(Kirigami.Setting.isMobile)
// 					return
					
					if(containsMouse && privateProperties.isCollapsed && collapsed && collapsible && !modal)			
					{				
						modal = true
						privateProperties.isCollapsed = false				
					}
					
					console.log("ENTERED", control.z)
			}
			
			onExited:
			{
// 				if(Kirigami.Settings.isMobile)
// 					return
					
					if(!privateProperties.isCollapsed  && collapsible  && collapsed  && modal)			
					{				
						modal = false
						privateProperties.isCollapsed  = true	
					}
					console.log("EXITED", control.z)			
			}
			
			onPositionChanged: 
			{
				if (!pressed)
				{
					return;
				}
				
				console.log(mouse.x, mouse.x > control.collapsedSize)
				
				if(control.collapsed)
				{
					if(mouse.x > control.collapsedSize)
					{
						modal = true
						privateProperties.isCollapsed = false	
					}else
					{
						modal = false
						privateProperties.isCollapsed  = true	
					}
					
				}
			}		
			
		}	
		
}

