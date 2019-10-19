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
	property int folderSize : iconSize
	property int emblemSize: Maui.Style.iconSizes.medium
	property bool showLabel : true
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
	
	
	Component
	{
		id: _imgComponent
		
		Item
		{
			anchors.fill: parent
			Image
			{
				id: img
				anchors.centerIn: parent
				source: model.thumbnail ? model.thumbnail : undefined
				height: control.folderSize
				width: height
				sourceSize.width: width
				sourceSize.height: height
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				fillMode: Image.PreserveAspectCrop
				cache: false
				asynchronous: true
				smooth: !Kirigami.Settings.isMobile
				
				layer.enabled: true
				layer.effect: OpacityMask
				{
					maskSource: Item
					{
						width: img.width
						height: img.height
						Rectangle
						{
							anchors.centerIn: parent
							width: img.width
							height: img.height
							radius: Maui.Style.radiusV
						}
					}
				}
			}
			
			Loader
			{
				anchors.centerIn: parent				
				sourceComponent: img.status === Image.Ready ? undefined : _iconComponent
			}
		}
	}
	
	Component
	{
		id: _iconComponent
		
        Kirigami.Icon
		{
            source: model.icon
            fallback: "qrc:/assets/application-x-zerosize.svg"
            height: control.folderSize
            width: height
		}
	}
	
	RowLayout
	{
		opacity: (model.hidden == true || model.hidden == "true" )? 0.5 : 1
		anchors.fill: parent
		spacing: Maui.Style.space.small
		Item
		{
			Layout.preferredHeight: control.folderSize
			Layout.preferredWidth: control.folderSize
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: Maui.Style.space.medium 
			
			Loader
			{
				anchors.centerIn: parent
				sourceComponent: model.mime ? (Maui.FM.checkFileType(Maui.FMList.IMAGE, model.mime) && control.showThumbnails ? _imgComponent : _iconComponent) : _iconComponent 
			}                    
		}  
		
		Label
		{
			id: label
			text: model.label
			Layout.margins: Maui.Style.space.tiny
			Layout.fillHeight: true
			Layout.fillWidth: true
			horizontalAlignment: Qt.AlignLeft
			verticalAlignment: Qt.AlignVCenter
			elide: Qt.ElideRight
			wrapMode: Text.Wrap
			color: control.Kirigami.Theme.textColor				
		}
		
		
		ColumnLayout
		{
			Layout.alignment: Qt.AlignRight
			Layout.rightMargin: Maui.Style.space.medium
			
			Label
			{
				Layout.alignment: Qt.AlignRight					
				Layout.fillHeight: true
				horizontalAlignment: Qt.AlignRight
				verticalAlignment: Qt.AlignBottom
				elide: Qt.ElideRight
				wrapMode: Text.NoWrap
				font.pointSize: Maui.Style.fontSizes.small
				color: control.Kirigami.Theme.textColor
				opacity: control.isCurrentItem ? 1 : 0.5
				text: model.mime === "inode/directory" ? (model.count ? model.count + qsTr(" items") : "") : Maui.FM.formatSize(model.size)
			}
			
			Label
			{
				Layout.alignment: Qt.AlignRight					
				Layout.fillHeight: true
				
				text: Maui.FM.formatDate(model.modified, "MM/dd/yyyy")
				
				horizontalAlignment: Qt.AlignRight
				verticalAlignment: Qt.AlignTop
				elide: Qt.ElideRight
				wrapMode: Text.NoWrap
				font.pointSize: Maui.Style.fontSizes.small
				color: control.Kirigami.Theme.textColor
				opacity: control.isCurrentItem ? 1 : 0.5
			}
		}
	}	
}
