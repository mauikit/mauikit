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
import QtGraphicalEffects 1.0


TextField
{
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            placeholderText ? placeholder.implicitWidth + leftPadding + rightPadding : 0)
                            || contentWidth + leftPadding + rightPadding
    implicitHeight:  iconSizes.big

    topPadding: space.tiny
    bottomPadding: space.tiny

    color: enabled ? textColor : Qt.lighter(textColor, 1.4)
    selectionColor: highlightColor
    selectedTextColor: highlightedTextColor
    verticalAlignment: TextInput.AlignVCenter

    cursorDelegate: CursorDelegate { }
    
    horizontalAlignment: Text.AlignHCenter
        selectByMouse: !isMobile
        focus: true
        wrapMode: TextEdit.Wrap

    Label
    {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)

        text: control.placeholderText
        font: control.font
        color: Kirigami.Theme.disabledTextColor
        horizontalAlignment: control.horizontalAlignment
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
    }


    background: Rectangle 
    {
        
        implicitWidth: unit * 120
        implicitHeight: iconSizes.big
        color: control.activeFocus ? viewBackgroundColor
                                   : (control.hovered ? "pink" : buttonBackgroundColor)
        border.color: Qt.darker(color, 1.4)
        radius: radiusV
        
    }
    
}
