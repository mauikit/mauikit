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

import QtQuick 2.13
import QtQuick.Templates 2.3 as T
import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Controls.impl 2.12

T.Button
{
    id: control
    implicitWidth: Math.max(background.implicitWidth, contentItem.implicitWidth + Maui.Style.space.medium )
    implicitHeight: background.implicitHeight
    hoverEnabled: true

    icon.width: Kirigami.Settings.isMobile ? Maui.Style.iconSizes.medium : Maui.Style.iconSizes.small
    icon.height: Kirigami.Settings.isMobile ? Maui.Style.iconSizes.medium : Maui.Style.iconSizes.small

    icon.color: control.enabled ? (control.highlighted ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor) : control.Kirigami.Theme.disabledTextColor
    spacing: Maui.Style.space.medium

    contentItem: IconLabel
    {
        text: control.text
        font: control.font
        icon: control.icon
        color: !control.enabled ? control.Kirigami.Theme.disabledTextColor :
        control.highlighted || control.down ? control.Kirigami.Theme.highlightedTextColor : control.Kirigami.Theme.textColor
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignCenter
    }
    
    background: Rectangle
    {
        implicitWidth:  (Maui.Style.iconSizes.medium * 3) + Maui.Style.space.big
        implicitHeight: Maui.Style.iconSizes.medium + Maui.Style.space.small
     
        color: control.Kirigami.Theme.backgroundColor
        border.color: control.hovered ? Kirigami.Theme.highlightColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
        border.width: Kirigami.Units.devicePixelRatio
        radius: height * 0.07
    }
}
