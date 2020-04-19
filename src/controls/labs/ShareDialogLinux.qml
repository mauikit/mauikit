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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.kde.purpose 1.0 as Purpose

Maui.Dialog
{	
	id: control
	
	property var urls : []
	property string mimeType
	
	widthHint: 0.9
	
	maxHeight: 500
	maxWidth: Maui.Style.unit * 500
	page.margins: Maui.Style.space.medium
	
	verticalAlignment: Qt.AlignBottom
	
	defaultButtons: false
		
		page.title: qsTr("Share with")
		headBar.visible: true
		
		headBar.leftContent: ToolButton
		{
			visible: _purpose.depth>1;
			icon.name: "go-previous"
			onClicked: _purpose.pop()
		}
		
		footBar.visible: true
		footBar.middleContent : Button
		{
			text: qsTr("Open with")
            onClicked:  control.openWith()
		}
		
		Maui.OpenWithDialog
		{
			id: _openWithDialog
			urls: control.urls			
		}
		
		Purpose.AlternativesView
		{
			id: _purpose
			Layout.fillWidth: true
			Layout.fillHeight: true
			pluginType: 'Export'
			clip: true
			
			inputData :
			{
				'urls': control.urls,
				'mimeType':control.mimeType
			}				
			
			delegate: Maui.ItemDelegate
			{
				width: parent.width
				height: Maui.Style.rowHeight * 1.5
				
				Maui.ListItemTemplate
				{
					anchors.fill: parent
					
					label1.text: model.display
					iconSource: model.iconName
					
					iconSizeHint: Maui.Style.iconSizes.medium					
				}
				
				onClicked: _purpose.createJob(index)
			}
        }
        
        function openWith()
        {
            _openWithDialog.open()
            control.close()
        }
}

