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
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

Drawer
{
    id: control

    property Item bg

    width: isMobile ? parent.width * 0.9 : Kirigami.Units.gridUnit * 17
    y: altToolBars ? 0 : root.headBar.height
    height: parent.height - (((floatingBar || root.floatingBar) && !altToolBars) ? root.headBar.height :
                                                           headBar.height + footBar.height)
    clip: true

    FastBlur
    {
        id: blur
        height: parent.height
        width: parent.width
        radius: 90
        opacity: 0.5
        source: ShaderEffectSource
        {
            sourceItem: bg
            sourceRect:Qt.rect(bg.width-(control.position * control.width),
                               0,
                               control.width,
                               control.height)
        }
    }

    background: Rectangle
    {
        color: backgroundColor
        Kirigami.Separator
        {
            readonly property bool horizontal: control.edge === Qt.LeftEdge || control.edge === Qt.RightEdge
            anchors
            {
                left: control.edge !== Qt.LeftEdge ? parent.left : undefined
                right: control.edge !== Qt.RightEdge ? parent.right : undefined
                top: control.edge !== Qt.TopEdge ? parent.top : undefined
                bottom: control.edge !== Qt.BottomEdge ? parent.bottom : undefined
            }
        }
    }


}
