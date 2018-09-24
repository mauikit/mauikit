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
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

Rectangle
{
    id: control
    height: iconSizes.medium
    width: iconSizes.medium
    radius: Math.min(width, height)
    color: altColor
    border.color: Qt.darker(color, 1.4)
    clip: false
    property string iconName : ""
    property string text : ""
    
    signal clicked()    
      
    Label
    {
     height: parent.height
     width: parent.width
     text: control.text
     font.weight: Font.Bold
     font.bold: true
     visible:control.text.length
        color: altColorText
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
    }
    
    Maui.ToolButton
    {
        visible: iconName.length 
        anchors.centerIn: parent
        iconName: control.iconName
        iconColor: altColorText
        size: iconSizes.small
        enabled: false
    }
    
    MouseArea
    {
        anchors.fill: parent
        onClicked: control.clicked() 
        
    }
}
