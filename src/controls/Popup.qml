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

import QtQuick 2.13
import QtQuick.Controls 2.13
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Popup
{
    id: control
    
    property int maxWidth : parent.width
    property int maxHeight : parent.height
    property double hint : 0.9
    property double heightHint : hint 
    property double widthHint : hint
    
    property int verticalAlignment : Qt.AlignVCenter
    
    parent: ApplicationWindow.overlay
    
    width: Math.max(Math.min(parent.width * widthHint, maxWidth), Math.min(maxWidth, parent.width * widthHint))	
    height: Math.max(Math.min(parent.height * heightHint, maxHeight), Math.min(maxHeight, parent.height * heightHint))	
    
    
    x:  parent.width / 2 - width / 2
    y: if(verticalAlignment === Qt.AlignVCenter) 
    parent.height / 2 - height / 2
    else if(verticalAlignment === Qt.AlignTop)
		(height + Maui.Style.space.huge)
        else if(verticalAlignment === Qt.AlignBottom)
			(parent.height) - (height + Maui.Style.space.huge)
            else
                parent.height / 2 - height / 2

                
                modal: control.width !== control.parent.width && control.height !== control.parent.height
            
                
                margins: 1
                padding: 1 
                
                //     topPadding: popupBackground.radius
                //     bottomPadding: popupBackground.radius
                topPadding: control.padding
                bottomPadding: control.padding
                leftPadding: control.padding
                rightPadding: control.padding
                
                rightMargin: control.margins
                leftMargin: control.margins
                topMargin: control.margins
                bottomMargin: control.margins    
                
                enter: Transition 
                {
                    // grow_fade_in
                    NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
                    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
                }
                
                exit: Transition 
                {
                    // shrink_fade_out
                    NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
                    NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
                }                
}
