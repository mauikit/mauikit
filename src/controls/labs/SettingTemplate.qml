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

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.ListItemTemplate
{
    id: control

    property alias setting : _settingSection
    Maui.SettingSection
    {
        id: _settingSection
    }

    leftMargin: Maui.Style.space.big
    rightMargin: leftMargin

    Layout.fillWidth: true
    iconSizeHint: Maui.Style.iconSizes.medium
    label2.wrapMode: Text.WordWrap
    implicitHeight: Math.floor(label1.implicitHeight + label2.implicitHeight + Maui.Style.space.big )

    background.visible: true
    background.opacity: 0.5
    background.color: control.enabled ? Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9)) :  "transparent"
    background.radius: Maui.Style.radiusV
    background.border.color: control.enabled ? "transparent" : Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))
} 
