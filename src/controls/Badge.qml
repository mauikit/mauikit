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
import org.kde.kirigami 2.7 as Kirigami

import "private"

Rectangle
{
    id: control

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    property alias item : loader.item
    property bool hovered : false

    property int size: Kirigami.Settings.isMobile ? Maui.Style.iconSizes.medium : Maui.Style.iconSizes.small
    property string iconName : ""
    property string text : ""

    signal clicked()
    signal pressed()
    signal hovered()
    signal released()

    z: parent.z+1
    height: size + Maui.Style.space.small
    width: Math.max(implicitWidth, height)
    implicitWidth: (loader.sourceComponent == labelComponent ? Math.max(loader.item.implicitWidth + Maui.Style.space.small, control.height) : control.height)
    radius: Math.min(width, height)
    color: Kirigami.Theme.backgroundColor
    border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))

    clip: false

    Loader
    {
        id: loader
        anchors.fill: parent
        sourceComponent: control.text.length && !control.iconName.length ? labelComponent : (!control.text.length && control.iconName.length ? iconComponent : undefined)
    }

    Component
    {
        id: labelComponent
        Label
        {
            height: parent.height
            width: parent.width
            text: control.text
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.default
            color: Kirigami.Theme.textColor
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
        }
    }

    Component
    {
        id: iconComponent
        Kirigami.Icon
        {
            anchors.centerIn: parent
            source: control.iconName
            color: Kirigami.Theme.textColor
            width: control.size
            height: width
        }
    }

    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        onClicked: control.clicked()
        onPressed: control.pressed()
        onReleased: control.released()
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
    }
}
