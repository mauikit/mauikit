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
import QtQuick.Templates 2.3 as T
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

T.Slider {
    id: control
    Kirigami.Theme.colorSet: Kirigami.Theme.Button

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight

    hoverEnabled: true

    handle:  Rectangle
    {
        id: handleRect
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))

        width: Maui.Style.iconSizes.medium
        height: width
        radius: width / 2
        color: control.Kirigami.Theme.highlightColor
        scale: control.handlePressed ? 1.5 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 250
            }
        }
    }

    snapMode: T.Slider.SnapOnRelease

    background: Rectangle
    {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : 48
        implicitHeight: control.horizontal ? 48 : 200
        width: control.horizontal ? control.availableWidth : 1
        height: control.horizontal ? 1 : control.availableHeight
        color: control.Kirigami.Theme.backgroundColor
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle
        {
            x: control.horizontal ? 0 : (parent.width - width) / 2
            y: control.horizontal ? (parent.height - height) / 2 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : 3
            height: control.horizontal ? 3 : control.position * parent.height

            color: control.Kirigami.Theme.highlightColor
        }
    }
}
