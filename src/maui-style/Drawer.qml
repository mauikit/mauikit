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
import QtQuick.Controls 2.3
import QtQuick.Templates 2.3 as T
import org.kde.kirigami 2.2 as Kirigami

T.Drawer {
    id: control

    parent: T.ApplicationWindow.overlay

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    topPadding: control.edge === Qt.BottomEdge ? 1 : 0
    leftPadding: control.edge === Qt.RightEdge ? 1 : 0
    rightPadding: control.edge === Qt.LeftEdge ? 1 : 0
    bottomPadding: control.edge === Qt.TopEdge ? 1 : 0

    background: Rectangle 
    {
        color: Kirigami.Theme.viewBackgroundColor
         Kirigami.Separator 
        {
            anchors 
            {
                left: control.edge === Qt.RightEdge ?  parent.left : undefined
                right: control.edge === Qt.LeftEdge ? parent.right : undefined
                top: parent.top
                bottom: parent.bottom
            }
        }  
    }

    enter: Transition {
        SmoothedAnimation {
            velocity: 5
        }
    }
    exit: Transition {
        SmoothedAnimation {
            velocity: 5
        }
    }
}
