/*
 *   Copyright 2020 Camilo Higuita <milo.h@aol.com>
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


//this basic toolbutton provides a basic anima

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

AbstractButton
{
    id: control

    /**
      *
      */
    property alias extraContent : _layoutButton.data

    /**
      *
      */
    readonly property alias label : _label

    /**
      *
      */
    readonly property alias kicon : _icon

    /**
      *
      */
    property alias rec : _background

//    Kirigami.Theme.inherit: false
//    Kirigami.Theme.colorSet: Kirigami.Theme.Button

focusPolicy: Qt.NoFocus

    hoverEnabled: !Kirigami.Settings.isMobile
    implicitHeight: Math.floor(Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.25))
    implicitWidth: Math.floor(_layoutButton.implicitWidth + (Maui.Style.space.medium *  2))

    icon.width: Maui.Style.iconSizes.medium
    icon.height: Maui.Style.iconSizes.medium

    background: Rectangle
    {
        id: _background
        implicitHeight: Math.floor(Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.25))

        radius: Maui.Style.radiusV
        color: control.down || control.checked || control.hovered || control.pressed ? Qt.rgba(control.Kirigami.Theme.highlightColor.r,  control.Kirigami.Theme.highlightColor.g,  control.Kirigami.Theme.highlightColor.b, 0.2) : "transparent"
        border.color:  checked ?  control.Kirigami.Theme.highlightColor : "transparent"

        Behavior on color
        {
            ColorAnimation
            {
                duration: Kirigami.Units.longDuration
            }
        }
    }

    RowLayout
    {
        id: _layoutButton
        anchors.centerIn: parent
        height: parent.height
        spacing: 0
        clip: true

        Item
        {
            implicitWidth: visible ? _icon.width + Maui.Style.space.medium : 0
            Layout.alignment: Qt.AlignCenter

            visible: _icon.source && _icon.source.length && (control.display === ToolButton.TextBesideIcon || control.display === ToolButton.IconOnly)

            Kirigami.Icon
            {
                id: _icon
                anchors.centerIn: parent
                width: control.icon.width
                height: control.icon.height

                color: (control.icon.color && control.icon.color.length ) ? control.icon.color : ( (control.checked || control.hovered || control.pressed || control.down ) && enabled ) ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor

                source: control.icon.name
                isMask: true
            }
        }

        Label
        {
            id: _label
            text: control.text
            visible: text.length && (control.display === ToolButton.TextOnly || control.display === ToolButton.TextBesideIcon || !_icon.visible)
            opacity: visible ? ( enabled ? 1 : 0.5) : 0
            horizontalAlignment: Qt.AlignHCenter
            Layout.fillWidth: visible
            Layout.preferredWidth: visible ? implicitWidth + Maui.Style.space.medium : 0
            color: control.down || control.pressed || control.checked || control.hovered ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor

            Behavior on Layout.preferredWidth
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: ( control.hovered ) && control.text.length && (control.display === ToolButton.IconOnly ? true : !checked)
    ToolTip.text: control.text
}
