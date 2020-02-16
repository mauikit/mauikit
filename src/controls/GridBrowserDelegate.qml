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
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0
import "private"

Maui.ItemDelegate
{
    id: control

    property int folderSize : Maui.Style.iconSizes.big
    property int emblemSize: Maui.Style.iconSizes.medium
    property bool showLabel : true
    property bool showEmblem : false
    property bool showTooltip : false
    property bool showThumbnails : false
    property bool isSelected : false
    property bool keepEmblemOverlay : false
    property string rightEmblem
    property string leftEmblem

    property alias dropArea : _dropArea

    isCurrentItem : GridView.isCurrentItem || isSelected

    signal emblemClicked(int index)
    signal rightEmblemClicked(int index)
    signal leftEmblemClicked(int index)
    signal contentDropped(var drop)

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered && control.showTooltip
    ToolTip.text: model.tooltip ? model.tooltip : model.path

    background: Item {}

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        enabled: control.draggable

        Rectangle
        {
            anchors.fill: parent
            radius: Maui.Style.radiusV
            color: control.Kirigami.Theme.highlightColor
            visible: parent.containsDrag
        }

        onDropped:
        {
            control.contentDropped(drop)
        }
    }

    Drag.active: mouseArea.drag.active && control.draggable
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction
    Drag.mimeData:
    {
        "text/uri-list": model.path
    }


    Maui.GridItemTemplate
    {
        id: _template
        anchors.fill: parent
        iconSizeHint: control.folderSize
        iconSource: model.icon
        imageSource : model.mime ? (Maui.FM.checkFileType(Maui.FMList.IMAGE, model.mime) && control.showThumbnails && model.thumbnail && model.thumbnail.length? model.thumbnail : "") : ""
        label1.text: model.label
//        label1.elide: Text.ElideMiddle // TODO this is broken ???
        emblem.iconName: control.leftEmblem
        emblem.visible: (control.keepEmblemOverlay || control.isSelected) && control.showEmblem  && control.leftEmblem
        isCurrentItem: control.isCurrentItem
        emblem.border.color: emblem.Kirigami.Theme.textColor
        emblem.color: control.isSelected ? emblem.Kirigami.Theme.highlightColor : Qt.rgba(emblem.Kirigami.Theme.backgroundColor.r, emblem.Kirigami.Theme.backgroundColor.g, emblem.Kirigami.Theme.backgroundColor.b, 0.7)

        Connections
        {
            target: _template.emblem
            onClicked: control.leftEmblemClicked(index)
        }
    }


}
