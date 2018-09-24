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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import org.kde.kirigami 2.2 as Kirigami
import QtGraphicalEffects 1.0

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

    width: parent.width * widthHint > maxWidth ? maxWidth : parent.width * widthHint
    height: parent.height * heightHint > maxHeight ? maxHeight: parent.height * heightHint


    x:  parent.width / 2 - width / 2
    y: if(verticalAlignment === Qt.AlignVCenter) 
        parent.height / 2 - height / 2
        else if(verticalAlignment === Qt.AlignTop)
                    parent.height / 2 + height * 0.3
                else if(verticalAlignment === Qt.AlignBottom)
                    (parent.height) - (height *1.3)
else
                        parent.height / 2 - height / 2


    z: parent.z+1

    modal: true
    focus: true
    clip: true
    
    margins: unit 
    padding: unit
    
    topPadding: control.padding
    bottomPadding: control.padding
    leftPadding: control.padding
    rightPadding: control.padding
    
    rightMargin: control.margins
    leftMargin: control.margins
    topMargin: control.margins
    bottomMargin: control.margins
    

    background: Rectangle
    {
        radius: unit * 2
        color: viewBackgroundColor
        border.color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.3)
        layer.enabled: true
        
        layer.effect: DropShadow 
        {
            transparentBorder: true
            radius: 8
            samples: 16
            horizontalOffset: 0
            verticalOffset: unit * 4
            color: Qt.rgba(0, 0, 0, 0.3)
        }
    }

    enter: Transition
    {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0;  duration: 150 }
    }

    exit: Transition
    {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
    }

    Material.accent: accentColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: textColor
}
