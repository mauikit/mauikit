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
import org.kde.qqc2desktopstyle.private 1.0 as StylePrivate
import org.kde.kirigami 2.3 as Kirigami

T.Button {
    id: controlRoot
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    hoverEnabled: true
    contentItem: Text {
        text: controlRoot.text
        font: controlRoot.font
         color: !controlRoot.enabled ? Kirigami.Theme.disabledTextColor :
            controlRoot.highlighted || controlRoot.down ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.buttonTextColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    
    background: Rectangle {
        implicitWidth: (Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium) * 2 + Kirigami.Units.smallSpacing
        implicitHeight: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium 
     
        color: !controlRoot.enabled ? Kirigami.Theme.backgroundColor :
                controlRoot.highlighted || controlRoot.down ? Kirigami.Theme.buttonFocusColor : Kirigami.Theme.buttonBackgroundColor
        border.color: controlRoot.hovered ? Kirigami.Theme.buttonHoverColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
        border.width: Kirigami.Units.devicePixelRatio
        radius: height * 0.05
    }
}
