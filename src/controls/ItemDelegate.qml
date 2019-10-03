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

import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0
import "private"

ItemDelegate
{
    id: control
    
    default property alias content : _content.data   
    
    property bool draggable: false
    property bool isCurrentItem :  false

    property int radius: Maui.Style.radiusV	
    
    //override the itemdelegate default signals to allow dragging content
    signal pressed(var mouse)
    signal pressAndHold(var mouse)
    signal clicked(var mouse)	
    signal rightClicked(var mouse)
	signal doubleClicked(var mouse)
    
    background: null
    hoverEnabled: !Kirigami.Settings.isMobile

    padding: 0
    bottomPadding: padding
    rightPadding: padding
    leftPadding: padding
    topPadding: padding
    
    MouseArea
	{
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        onClicked:
        {
            if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                control.rightClicked(mouse)
                else	
                    control.clicked(mouse)
        }
        
        onDoubleClicked: control.doubleClicked(mouse)
        
        onPressed: 
        {	
            if(control.draggable)
                loader.grabToImage(function(result)
                {
                    parent.Drag.imageSource = result.url
                })
                
                control.pressed(mouse)			
        }
        
        onPressAndHold : control.pressAndHold(mouse)
    }	
    
    Rectangle
	{
        id: _content
        
		anchors
		{
			fill: parent
			topMargin: control.topPadding
			bottomMargin: control.bottomPadding
			leftMargin: control.leftPadding
			rightMargin: control.rightPadding
			margins: control.padding
		}		
			color: control.isCurrentItem || control.hovered ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2) : "transparent"
					
			radius: control.radius
			border.color: control.isCurrentItem ? Kirigami.Theme.highlightColor : "transparent"
    }
}	
