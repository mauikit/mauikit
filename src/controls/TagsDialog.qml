import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{	
	signal tagsAdded(var tags, var urls)
	defaultButtons: true
	maxHeight: unit * 500
	
	onAccepted: setTags()
	onRejected: close()
	
	ColumnLayout
	{
		anchors.fill: parent
		Item
		{
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			TagsList
			{
				id: _tagsList
				
				width: parent.width
				height: parent.height
				onTagClicked:
				{
					tagListComposer.list.append(tagsList.get(index).tag)
				}
			}
		}
		
		
		Maui.TextField
		{
			id: tagText
			Layout.fillWidth: true
			placeholderText: "New tags..."
			onAccepted:
			{
				var tags = tagText.text.split(",")
				for(var i in tags)
				{
					var myTag = tags[i].trim()
					tagsList.insert(myTag)
					tagListComposer.list.append(myTag)
				}
				clear()
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
			onTagRemoved: list.removeFromUrls(index)
		}
	}
	
// 	function show(urls)
// 	{
// 		picUrls = urls
// 		if(forAlbum)
// 			tag.getAbstractTags("album", picUrls[0], true)
// 			else
// 				tagListComposer.list.urls = picUrls
// 				
// 				open()
// 	}
// 	
// 	function setTags()
// 	{
// 		var tags = []
// 		
// 		for(var i = 0; i < tagListComposer.count; i++)
// 			tags.push(tagListComposer.list.get(i).tag)
// 			ss
// 			tagsAdded(tags, picUrls)
// 	}
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
