import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Maui.SideBar
{
	id: placesList
	
	signal placeClicked (var item)
	focus: true
	clip: true
	
	downloadBadget: "3"
	section.property: !placesList.isCollapsed ? "type" : ""
	section.criteria: ViewSection.FullString
	section.delegate: Maui.LabelDelegate
	{
		id: delegate
		label: section
		labelTxt.font.pointSize: fontSizes.big
		
		isSection: true
		boldLabel: true
		height: toolBarHeightAlt
	}
	
	onItemClicked:
	{
		placeClicked(item)
		
		if(pageStack.currentIndex === 0 && !pageStack.wideMode)
			pageStack.currentIndex = 1
	}
	
	Component.onCompleted: populate()
	
	function populate()
	{
		clear()
		var places = Maui.FM.getDefaultPaths()
		places.push(Maui.FM.getCustomPaths())
		places.push(Maui.FM.getBookmarks())
		places.push(Maui.FM.getDevices())
		places.push(Maui.FM.getTags())
		
		if(places.length > 0)
			for(var i in places)
				placesList.model.append(places[i])
				
	}
	
	function clear()
	{
		placesList.model.clear()
	}
}
