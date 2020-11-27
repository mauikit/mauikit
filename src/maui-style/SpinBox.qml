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
import QtQuick.Templates 2.12 as T
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui


T.SpinBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth +
                            up.implicitIndicatorWidth +
                            down.implicitIndicatorWidth)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding,
                             implicitBackgroundHeight,
                             up.implicitIndicatorHeight,
                             down.implicitIndicatorHeight)

    spacing: Maui.Style.space.tiny
    topPadding: 0
    bottomPadding: 0
    leftPadding: (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))

    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        opacity: control.enabled ? 1 : 0.3

        font: control.font
        color: Kirigami.Theme.textColor
        selectionColor: Kirigami.Theme.highlightColor
        selectedTextColor: Kirigami.Theme.highlightedTextColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly

        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = false;
            onWheel: {
                if (wheel.pixelDelta.y < 0 || wheel.angleDelta.y < 0) {
                    control.decrease();
                } else {
                    control.increase();
                }
            }
        }
    }

    up.indicator: Item {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        width: height

        Kirigami.Icon {
            source: "list-add"
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: Maui.Style.iconSizes.small
            height: width
            color: enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
        }
        
        Kirigami.Separator
        {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
    }

    down.indicator: Item {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        width: height

        Kirigami.Icon {
            source: "list-remove"
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: Maui.Style.iconSizes.small
            height: width
            color: enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
        }
        
        Kirigami.Separator
        {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
    }

    background: Rectangle
    {
        implicitWidth:  (Maui.Style.iconSizes.medium * 6) + Maui.Style.space.big
        implicitHeight: Math.floor(Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.25))

        radius: Maui.Style.radiusV

        color: !control.editable ? control.Kirigami.Theme.backgroundColor : "transparent"

        border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
    }
}
