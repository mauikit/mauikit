/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.12
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Rectangle
{
    id: indicatorItem
    implicitWidth: 18
    implicitHeight: 18
    color: !control.enabled ? "transparent"
                            :(checked ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.4) : control.Kirigami.Theme.backgroundColor)
    border.color: !control.enabled ? control.Kirigami.Theme.disabledTextColor
                                   : checked ? control.Kirigami.Theme.highlightColor: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9))
    border.width: control.checked ? 1 : 1
    radius: control.autoExclusive ? Math.min(height, width) : Maui.Style.radiusV

    property Item control
    property bool checked : control.checked

    Behavior on border.width
    {
        NumberAnimation
        {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color
    {
        ColorAnimation
        {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    Kirigami.Icon
    {
        visible: !control.autoExclusive
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 14
        height: 16
        source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/Material/images/check.png"
        color: control.checked ? Kirigami.Theme.highlightColor : "transparent"

        scale: checked ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 100 } }
    }

    Rectangle
    {
        visible: control.autoExclusive
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 10
        height: 10
        color: control.checked ? Kirigami.Theme.highlightColor : "transparent"
        radius: height
        scale: checked ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 100 } }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            NumberAnimation
            {
                target: indicatorItem
                property: "scale"
                // Go down 2 pixels in size.
                to: 1 - 2 / indicatorItem.width
                duration: 120
            }
            NumberAnimation
            {
                target: indicatorItem
                property: "scale"
                to: 1
                duration: 120
            }
        }
    }
}
