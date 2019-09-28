
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
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

ItemDelegate
{
	id: control
	property bool isDetails : false
	property bool showDetailsInfo: false
	
	property int emblemSize: Maui.Style.iconSizes.medium
	property bool isHovered :  hovered
	property bool showLabel : true
	property bool showEmblem : true
	property bool showSelectionBackground : true
	property bool showTooltip : false
	property bool showThumbnails : false
	
	property bool emblemAdded : false
	property bool keepEmblemOverlay : false
	property bool isCurrentListItem :  ListView.isCurrentItem
	
	property bool fitImage : true
	
	property color labelColor : (isCurrentListItem || GridView.isCurrentItem || (keepEmblemOverlay && emblemAdded)) && !hovered && showSelectionBackground ? highlightedTextColor : textColor
	property color hightlightedColor : GridView.isCurrentItem || hovered || (keepEmblemOverlay && emblemAdded) ? highlightColor : "transparent"
	
	property string rightEmblem
	property string leftEmblem : "list-add"
	
	signal rightClicked()
	signal emblemClicked(int index)
	signal rightEmblemClicked(int index)
	signal leftEmblemClicked(int index)
	
	focus: true
	clip: true
	hoverEnabled: !isMobile
	
	background: Rectangle
	{
		color: !isDetails? "transparent" : (isCurrentListItem ? highlightColor :
		index % 2 === 0 ? Qt.lighter(backgroundColor,1.2) : backgroundColor)
		
	}
	
	MouseArea
	{
		anchors.fill: parent
		acceptedButtons:  Qt.RightButton
		onClicked:
		{
			if(!isMobile && mouse.button === Qt.RightButton)
				rightClicked()
		}
	}
	
	Maui.Badge
	{
		id: leftEmblemIcon
		iconName: leftEmblem
		visible: (isHovered || keepEmblemOverlay) && showEmblem && leftEmblem
		z: 999
		anchors.top: parent.top
		anchors.left: parent.left
		onClicked: leftEmblemClicked(index)
		// 		Component.onCompleted: leftEmblemIcon.item.isMask = false
		size: Maui.Style.iconSizes.small
	}
	
	Maui.Badge
	{
		id: rightEmblemIcon
		iconName: rightEmblem
		visible: (isHovered || keepEmblemOverlay) && showEmblem && rightEmblem
		z: 999
		size: Maui.Style.iconSizes.medium
		anchors.top: parent.top
		anchors.right: parent.right
		onClicked: rightEmblemClicked(index)
	}
	
	Component
	{
		id: imgComponent
		
		Item
		{
			anchors.fill: parent
			Image
			{
				id: img
				clip: true
				anchors.centerIn: parent
				source: model.thumbnail
				height: parent.height
				width: isDetails ? parent.width : control.width * 0.9
				sourceSize.width: width
				sourceSize.height: height
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				fillMode: fitImage ? Image.PreserveAspectFit : Image.PreserveAspectCrop
				cache: true
				asynchronous: true
				
				layer.enabled: true
				layer.effect: OpacityMask
				{
					maskSource: Item
					{
						width: img.sourceSize.width
						height: img.sourceSize.height
						Rectangle
						{
							anchors.centerIn: parent
							width: img.sourceSize.width
							height: img.sourceSize.height
							radius: Maui.Style.radiusV
						}
					}
				}
			}
			
			Loader
			{
				anchors.centerIn: parent				
				sourceComponent: img.status === Image.Ready ? undefined : iconComponent
			}
		}
	}
	
	Component
	{
		id: iconComponent
		
		ToolButton
		{
			icon.name: model.icon
			icon.source: "qrc:/assets/application-x-zerosize.svg"
			icon.color: (size <= Maui.Style.iconSizes.medium ?  "transparent" : labelColor)
			icon.width: Math.min(Maui.Style.iconSizes.huge, Math.min(control.width, control.height))
			enabled: false
		}
	}
	
	Component
	{
		id: labelComponent			
		
		Item
		{
			anchors.fill: parent
			Label
			{
				id: label
				text: model.label
				width: parent.width
				height: parent.height
				horizontalAlignment: isDetails? Qt.AlignLeft : Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: Maui.Style.fontSizes.default
				color: labelColor
				
				Rectangle
				{
					visible: parent.visible && showSelectionBackground && !isDetails
					anchors.fill: parent
					
					z: -1
					radius: Maui.Style.radiusV
					color: hightlightedColor
					opacity: hovered ? 0.25 : 0.5
				}
			}
		}
	}
	
	Component
	{
		id: detailsComponent
		
		RowLayout
		{
			anchors.fill: parent
			
			ColumnLayout
			{
				Layout.fillHeight: true
				Layout.fillWidth: true				
				Layout.alignment: Qt.AlignRight
				
				width: parent.width
				height: parent.height
				
				Label
				{
					Layout.alignment: Qt.AlignRight					
					Layout.fillWidth: true
					Layout.fillHeight: true
					horizontalAlignment: Qt.AlignRight
					verticalAlignment: Qt.AlignBottom
					elide: Qt.ElideRight
					wrapMode: Text.Wrap
					font.pointSize: Maui.Style.fontSizes.small
					color: labelColor
					opacity: isCurrentListItem ? 1 : 0.5
					text: model.owner
				}
				
				Label
				{
					Layout.alignment: Qt.AlignRight
					
					Layout.fillWidth: true
					Layout.fillHeight: true
					
					text: model.description
					
					horizontalAlignment: Qt.AlignRight
					verticalAlignment: Qt.AlignTop
					elide: Qt.ElideRight
					wrapMode: Text.Wrap
					font.pointSize: Maui.Style.fontSizes.small
					color: labelColor
					opacity: isCurrentListItem ? 1 : 0.5
				}
			}
		}		
	}
	
	GridLayout
	{
		id: delegatelayout
		anchors.fill: parent
		rows: isDetails ? 1 : 2
		columns: isDetails && showDetailsInfo ? 3 : (isDetails && !showDetailsInfo ? 2 : 1)
		rowSpacing: Maui.Style.space.tiny
		columnSpacing: Maui.Style.space.tiny
		
		Item
		{
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.maximumHeight: parent.height * 0.8
			Layout.maximumWidth: isDetails ? parent.height * 0.8 : parent.width
			Layout.row: 1
			Layout.column: 1
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: isDetails ? Maui.Style.space.medium : 0
			
			Loader
			{
				id: loader
				anchors.centerIn: parent
				anchors.fill: parent
				sourceComponent: imgComponent
			}
			
			ToolTip.delay: 1000
			ToolTip.timeout: 5000
			ToolTip.visible: hovered && showTooltip
			ToolTip.text: model.tooltip ? model.tooltip : model.path
		}		
		
		Loader
		{
			id: labelLoader
			Layout.fillWidth: true
			Layout.fillHeight: !isDetails
			Layout.maximumHeight: (isDetails ? parent.height :  parent.height * 0.2)
			Layout.minimumHeight: (isDetails ? parent.height :  parent.height * 0.1)
			Layout.preferredHeight: (isDetails ? parent.height : parent.height * 0.2)
			
			Layout.row: isDetails ? 1 : 2
			Layout.column: isDetails ? 2 : 1
			
			Layout.leftMargin: isDetails ? Maui.Style.space.medium : 0
			
			sourceComponent: labelComponent
		}
		
		
		Loader
		{
			id: detailsInfoLoader
			sourceComponent: isDetails && showDetailsInfo ? detailsComponent : undefined
			Layout.fillWidth: isDetails && showDetailsInfo
			Layout.maximumHeight: isDetails ? (showDetailsInfo ? parent.height :  Maui.Style.fontSizes.default * 5) : undefined
			Layout.minimumHeight: isDetails ? ( showDetailsInfo ? parent.height :  control.height -  Maui.Style.space.tiny) : undefined
			Layout.preferredHeight:  isDetails ? (showDetailsInfo ? parent.height : control.height -  Maui.Style.space.tiny) : undefined
			Layout.maximumWidth: control.width * (isMobile ? 0.5 : 0.3)
			Layout.row:  isDetails && showDetailsInfo ? 1 : 2
			Layout.column: isDetails && showDetailsInfo ? 3 : 0
			Layout.rightMargin: Maui.Style.space.medium
			// 			Layout.leftMargin: isDetails ? Maui.Style.space.medium : 0
		}
	}
}
