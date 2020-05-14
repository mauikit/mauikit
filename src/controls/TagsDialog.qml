import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import TagsModel 1.0
import TagsList 1.0

Maui.Dialog
{	
    id: control
    
	property alias taglist :_tagsList
	property alias listView: _listView
	property alias composerList: tagListComposer.list

	acceptText: "OK"
	rejectText: "Cancel"
	
	signal tagsReady(var tags)
	defaultButtons: true
	maxHeight: Maui.Style.unit * 500
	page.margins: Maui.Style.space.medium
	
	acceptButton.text: qsTr("Add")
	rejectButton.text: qsTr("Cancel")
	
	onAccepted: setTags()
	onRejected: close()	
    
    headBar.visible: true
	headBar.leftContent: ToolButton
	{
		icon.name: "view-sort"
		onClicked: sortMenu.popup()
		
		Menu
		{
			id: sortMenu			
			
			MenuItem
			{
				text: qsTr("Sort by name")
				checkable: true
				autoExclusive: true
				checked: _tagsList.sortBy === TagsList.TAG
				onTriggered: _tagsList.sortBy = TagsList.TAG
			}
			
			MenuItem
			{
				text: qsTr("Sort by date")
				checkable: true
				autoExclusive: true
				checked: _tagsList.sortBy === TagsList.ADD_DATE
				onTriggered: _tagsList.sortBy = TagsList.ADD_DATE
			}
		}
	}
	
	headBar.middleContent: Maui.TextField
	{
		id: tagText
		Layout.fillWidth: true
		placeholderText: qsTr("Add a new tag...")
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

	
	headBar.rightContent: ToolButton
	{
		icon.name: "view-refresh"
		onClicked: taglist.refresh()
	}	

	ColumnLayout
	{
		Layout.fillWidth: true
		Layout.fillHeight: true
		
		Item
		{
			Layout.fillHeight: true
			Layout.fillWidth: true
			
            Maui.ListBrowser
			{
                id: _listView                
                anchors.fill: parent
                spacing: Maui.Style.space.tiny

				TagsModel
				{
					id: _tagsModel
					list: _tagsList
				}
				
				TagsList
				{
					id: _tagsList
				}				
				
                holder.emoji: "qrc:/assets/Electricity.png"
                holder.visible: _listView.count === 0
                holder.isMask: false
                holder.title : qsTr("No tags!")
                holder.body: qsTr("Start by creating tags")
                holder.emojiSize: Maui.Style.iconSizes.huge
				
				model: _tagsModel
				delegate: Maui.ListDelegate
				{
					id: delegate
                    label: model.tag
                    iconName: model.icon
                    iconSize: Maui.Style.iconSizes.small
					radius: Maui.Style.radiusV
					Connections
					{
						target: delegate
						onClicked:
						{
							_listView.currentIndex = index
							tagListComposer.list.append(_tagsList.get(_listView.currentIndex ).tag)			
						}
					}
				}				
			}			
		}		
		
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
	}
	
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
