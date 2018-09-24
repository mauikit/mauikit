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
import "private"

Item
{
    id: control
    clip : true
    width: parent.width
    height: rowHeight
    property alias tagsList : tagsList
    property color bgColor: "transparent"
    property bool editMode : false
    property bool allowEditMode : false

    signal addClicked()
    signal tagRemovedClicked(int index)
    signal tagClicked(string tag)
    signal tagsEdited(var tags)

    Rectangle
    {
        anchors.fill: parent
        color: bgColor
        z: -1
    }

    RowLayout
    {
        anchors.fill: parent
        spacing: 0
        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: !editMode
            RowLayout
            {
                anchors.fill: parent
                spacing: 0

                Maui.ToolButton
                {
                    Layout.alignment: Qt.AlignLeft
                    visible: allowEditMode
                    iconName: "list-add"
                    onClicked: addClicked()
                    iconColor: textColor
                }

                TagList
                {
                    id: tagsList
                    Layout.leftMargin: contentMargins
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    showPlaceHolder: allowEditMode
                    showDeleteIcon: allowEditMode
                    onTagRemoved: tagRemovedClicked(index)
                    onTagClicked: control.tagClicked(tagsList.model.get(index).tag)

                    MouseArea
                    {
                        anchors.fill: parent
                        z: tagsList.z -1
                        propagateComposedEvents: true
                        onClicked: if(allowEditMode) goEditMode()
                    }
                }
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: editMode

            RowLayout
            {
                anchors.fill: parent
                spacing: 0
                Item
                {
                    Layout.fillHeight: true
                    Layout.fillWidth:true
                    Layout.leftMargin: space.medium
                    //                    Layout.margins: space.big
                    TextInput
                    {
                        id: editTagsEntry
                        anchors.fill: parent

                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment:  Text.AlignVCenter
                        selectByMouse: !isMobile
                        focus: true
                        wrapMode: TextEdit.Wrap
                        color: textColor
                        selectionColor: highlightColor
                        selectedTextColor: highlightedTextColor
                        onFocusChanged: editMode = false
                        onAccepted: saveTags()
                    }
                }

                Maui.ToolButton
                {
                    Layout.alignment: Qt.AlignLeft
                    iconName: "checkbox"
                    onClicked: saveTags()
                }
            }
        }
    }

    function clear()
    {
        tagsList.model.clear()
    }

    function goEditMode()
    {
        var currentTags = []
        for(var i = 0 ; i < tagsList.count; i++)
            currentTags.push(tagsList.model.get(i).tag)

        editTagsEntry.text = currentTags.join(", ")
        editMode = true
        editTagsEntry.forceActiveFocus()
    }

    function saveTags()
    {
        tagsEdited(getTags())
        editMode = false
    }

    function populate(tags)
    {
        clear()
        for(var i in tags)
            append(tags[i])

    }

    function append(tag)
    {
        tagsList.model.append(tag)
    }

    function getTags()
    {
        var tags = []
        if(editTagsEntry.text.trim().length > 0)
        {
            var list = editTagsEntry.text.split(",")

            if(list.length > 0)
                for(var i in list)
                    tags.push(list[i].trim())
        }

        return tags
    }

}
