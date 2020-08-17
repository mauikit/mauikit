import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import TagsList 1.0

Maui.Dialog
{	
    id: control
    
    property alias taglist :_tagsList
    property alias listView: _listView
    property alias composerList: tagListComposer.list

    signal tagsReady(var tags)

    defaultButtons: true
    maxHeight: Maui.Style.unit * 500
    maxWidth: 400
    page.margins: 0

    acceptButton.text: i18n("Add")
    rejectButton.text: i18n("Cancel")

    onAccepted: setTags()
    onRejected: close()
    
    headBar.visible: true
    headBar.rightContent: Maui.ToolButtonMenu
    {
        icon.name: "view-sort"
        MenuItem
        {
            text: i18n("Sort by name")
            checkable: true
            autoExclusive: true
            checked: _tagsList.sortBy === TagsList.TAG
            onTriggered: _tagsList.sortBy = TagsList.TAG
        }

        MenuItem
        {
            text: i18n("Sort by date")
            checkable: true
            autoExclusive: true
            checked: _tagsList.sortBy === TagsList.ADD_DATE
            onTriggered: _tagsList.sortBy = TagsList.ADD_DATE
        }
    }

    headBar.middleContent: Maui.TextField
    {
        id: tagText
        Layout.fillWidth: true       
        placeholderText: i18n("New tag")
        onAccepted:
        {
            const tags = tagText.text.split(",")
            for(var i in tags)
            {
                const myTag = tags[i].trim()
                _tagsList.insert(myTag)
                tagListComposer.list.append(myTag)
            }
            clear()
        }
    }

    //	headBar.rightContent: ToolButton
    //	{
    //		icon.name: "view-refresh"
    //		onClicked: taglist.refresh()
    //	}

    stack: [

        Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: i18n("Filter")
            background: Item{}

            onAccepted: _tagsModel.filter = text
            onCleared: _tagsModel.filter = ""
        },

        Maui.ListBrowser
        {
            id: _listView

            Layout.fillHeight: true
            Layout.fillWidth: true

            topMargin: Maui.Style.space.medium

            holder.emoji: "qrc:/assets/Electricity.png"
            holder.visible: _listView.count === 0
            holder.isMask: false
            holder.title : i18n("No tags!")
            holder.body: i18n("Start by creating tags")
            holder.emojiSize: Maui.Style.iconSizes.huge

            model: Maui.BaseModel
            {
                id: _tagsModel
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
                list: TagsList
                {
                    id: _tagsList
                }
            }

            delegate: Maui.ListDelegate
            {
                id: delegate
                label: model.tag
                iconName: model.icon
                iconSize: Maui.Style.iconSizes.small

                onClicked:
                {
                    _listView.currentIndex = index
                    tagListComposer.list.append(_tagsList.get(_listView.currentIndex ).tag)
                }
            }
        },

        Maui.TagList
        {
            id: tagListComposer
            Layout.fillWidth: true
            Layout.leftMargin: Maui.Style.contentMargins
            Layout.rightMargin: Maui.Style.contentMargins
            height: Maui.Style.rowHeight
            width: parent.width
            onTagRemoved: list.remove(index)
            placeholderText: ""
        }
    ]

    onClosed:
    {
        composerList.urls = []
    }

    function setTags()
    {
        var tags = []

        for(var i = 0; i < tagListComposer.count; i++)
            tags.push(tagListComposer.list.get(i).tag)
        control.tagsReady(tags)
        close()
    }
}
