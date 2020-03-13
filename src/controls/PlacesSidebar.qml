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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

Maui.SideBar
{
	id: control
	
	property alias list : placesList
	property alias itemMenu : _menu
	collapsedSize: Maui.Style.iconSizes.medium + (Maui.Style.space.medium*4) - Maui.Style.space.tiny
	signal placeClicked (string path)
	focus: true
	model: placesModel
	section.property: "type"
	section.criteria: ViewSection.FullString
	section.delegate: Maui.LabelDelegate
	{
		id: delegate
		width: control.width
		label: section
		labelTxt.font.pointSize: Maui.Style.fontSizes.big		
		isSection: true
		height: Maui.Style.toolBarHeightAlt
	}
	onContentDropped:
	{
		placesList.addPlace(drop.text)
	}	
	onItemClicked:
	{
		var item = list.get(index)
		var path = item.path
		
		placesList.clearBadgeCount(index)	
			
		placeClicked(path)	
		if(control.collapsed)
			control.collapse()
	}
	
	onItemRightClicked: _menu.popup()
	
	Menu
	{
		id: _menu
		property int index
		
		MenuItem
		{
			text: qsTr("Edit...")
		}
		
		MenuItem
		{
			text: qsTr("Hide")
		}
		
		MenuItem
		{
			text: qsTr("Remove")
			Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
			onTriggered: list.removePlace(control.currentIndex)
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
		groups: [
		Maui.FMList.PLACES_PATH, 
//         Maui.FMList.APPS_PATH, 
        Maui.FMList.BOOKMARKS_PATH, 
        Maui.FMList.DRIVES_PATH, 
        Maui.FMList.TAGS_PATH]
	}
}
