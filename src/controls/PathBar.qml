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
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

Item
{
    id: control

    property alias pathBarBG : pathBarBG
    height: iconSizes.big
    signal pathChanged(string path)
    signal homeClicked()
    signal placeClicked(string path)

    Rectangle
    {
        id: pathBarBG
        anchors.fill: parent
        z:-1
        color: viewBackgroundColor
        radius: radiusV
        opacity: 1
        border.color: Qt.tint(textColor, Qt.rgba(color.r, color.g, color.b, 0.7))
        border.width: unit
    }

    RowLayout
    {
        id: pathEntry
        anchors.fill:  parent
        visible: false

        TextInput
        {
            id: entry
            clip: true
            height: parent.height
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: contentMargins
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Qt.AlignVCenter
            color: textColor
            onAccepted:
            {
                pathChanged(text)
                showEntryBar()
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.leftMargin: space.small
            Layout.rightMargin: space.small
            width: iconSize

            Maui.ToolButton
            {
                anchors.centerIn: parent
                iconName: "go-next"
                onClicked:
                {
                    pathChanged(entry.text)
                    showEntryBar()
                }
            }
        }
    }

    RowLayout
    {
        id: pathCrumbs
        anchors.fill: parent
        spacing: 0

        Item
        {
            Layout.fillHeight: true
            Layout.leftMargin: space.small
            Layout.rightMargin: space.small
            width: iconSize

            Maui.ToolButton
            {
                anchors.centerIn: parent
                iconName: "go-home"
                onClicked: homeClicked()
            }
        }

        Kirigami.Separator
        {
            Layout.fillHeight: true
            color: pathBarBG.border.color
        }

        ListView
        {
            id: pathBarList
            Layout.fillHeight: true
            Layout.fillWidth: true

            orientation: ListView.Horizontal
            clip: true
            spacing: 0

            focus: true
            interactive: true
            boundsBehavior: isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds

            model: ListModel{}

            delegate: PathBarDelegate
            {
                id: delegate
                height: pathBar.height - (Kirigami.Units.devicePixelRatio * 2)
                width: iconSizes.big * 3
                Connections
                {
                    target: delegate
                    onClicked:
                    {
                        pathBarList.currentIndex = index
                        placeClicked(pathBarList.model.get(index).path)
                    }
                }
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked: showEntryBar()
                z: -1
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.leftMargin: space.small
            Layout.rightMargin: space.small
            width: iconSize
            Maui.ToolButton
            {
                anchors.centerIn: parent
                iconName: "filename-space-amarok"
                onClicked: showEntryBar()
            }
        }

        //        MouseArea
        //        {
        //            anchors.fill: parent
        //            propagateComposedEvents: true
        //            onClicked: showEntryBar()
        //        }



    }

    function append(path)
    {
        pathBarList.model.clear()
        var places = path.split("/")
        var url = ""
        for(var i in places)
        {
            url = url + places[i] + "/"
            if(places[i].length > 1)
                pathBarList.model.append({label : places[i], path: url})
        }

        pathBarList.currentIndex = pathBarList.count-1
        pathBarList.positionViewAtEnd()
    }

    function position(index)
    {
        //        rollList.currentIndex = index
        //        rollList.positionViewAtIndex(index, ListView.Center)
    }

    function showEntryBar()
    {
        pathEntry.visible = !pathEntry.visible
        entry.text = browser.currentPath
        pathCrumbs.visible = !pathCrumbs.visible
    }


}
