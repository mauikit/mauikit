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

ListView
{
    id: control
    property bool detailsView : false
    property int itemSize : iconSizes.big
    property bool showEmblem : true
    property string rightEmblem
    property string leftEmblem

    property bool showDetailsInfo : false
    property bool showPreviewThumbnails: true

    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)

	signal rightEmblemClicked(int index)
	signal leftEmblemClicked(int index)

    signal areaClicked(var mouse)
    signal areaRightClicked()

    //    maximumFlickVelocity: 400

    snapMode: ListView.SnapToItem
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds

    width: parent.width
    height: parent.height

    clip: true
    focus: true

    model: ListModel { id: listModel }
    delegate: Maui.IconDelegate
    {
        id: delegate
        isDetails: true
        width: parent.width
        height: itemSize + space.big

        showDetailsInfo: control.showDetailsInfo
        folderSize : itemSize
        showTooltip: true
        showEmblem: control.showEmblem
        showThumbnails: showPreviewThumbnails
        rightEmblem: control.rightEmblem
        leftEmblem: control.leftEmblem

        Connections
        {
            target: delegate
            onClicked:
            {
                control.currentIndex = index
                control.itemClicked(index)
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                control.itemDoubleClicked(index)
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
                control.rightEmblemClicked(index)
            }

            onLeftEmblemClicked:
            {
                control.currentIndex = index
                control.leftEmblemClicked(index)
            }
        }
    }

    ScrollBar.vertical: ScrollBar{ visible: !isMobile}

    MouseArea
    {
        anchors.fill: parent
        z: -1
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        onClicked: control.areaClicked(mouse)
        onPressAndHold: control.areaRightClicked()
    }
}
