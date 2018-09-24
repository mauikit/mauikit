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
import org.kde.kirigami 2.0 as Kirigami
import QtGraphicalEffects 1.0

Kirigami.GlobalDrawer
{
    id: control

    property Item bg

    z: 999
    handleVisible: false
    y: altToolBars ? 0 : headBar.height
    height: parent.height - (floatingBar && altToolBars ? 0 : headBar.height)
    modal: true

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    actions: [

        Column
        {
            id: drawerActionsColumn

        },

        Kirigami.Action
        {
            text: "About..."
            iconName: "documentinfo"
            onTriggered: about.open()
        }
    ]

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
}
