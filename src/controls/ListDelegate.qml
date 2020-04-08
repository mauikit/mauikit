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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ItemDelegate
{
	id: control
	
	property bool labelVisible : true
	property alias iconSize : _template.iconSizeHint  
	property alias iconVisible : _template.iconVisible
	property alias label: _template.text1
	property alias label2: _template.text2
	property alias iconName: _template.iconSource  
	property alias count : _badge.text
	implicitWidth: parent.width
	implicitHeight: Math.max(control.iconSize + Maui.Style.space.tiny, Maui.Style.rowHeight)	
	
	isCurrentItem : ListView.isCurrentItem 
	
	padding: 0
	leftPadding: Maui.Style.space.tiny
	rightPadding: Maui.Style.space.tiny
	
	ToolTip.delay: 1000
	ToolTip.timeout: 5000
	ToolTip.visible: hovered 
	ToolTip.text: qsTr(control.label)
	
	
	Maui.ListItemTemplate
	{
		id: _template
		anchors.fill: parent
		labelsVisible: control.labelVisible
		hovered: control.hovered
		isCurrentItem: control.isCurrentItem
		
		Maui.Badge
		{
			id: _badge
			text: control.count     			
			visible: control.count.length > 0 && control.labelVisible			
		}
	}	
	
	function clearCount()
	{
		console.log("CLEANING SIDEBAR COUNT")
		control.count = ""
	}
}
