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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.impl 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import QtGraphicalEffects 1.0
import "private"

Button
{
    id: control

    /* Controlc color scheming */
    ColorScheme {id: colorScheme}
    property alias colorScheme : colorScheme
    /***************************/    
  
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: background.implicitHeight
    hoverEnabled: !isMobile    
    
    leftPadding: space.small
    rightPadding: leftPadding
    
    contentItem: Text 
    {
        text: control.text
        font: control.font
        color: !control.enabled ? Qt.lighter(colorScheme.textColor, 1,2) :
        control.highlighted || control.down ? Qt.lighter(colorScheme.textColor, 1.4) : colorScheme.textColor 
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    
    background: Rectangle 
    {
        id: buttonBG
		implicitWidth: iconSizes.medium *3
        
        implicitHeight: iconSizes.medium + space.small
     
		color: !control.enabled ? colorScheme.viewBackgroundColor : control.highlighted || control.down ? Qt.darker(colorScheme.backgroundColor, 1.4) : colorScheme.backgroundColor    
		
		border.color: control.highlighted || control.down ? Qt.darker(colorScheme.borderColor, 1.4) : colorScheme.borderColor
        
        border.width: unit
        radius: radiusV     
     
    }
    
}
