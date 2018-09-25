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
import QtQuick.Controls.impl 2.3
import org.kde.kirigami 2.0 as Kirigami

ToolButton
{
    id: control
    readonly property color defaultColor:  textColor

    property bool isMask:  true
    property string iconName: ""
    property int size: iconSize
    property color iconColor: textColor
    property bool anim: false
    property string tooltipText : ""
    hoverEnabled: !isMobile
    height:  control.display === ToolButton.IconOnly ? size + space.medium : implicitHeight
    width: control.display === ToolButton.IconOnly ? height : implicitWidth
    icon.name:  iconName
    icon.width:  size
    icon.height: size
    //     icon.height:  display === ToolButton.TextUnderIcon ? size * 2 : size
    icon.color: !isMask ? "transparent" : iconColor

    onClicked: if(anim) animIcon.running = true
    //                 anchors.verticalCenter: parent.verticalCenter

    flat: true
    highlighted: !isMask
    font.pointSize: control.display === ToolButton.TextUnderIcon ? fontSizes.small : undefined

    display: control.text.length > 0 ? (isWide ? ToolButton.TextBesideIcon : ToolButton.TextUnderIcon) : ToolButton.IconOnly
    spacing: space.tiny
    
    background: Rectangle
    {
     color: /*(down || pressed || checked) */ checked && enabled  ? 
Qt.lighter(highlightColor, 1.2) : "transparent"
     radius: unit * 3
     opacity: 0.5
    }

    contentItem: IconLabel
    {
        spacing:  control.display === ToolButton.TextUnderIcon ? space.tiny : control.spacing
        mirrored: control.mirrored
        display: control.display
        icon: control.icon
        text: control.text
        font: control.font
        color: control.iconColor
    }

    SequentialAnimation
    {
        id: animIcon
        PropertyAnimation
        {
            target: control
            property: "icon.color"
            easing.type: Easing.InOutQuad
            from: highlightColor
            to: iconColor
            duration: 500
        }
    }
    
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: hovered && !isMobile && tooltipText.length > 0
    ToolTip.text: tooltipText
}
