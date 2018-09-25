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
import QtQuick.Controls.impl 2.3
import QtQuick.Controls.Material.impl 2.3
import org.kde.mauikit 1.0 as Maui


TextField
{
    id: control
    
    property color bgColor : buttonBackgroundColor
    property color fgColor : textColor
    property color borderColor : Qt.tint(fgColor, Qt.rgba(bgColor.r, bgColor.g, bgColor.b, 0.7))
    
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            placeholderText ? placeholder.implicitWidth + leftPadding + rightPadding : 0)
    || contentWidth + leftPadding + rightPadding
    implicitHeight:  iconSizes.big
    
    topPadding: space.tiny
    bottomPadding: space.tiny
    
    color: enabled ? fgColor : Qt.lighter(fgColor, 1.4)
    selectionColor: highlightColor
    selectedTextColor: highlightedTextColor
    verticalAlignment: TextInput.AlignVCenter
    
    cursorDelegate: CursorDelegate { }
    
    horizontalAlignment: Text.AlignHCenter
    selectByMouse: !isMobile
    focus: true
    wrapMode: TextEdit.Wrap
    
    Maui.ToolButton
    {
        visible: control.text.length
        anchors.top: control.top
        anchors.right: control.right
        anchors.rightMargin: space.small
        anchors.verticalCenter: parent.verticalCenter
        iconName: "edit-clear"
        iconColor: color   
        onClicked: control.clear()
        
    }
    
        Label
        {
            id: placeholder
            x: control.leftPadding
            y: control.topPadding
            width: control.width - (control.leftPadding + control.rightPadding)
            height: control.height - (control.topPadding + control.bottomPadding)
    
            text: control.placeholderText
            font: control.font
            color: Qt.lighter(fgColor, 1.4)
            horizontalAlignment: control.horizontalAlignment
            verticalAlignment: control.verticalAlignment
            visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
            elide: Text.ElideRight
        }
    
    
    background: Rectangle 
    {
        
        implicitWidth: unit * 120
        implicitHeight: iconSizes.big
        color: control.activeFocus ? Qt.lighter(bgColor, 1.4)
        : (control.hovered ? Qt.lighter(bgColor, 1.3) : bgColor)
        border.color: borderColor
        radius: radiusV
        
    }
    
}
