import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import TagsModel 1.0
import TagsList 1.0


Maui.Dialog
{	
	property var urls : []
	
	property alias taglist :_tagsList
	property alias listView: _listView
	property alias composerList: tagListComposer.list
	
	signal tagsReady(var tags)
	defaultButtons: true
	maxHeight: unit * 500
	
	onAccepted: setTags()
	onRejected: close()	
	headBar.plegable: false
	headBar.leftContent: Maui.ToolButton
	{
		iconName: "view-sort"
		tooltipText: qsTr("Sort by...")
		onClicked: sortMenu.popup()
		
		Maui.Menu
		{
			id: sortMenu			
			
			Maui.MenuItem
			{
				text: qsTr("Name")
				checkable: true
				checked: _tagsList.sortBy === TagsList.TAG
				onTriggered: _tagsList.sortBy = TagsList.TAG
			}
			
			Maui.MenuItem
			{
				text: qsTr("Date")
				checkable: true
				checked: _tagsList.sortBy === TagsList.ADD_DATE
				onTriggered: _tagsList.sortBy = TagsList.ADD_DATE
			}
		}
	}
	
	headBar.middleContent: Maui.TextField
	{
		id: tagText
		width: headBar.middleLayout.width * 0.9
		placeholderText: qsTr("New tags...")
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

	
	headBar.rightContent: Maui.ToolButton
	{
		iconName: "view-refresh"
		tooltipText: qsTr("Refresh...")
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
				clip: true
				anchors.fill: parent
				
				signal tagClicked(int index)
				
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
					title : "No tags!"
					body: "Start tagging your pics"
					emojiSize: iconSizes.huge
				}
				
				model: _tagsModel
				delegate: Maui.ListDelegate
				{
					id: delegate
					label: tag
					radius: radiusV
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
			Layout.leftMargin: contentMargins
			Layout.rightMargin: contentMargins
			height: 64
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
		tagsReady(tags)
		close()
	}
	
// 	function show(urls)
// 	{
// 		control.urls = urls
// 		tagListComposer.list.urls = picUrls
// 				
// 		open()
// 	}
// 	
	
// 	
// 	function addTagsToPic(urls, tags)
// 	{        
// 		if(tags.length < 1)
// 			return
// 			
// 			for(var j in urls)
// 			{
// 				var url = urls[j]
// 				
// 				if(!dba.checkExistance("images", "url", url))
// 					if(!dba.addPic(url))
// 						return
// 						
// 						for(var i in tags)
// 							if(PIX.addTagToPic(tags[i], url))
// 								picTagged(tags[i], url)
// 								
// 			}
// 			close()
// 	}  
}
