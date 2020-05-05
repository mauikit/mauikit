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
    readonly property alias hovered : mouseArea.containsMouse
    readonly property alias pressed : mouseArea.pressed
    
    property int size: Maui.Style.iconSizes.medium
    property string iconName : ""
    property string text : ""

    signal clicked()
    signal hovered()
    signal released()

    z: parent.z+1
    
    implicitHeight: size
    implicitWidth: loader.sourceComponent == labelComponent ? Math.max(loader.item.implicitWidth, size) : size
    
    radius: Math.min(width, height)
    color: control.Kirigami.Theme.backgroundColor
    border.color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.7))

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
            color: control.Kirigami.Theme.textColor
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
            color: control.Kirigami.Theme.textColor
            width: control.size
            height: width
            isMask: color !== "transparent"
        }
    }

    MouseArea
    {
        id: mouseArea
        hoverEnabled: true
        
        readonly property int targetMargin:  Kirigami.Settings.isMobile ? Maui.Style.space.big : 0

        height: parent.height + targetMargin
        width: parent.width + targetMargin

        anchors.centerIn: parent
        onClicked: control.clicked()
        onReleased: control.released()
    }
}
