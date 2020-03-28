/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2020  camilo <chiguitar@unal.edu.co>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
	id: control
	
	property var urls : []
	
	widthHint: 0.9
	page.padding: 0
	maxHeight: grid.contentHeight + (page.padding * 2.5) + headBar.height + Maui.Style.space.huge
	maxWidth: Maui.Style.unit * 500
	
	verticalAlignment: Qt.AlignBottom
	
	defaultButtons: false
		
	page.title: qsTr("Open with")
	headBar.visible: true
		
	Maui.GridBrowser
	{
		id: grid
		Layout.fillWidth: true
		Layout.fillHeight: true
		checkable: false
		model: ListModel {}
		onItemClicked:
		{
			grid.currentIndex = index
			triggerService(index)
		}
	}
	
	onOpened: populate()

	function populate()
	{
		if(urls.length > 0)
		{
			grid.model.clear()
			var services = Maui.KDE.services(control.urls[0])
			
			for(var i in services)
			{
				grid.model.append(services[i])
			}
		}
	}	
	
	function triggerService(index)
	{
		const obj = grid.model.get(index)		
		Maui.KDE.openWithApp(obj.actionArgument, control.urls)							
		close()
	}
}
