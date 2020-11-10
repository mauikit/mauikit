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

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "private"

/**
 * TagsBar
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.ToolBar
{
    id: control

    /**
      * listView : TagList
      */
    property alias listView : tagsList

    /**
      * count : int
      */
    property alias count : tagsList.count

    /**
      * editMode : bool
      */
    property bool editMode : false

    /**
      * allowEditMode : bool
      */
    property bool allowEditMode : false

    /**
      * list : TagsList
      */
    property alias list : tagsList.list

    /**
      * addClicked :
      */
    signal addClicked()

    /**
      * tagRemovedClicked :
      */
    signal tagRemovedClicked(int index)

    /**
      * tagClicked :
      */
    signal tagClicked(string tag)

    /**
      * tagsEdited :
      */
    signal tagsEdited(var tags)

    preferredHeight: Maui.Style.rowHeight + Maui.Style.space.tiny

    background: Rectangle
    {
        color: control.hovered || control.editMode ?  Qt.darker(control.Kirigami.Theme.backgroundColor, 1.1): control.Kirigami.Theme.backgroundColor

        Maui.Separator
        {
            position: Qt.Horizontal
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    leftSretch: false
    rightContent: [
    MouseArea
    {
        visible: control.allowEditMode && tagsList.visible
        hoverEnabled: true
        onClicked: addClicked()
        Layout.fillHeight: true
        Layout.preferredWidth: visible ? height : 0

        Maui.PlusSign
        {
            height: Maui.Style.iconSizes.tiny
            width: height
            anchors.centerIn: parent
            color: parent.containsMouse || parent.containsPress ? Kirigami.Theme.highlightColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
        }
    }
    ]

    middleContent : [
    TagList
    {
        id: tagsList
        visible: !control.editMode
        Layout.fillHeight: true
        Layout.fillWidth: true
        showPlaceHolder: allowEditMode
        showDeleteIcon: allowEditMode
        onTagRemoved: tagRemovedClicked(index)
        onTagClicked: control.tagClicked(tagsList.list.get(index).tag)
        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
        Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor
        MouseArea
        {
            anchors.fill: parent
            z: tagsList.z -1
            propagateComposedEvents: true
            onClicked: if(allowEditMode) goEditMode()
        }
    },

    Maui.TextField
    {
        id: editTagsEntry
        visible: control.editMode
        Layout.fillHeight: true
        Layout.fillWidth:true
        horizontalAlignment: Text.AlignLeft
        verticalAlignment:  Text.AlignVCenter
        focus: true
        text: list.tags.join(",")
        color: Kirigami.Theme.textColor
        selectionColor: Kirigami.Theme.highlightColor
        selectedTextColor: Kirigami.Theme.highlightedTextColor
        onAccepted: control.saveTags()

        actions.data: ToolButton
        {
            Layout.alignment: Qt.AlignLeft
            icon.name: "checkbox"
            onClicked: editTagsEntry.accepted()
        }

        background: Rectangle
        {
            color: "transparent"
        }
    }
    ]

    /**
      *
      */
    function clear()
    {
        //         tagsList.model.clear()
    }

    /**
      *
      */
    function goEditMode()
    {
        editMode = true
        editTagsEntry.forceActiveFocus()
    }

    /**
      *
      */
    function saveTags()
    {
        control.tagsEdited(control.getTags())
        editMode = false
    }

    /**
      *
      */
    function getTags()
    {
        if(!editTagsEntry.text.length > 0)
        {
            return
        }

        var tags = []
        if(editTagsEntry.text.trim().length > 0)
        {
            var list = editTagsEntry.text.split(",")

            if(list.length > 0)
            {
                for(var i in list)
                {
                    tags.push(list[i].trim())

                }
            }
        }

        return tags
    }
}
