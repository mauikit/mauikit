import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

import FMList 1.0


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
	}
	
	onItemRightClicked: _menu.popup()
	
	Menu
	{
		id: _menu
		property int index
		
		MenuItem
		{
			text: qsTr("Edit")
		}
		
		MenuItem
		{
			text: qsTr("Hide")
		}
		
		MenuItem
		{
			text: qsTr("Remove")
			Kirigami.Theme.textColor: dangerColor
		}
	}
	
	Maui.BaseModel
	{
		id: placesModel
		list: placesList
	}
	
	Maui.PlacesList
	{
		id: placesList
		groups: [FMList.PLACES_PATH, FMList.APPS_PATH, FMList.BOOKMARKS_PATH, FMList.DRIVES_PATH, FMList.TAGS_PATH]
	}
}
