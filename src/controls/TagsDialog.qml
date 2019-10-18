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
	page.padding: Maui.Style.space.medium
	
	acceptButton.text: qsTr("Add")
	rejectButton.text: qsTr("Cancel")
	
	onAccepted: setTags()
	onRejected: close()	
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
				checked: _tagsList.sortBy === TagsList.TAG
				onTriggered: _tagsList.sortBy = TagsList.TAG
			}
			
			MenuItem
			{
				text: qsTr("Sort by date")
				checkable: true
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
			var tags = tagText.text.split(",")
			for(var i in tags)
			{
				var myTag = tags[i].trim()
				_tagsList.insert(myTag)
				tagListComposer.list.append(myTag)
			}
			clear()
		}
	}

	
	headBar.rightContent: ToolButton
	{
		icon.name: "view-refresh"
// 		text: qsTr("Refresh...")
		onClicked: taglist.refresh()
	}	

	ColumnLayout
	{
		anchors.fill: parent
		
		Item
		{
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			ListView
			{
                id: _listView                
                anchors.fill: parent
                spacing: Maui.Style.space.tiny
                clip: true
                focus: true
				interactive: true
				highlightFollowsCurrentItem: true
				highlightMoveDuration: 0
				
				TagsModel
				{
					id: _tagsModel
					list: _tagsList
				}
				
				TagsList
				{
					id: _tagsList
				}				
				
				Maui.Holder
				{
					id: holder
					emoji: "qrc:/img/assets/Electricity.png"
					visible: _listView.count === 0
					isMask: false
					title : qsTr("No tags!")
					body: qsTr("Start by creating tags")
					emojiSize: Maui.Style.iconSizes.huge
				}
				
				model: _tagsModel
				delegate: Maui.ListDelegate
				{
					id: delegate
					label: tag
					radius: Maui.Style.radiusV
					Connections
					{
						target: delegate
						onClicked:
						{
							_listView.currentIndex = index
							tagListComposer.list.append(_tagsList.get(index).tag)
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
	
	function setTags()
	{
		var tags = []
		
		for(var i = 0; i < tagListComposer.count; i++)
			tags.push(tagListComposer.list.get(i).tag)
        control.tagsReady(tags)
		close()
    }
}
