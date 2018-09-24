
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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

ItemDelegate
{
    id: control
    property bool isDetails : false
    property int folderSize : iconSize
    property int emblemSize: iconSizes.medium
    property bool isHovered :  hovered
    property bool showLabel : true
    property bool showEmblem : true
    property bool showSelectionBackground : true
    property bool showTooltip : false
    property bool showThumbnails : false

    property bool emblemAdded : false
    property bool keepEmblemOverlay : false
    property bool isCurrentListItem :  ListView.isCurrentItem

    property color labelColor : (isCurrentListItem || GridView.isCurrentItem || (keepEmblemOverlay && emblemAdded)) && !hovered && showSelectionBackground ? highlightedTextColor : textColor
    property color hightlightedColor : GridView.isCurrentItem || hovered || (keepEmblemOverlay && emblemAdded) ? highlightColor : "transparent"

    property string rightEmblem
    property string leftEmblem : "emblem-added"

    signal rightClicked()
    signal emblemClicked(int index)
    signal rightEmblemClicked(int index)
    signal leftEmblemClicked(int index)

    focus: true
    hoverEnabled: !isMobile

    background: Rectangle
    {
        color: !isDetails? "transparent" : (isCurrentListItem ? highlightColor :
                                                                index % 2 === 0 ? Qt.lighter(backgroundColor,1.2) : backgroundColor)

    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        onClicked:
        {
            if(!isMobile && mouse.button === Qt.RightButton)
                rightClicked()
        }
    }

    Maui.ToolButton
    {
        id: leftEmblemIcon
        isMask: false
        size: emblemSize
        iconName: leftEmblem
        visible: (isHovered || keepEmblemOverlay) && showEmblem && leftEmblem
        z: 999
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked: leftEmblemClicked(index)
    }

    Maui.ToolButton
    {
        id: rightEmblemIcon
        isMask: false
        size: emblemSize
        iconName: rightEmblem
        visible: (isHovered || keepEmblemOverlay) && showEmblem && rightEmblem
        z: 999
        anchors.top: parent.top
        anchors.right: parent.right
        onClicked: rightEmblemClicked(index)
    }

    Component
    {
        id: imgComponent

        Image
        {
            id: img
            clip: true
            source:  "file://"+model.thumbnail
            height: folderSize
            width: isDetails ? folderSize : control.width * 0.9
            sourceSize.width: width
            sourceSize.height: folderSize
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: true

            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: img.sourceSize.width
                    height: img.sourceSize.height
                    Rectangle
                    {
                        anchors.centerIn: parent
                        width: img.sourceSize.width
                        height: img.sourceSize.height
                        radius: Kirigami.Units.devicePixelRatio * 3
                    }
                }
            }
        }
    }

    Component
    {
        id: iconComponent

        Maui.ToolButton
        {
            iconName: model.icon
            isMask: folderSize <= iconSizes.medium
            iconColor: labelColor
            size: folderSize
            enabled: false
        }
    }

    GridLayout
    {
        id: delegatelayout
        anchors.fill: parent
        rows: isDetails ? 1 : 2
        columns: isDetails ? 2 : 1
        rowSpacing: space.tiny
        columnSpacing: space.tiny

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: folderSize
            Layout.row: 1
            Layout.column: 1
            Layout.alignment: Qt.AlignCenter
            Layout.leftMargin: isDetails ? space.medium : 0

            Loader
            {
                id: loader
                anchors.centerIn: parent
                sourceComponent: model.mime ? (model.mime.indexOf("image") > -1 && showThumbnails ? imgComponent :
                                                                    iconComponent) : iconComponent

            }

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && showTooltip
            ToolTip.text: model.tooltip ? model.tooltip : model.path
        }


        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: parent.height * (isDetails ? 1 : 0.3)

            Layout.row: isDetails ? 1 : 2
            Layout.column: isDetails ? 2 : 1

            Layout.leftMargin: isDetails ? space.medium : 0

            Label
            {
                visible: showLabel
                text: model.label
                width: parent.width
                height: parent.height
                horizontalAlignment: isDetails? Qt.AlignLeft : Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                elide: Qt.ElideRight
                wrapMode: Text.Wrap
                font.pointSize: fontSizes.default
                color: labelColor

                Rectangle
                {
                    visible: parent.visible && showSelectionBackground && !isDetails
                    anchors.fill: parent
                    z: -1
                    radius: unit * 3
                    color: hightlightedColor
                    opacity: hovered ? 0.25 : 1
                }
            }
        }
    }
}
