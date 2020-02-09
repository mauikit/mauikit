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
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"
import "private/shapes"

Rectangle
{
    id: control

    implicitHeight: Maui.Style.rowHeight

    property string url : ""
    property bool pathEntry: false
    property alias list : _pathList
    property alias model : _pathModel
    property alias item : _loader.item

    signal pathChanged(string path)
    signal homeClicked()
    signal placeClicked(string path)
    signal placeRightClicked(string path)

    onUrlChanged: append()

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    color: Kirigami.Theme.backgroundColor
    radius: Maui.Style.radiusV
    opacity: 1
    border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
    border.width: Maui.Style.unit


    Loader
    {
        id: _loader
        z: control.z + 999999999999999
        anchors.fill: parent
        sourceComponent: pathEntry ? _pathEntryComponent : _pathCrumbsComponent
        onLoaded:
        {
            if(sourceComponent === _pathCrumbsComponent)
                control.append()
        }
    }

    Maui.BaseModel
    {
        id: _pathModel
        list: _pathList
    }

    Maui.PathList
    {
        id: _pathList
    }

    Component
    {
        id: _pathEntryComponent

        Maui.TextField
        {
            id: entry
            anchors.fill: parent
            text: control.url

            Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
            Kirigami.Theme.backgroundColor: "transparent"
            horizontalAlignment: Qt.AlignLeft
            onAccepted:
            {
                pathChanged(text)
                showEntryBar()
            }
            background: Rectangle
            {
                color: "transparent"
            }

            actions.data: ToolButton
            {
                icon.name: "go-next"
                icon.color: control.Kirigami.Theme.textColor
                onClicked:
                {
                    pathChanged(entry.text)
                    showEntryBar()
                }
            }
        }
    }

    Component
    {
        id: _pathCrumbsComponent

        RowLayout
        {
            anchors.fill: parent
            property alias listView: _listView
            spacing: 0
            clip: false

            MouseArea
            {
                Layout.fillHeight: true
                Layout.preferredWidth: height * 1.5
                onClicked: control.homeClicked()
                hoverEnabled: true

                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    source: Qt.platform.os == "android" ?  "user-home-sidebar" : "user-home"
                    color: parent.hovered ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                    width: Maui.Style.iconSizes.medium
                    height: width
                }
            }

            ListView
            {
                id: _listView
                Layout.fillHeight: true
                Layout.fillWidth: true
                property int pathArrowWidth: 8
                orientation: ListView.Horizontal
                clip: true
                spacing: 1 - (pathArrowWidth + 1)

                focus: true
                interactive: true
                boundsBehavior: Kirigami.Settings.isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds

                model: _pathModel

                delegate: PathBarDelegate
                {
                    id: delegate
                    borderColor: control.border.color
                    arrowWidth: _listView.pathArrowWidth
                    height: parent.height
                    width: Math.max(Maui.Style.iconSizes.medium * 2, implicitWidth)
                    Connections
                    {
                        target: delegate
                        onClicked:
                        {
                            listView.currentIndex = index
                            control.placeClicked(_pathList.get(index).path)
                        }

                        onRightClicked:
                        {
                            control.placeRightClicked(_pathList.get(index).path)

                        }

                        onPressAndHold:
                        {
                            control.placeRightClicked(_pathList.get(index).path)
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

            MouseArea
            {
                Layout.fillHeight: true
                Layout.preferredWidth: control.height
                onClicked: control.showEntryBar()
                hoverEnabled: true

                Rectangle
                {
                    anchors.fill: parent
                    radius: Maui.Style.radiusV
                    color: parent.containsMouse ?  Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2)  : "transparent"
                    Kirigami.Icon
                    {
                        anchors.centerIn: parent
                        source: "filename-space-amarok"
                        color: control.Kirigami.Theme.textColor
                        width: Maui.Style.iconSizes.medium
                        height: width
                    }
                }
            }
        }
    }

    Component.onCompleted: control.append()

    function append()
    {
        _pathList.path = control.url

        if(_loader.sourceComponent !== _pathCrumbsComponent)
            return

        _loader.item.listView.currentIndex = _loader.item.listView.count-1
        _loader.item.listView.positionViewAtEnd()
    }

    function showEntryBar()
    {
        control.pathEntry = !control.pathEntry
    }
}
