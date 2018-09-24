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
import org.kde.mauikit 1.0 as Maui

GridView
{
    id: control

    property int itemSize : iconSizes.large
    property int itemSpacing: itemSize * 0.5 + (isMobile ? space.big :
                                                           space.large)
    property bool showEmblem : true
    property string rightEmblem
    property string leftEmblem

    property bool centerContent: false
    property bool showPreviewThumbnails: true

    signal itemClicked(int index)
    signal itemDoubleClicked(int index)

    signal rightEmblemClicked(var item)
    signal leftEmblemClicked(var item)

    signal itemRightClicked(int index)
    signal areaClicked(var mouse)
    signal areaRightClicked()

    flow: GridView.FlowLeftToRight
    clip: true

    anchors.horizontalCenter: centerContent ? parent.horizontalCenter :
                                              undefined

    width: centerContent ? Math.min(model.count, Math.floor(parent.width/cellWidth))*cellWidth :
                           parent.width
    height: parent.height

    //    cacheBuffer: cellHeight * 2

    cellWidth: itemSize + (itemSpacing * 1.3)
    cellHeight: itemSize + (itemSpacing * 1.3)

    focus: true

    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
    flickableDirection: Flickable.AutoFlickDirection
    snapMode: GridView.SnapToRow

    model: ListModel { id: gridModel  }

    delegate: Maui.IconDelegate
    {
        id: delegate

        isDetails: false
        width: cellWidth * 0.9
        height: cellHeight * 0.9
        folderSize : itemSize
        showTooltip: true
        showEmblem: control.showEmblem
        showThumbnails: control.showPreviewThumbnails
        rightEmblem: control.rightEmblem
        leftEmblem: control.leftEmblem

        Connections
        {
            target: delegate
            onClicked:
            {
                control.currentIndex = index
                itemClicked(index)
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                itemDoubleClicked(index)
            }

            onPressAndHold:
            {
                control.currentIndex = index
                control.itemRightClicked(index)
            }

            onRightClicked:
            {
                control.currentIndex = index
                control.itemRightClicked(index)
            }

            onRightEmblemClicked:
            {
                control.currentIndex = index
                var item = control.model.get(index)
                control.rightEmblemClicked(item)
            }

            onLeftEmblemClicked:
            {
                control.currentIndex = index
                var item = control.model.get(index)
                control.leftEmblemClicked(item)
            }
        }
    }

    ScrollBar.vertical: ScrollBar{ visible: !isMobile}

    onWidthChanged: adaptGrid()

    MouseArea
    {
        anchors.fill: parent
        z: -1
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        onClicked: control.areaClicked(mouse)
        onPressAndHold: control.areaRightClicked()
    }

    function adaptGrid()
    {
        var amount = parseInt(width/(itemSize + itemSpacing),10)
        var leftSpace = parseInt(width-(amount*(itemSize + itemSpacing)), 10)
        var size = parseInt((itemSize + itemSpacing)+(parseInt(leftSpace/amount, 10)), 10)

        size = size > itemSize + itemSpacing ? size : itemSize + itemSpacing

        cellWidth = size
    }
}
