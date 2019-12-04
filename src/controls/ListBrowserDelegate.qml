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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0
import "private"

Maui.ItemDelegate
{
	id: control 
	
	property bool showDetailsInfo: false
	property int folderSize : Maui.Style.iconSizes.medium
	property int emblemSize: Maui.Style.iconSizes.medium
	property alias showLabel : _template.labelsVisible
	property bool showEmblem : false
	property bool showTooltip : false
	property bool showThumbnails : false
	property bool isSelected : false	
	property bool keepEmblemOverlay : false	
	property string rightEmblem
	property string leftEmblem
	
	isCurrentItem : ListView.isCurrentItem || isSelected	
		
	signal emblemClicked(int index)
	signal rightEmblemClicked(int index)
	signal leftEmblemClicked(int index) 
	signal contentDropped(var drop)
	
	ToolTip.delay: 1000
	ToolTip.timeout: 5000
	ToolTip.visible: control.hovered && control.showTooltip
	ToolTip.text: model.tooltip ? model.tooltip : model.path  
	
	
	property alias label1 : _template.label1
	property alias label2 : _template.label2
	property alias label3 : _template.label3
	property alias label4 : _template.label4
	property alias iconItem : _template.iconItem
	property alias iconVisible : _template.iconVisible
	property alias iconSizeHint : _template.iconSizeHint
	property alias imageSource : _template.imageSource
	property alias iconSource : _template.iconSource
		
	DropArea 
	{
		id: _dropArea
		anchors.fill: parent
		enabled: control.draggable
		
		Rectangle 
		{
			anchors.fill: parent
			radius: Maui.Style.radiusV
			color: control.Kirigami.Theme.highlightColor		
			visible: parent.containsDrag
		}
		
		onDropped:
		{
			control.contentDropped(drop)
		}
	}
	
	Drag.active: mouseArea.drag.active && control.draggable
	Drag.dragType: Drag.Automatic
	Drag.supportedActions: Qt.CopyAction
	Drag.mimeData:
	{
		"text/uri-list": model.path
	}
	
	Maui.Badge
	{
		id: _leftEmblemIcon
		iconName: control.leftEmblem
		visible: (control.hovered || control.keepEmblemOverlay || control.isSelected) && control.showEmblem  && control.leftEmblem
		anchors.top: parent.top
		anchors.left: parent.left
		onClicked: leftEmblemClicked(index)
        size: Maui.Style.iconSizes.small
	}
	
	Maui.ListItemTemplate
	{
		id: _template
		width: parent.width
		height: parent.height
		
		isCurrentItem : control.isCurrentItem
		
		iconSizeHint: control.folderSize
		
		imageSource: model.thumbnail
		iconSource: model.icon
		
		label1.text: model.label
		label3.text : model.mime === "inode/directory" ? (model.count ? model.count + qsTr(" items") : "") : Maui.FM.formatSize(model.size)
		label4.text: Maui.FM.formatDate(model.modified, "MM/dd/yyyy")
	}
}
