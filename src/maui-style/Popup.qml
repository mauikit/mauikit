/*
 * Copyright 2017 Marco Martin <mart@kde.org>
 * Copyright 2017 The Qt Company Ltd.
 *
 * GNU Lesser General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU Lesser
 * General Public License version 3 as published by the Free Software
 * Foundation and appearing in the file LICENSE.LGPLv3 included in the
 * packaging of this file. Please review the following information to
 * ensure the GNU Lesser General Public License version 3 requirements
 * will be met: https://www.gnu.org/licenses/lgpl.html.
 *
 * GNU General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU
 * General Public License version 2.0 or later as published by the Free
 * Software Foundation and appearing in the file LICENSE.GPL included in
 * the packaging of this file. Please review the following information to
 * ensure the GNU General Public License version 2.0 requirements will be
 * met: http://www.gnu.org/licenses/gpl-2.0.html.
 */


import QtQuick 2.6
import QtGraphicalEffects 1.0
import QtQuick.Templates 2.3 as T
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

T.Popup
{
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentWidth > 0 ? contentWidth + leftPadding + rightPadding : 0)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentWidth > 0 ? contentHeight + topPadding + bottomPadding : 0)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    topPadding: Kirigami.Units.devicePixelRatio * 4
    bottomPadding: Kirigami.Units.devicePixelRatio * 4
    rightPadding: Kirigami.Units.devicePixelRatio * 2
    leftPadding: Kirigami.Units.devicePixelRatio * 2

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            easing.type: Easing.InOutQuad
            duration: 250
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            easing.type: Easing.InOutQuad
            duration: 250
        }
    }

    contentItem: Item { }

    background: Rectangle
    {
        radius: Maui.Style.radiusV
        color: Kirigami.Theme.backgroundColor
        border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
        layer.enabled: true
        
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 8
            samples: 16
            horizontalOffset: 0
            verticalOffset: 0
            color: Qt.rgba(0, 0, 0, 0.3)
        }        
    }    
    
    T.Overlay.modal: Rectangle 
    {
        color: Qt.rgba( control.Kirigami.Theme.backgroundColor.r,  control.Kirigami.Theme.backgroundColor.g,  control.Kirigami.Theme.backgroundColor.b, 0.4)

        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    T.Overlay.modeless: Rectangle
    {
        color: Qt.rgba( control.Kirigami.Theme.backgroundColor.r,  control.Kirigami.Theme.backgroundColor.g,  control.Kirigami.Theme.backgroundColor.b, 0.4)
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
