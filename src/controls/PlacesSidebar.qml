import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

import FMList 1.0
import PlacesModel 1.0
import PlacesList 1.0

Maui.SideBar
{
	id: control
	
	property alias list : placesList
	
	signal placeClicked (string path)
	focus: true
	clip: true
	model: placesModel
	section.property: !control.isCollapsed ? "type" : ""
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
		var item = list.get(index)
		var path = item.path
		
		placesList.clearBadgeCount(index)
		
		if(item.type === "Tags")
			path ="Tags/"+path
			
		placeClicked(path)
		
		if(pageStack.currentIndex === 0 && !pageStack.wideMode)
			pageStack.currentIndex = 1
	}
	
	PlacesModel
	{
		id: placesModel
		list: placesList
	}
	
	PlacesList
	{
		id: placesList
		groups: [FMList.PLACES_PATH, FMList.APPS_PATH, FMList.BOOKMARKS_PATH, FMList.DRIVES_PATH, FMList.TAGS_PATH]
	}
}
