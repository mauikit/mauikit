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
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Item
{
	id: control    
	/* Controlc color scheming */
	ColorScheme 
	{
		id: colorScheme
	}
	property alias colorScheme : colorScheme
	/***************************/
	height: iconSizes.big
	
	property string url : ""
	property bool pathEntry: false
	
	signal pathChanged(string path)
	signal homeClicked()
	signal placeClicked(string path)
	
	onUrlChanged: append()
	
	Rectangle
	{
		id: pathBarBG
		anchors.fill: parent
		//         z: -1
		color: pathEntry ? colorScheme.viewBackgroundColor : colorScheme.backgroundColor
		radius: radiusV
		opacity: 1
		border.color: colorScheme.borderColor
		border.width: unit
	}
	
	Loader
	{
		id: _loader        
		anchors.fill: parent
		sourceComponent: pathEntry ? _pathEntryComponent : _pathCrumbsComponent
		
		onLoaded:
		{
			if(sourceComponent === _pathCrumbsComponent)
				control.append()
		}
	}
	
	
	Component
	{
		id: _pathEntryComponent
		RowLayout
		{
			anchors.fill:  parent
			
			Maui.TextField
			{
				id: entry
				text: control.url
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.leftMargin: contentMargins
				Layout.alignment: Qt.AlignVCenter
				colorScheme.textColor: control.colorScheme.textColor
				colorScheme.backgroundColor: "transparent"
				colorScheme.borderColor: "transparent"
				horizontalAlignment: Qt.AlignLeft
				onAccepted:
				{
					pathChanged(text)
					showEntryBar()
				}
				background: Rectangle
				{
					color: "transparent"
				}
			}
			
			Item
			{
				Layout.fillHeight: true
				Layout.leftMargin: space.small
				Layout.rightMargin: space.small
				width: iconSize
				
				ToolButton
				{
					anchors.centerIn: parent
					icon.name: "go-next"
					icon.color: control.colorScheme.textColor
					onClicked:
					{
						pathChanged(entry.text)
						showEntryBar()
					}
				}
			}
		}
	}
	
	Component
	{
		id: _pathCrumbsComponent
		
		RowLayout
		{
			anchors.fill: parent
			spacing: 0
			property alias pathsList : pathBarList
			
			Item
			{
				Layout.fillHeight: true
				Layout.leftMargin: space.small
				Layout.rightMargin: space.small
				width: iconSize
				
				ToolButton
				{
					anchors.centerIn: parent
					icon.name: "go-home"
					flat: true
					icon.color: control.colorScheme.textColor                
					onClicked: homeClicked()
				}
			}
			
			Kirigami.Separator
			{
				Layout.fillHeight: true
				color: colorScheme.borderColor
			}
			
			ListView
			{
				id: pathBarList
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				orientation: ListView.Horizontal
				clip: true
				spacing: 0
				
				focus: true
				interactive: true
				boundsBehavior: isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds
				
				model: ListModel{}
				
				delegate: PathBarDelegate
				{
					id: delegate
					height: control.height - (unit*2)
					width: iconSizes.big * 3
					Connections
					{
						target: delegate
						onClicked:
						{
							pathBarList.currentIndex = index
							placeClicked(pathBarList.model.get(index).path)
						}
					}
				}
				
				MouseArea
				{
					anchors.fill: parent
					onClicked: showEntryBar()
					z: -1
				}
				
			}
			
			Item
			{
				Layout.fillHeight: true
				Layout.leftMargin: space.small
				Layout.rightMargin: space.small
				width: iconSize
				ToolButton
				{
					anchors.centerIn: parent
					flat: true
					icon.name: "filename-space-amarok"
					icon.color: control.colorScheme.textColor                
					onClicked: showEntryBar()
				}
			}
			
			//        MouseArea
			//        {
			//            anchors.fill: parent
			//            propagateComposedEvents: true
			//            onClicked: showEntryBar()
			//        }
			
			
			
		}
	}
	
	Component.onCompleted: control.append(control.url)
	
	function append()
	{
		if(_loader.sourceComponent !== _pathCrumbsComponent)
			return
			
			_loader.item.pathsList.model.clear()
			var places = control.url.split("/")
			var url = ""
			for(var i in places)
			{
				url = url + places[i] + "/"
				if(places[i].length > 1)
					_loader.item.pathsList.model.append({label : places[i], path: url})
			}
			
			_loader.item.pathsList.currentIndex = _loader.item.pathsList.count-1
			_loader.item.pathsList.positionViewAtEnd()
	}
	
	function showEntryBar()
	{
		control.pathEntry = !control.pathEntry
	}
}
