
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

ItemDelegate
{
	id: control	
	property bool isDetails : false
	property bool showDetailsInfo: false
	
	property int folderSize : iconSize
	property int emblemSize: Maui.Style.iconSizes.medium
	property bool isHovered :  hovered
	property bool showLabel : true
	property bool showEmblem : false
	property bool showSelectionBackground : true
	property bool showTooltip : false
	property bool showThumbnails : false
	property bool draggable : false
	
	property bool emblemAdded : false
	property bool keepEmblemOverlay : false
	property bool isCurrentListItem :  ListView.isCurrentItem
	
	property int radius: 0
	
	property color labelColor : (isCurrentListItem || GridView.isCurrentItem || (keepEmblemOverlay && emblemAdded)) && !hovered && showSelectionBackground ? Qt.darker(Kirigami.Theme.highlightColor, 3) :  Kirigami.Theme.textColor
	property color hightlightedColor : GridView.isCurrentItem || hovered || (keepEmblemOverlay && emblemAdded) ? Kirigami.Theme.highlightColor : "transparent"
	
	property string rightEmblem
	property string leftEmblem : "list-add"
	
	
	//override the itemdelegate default signals to allow dragging content
	signal pressed(var mouse)
	signal pressAndHold(var mouse)
	signal clicked(var mouse)
	
	signal rightClicked()
	signal emblemClicked(int index)
	signal rightEmblemClicked(int index)
	signal leftEmblemClicked(int index)
	
	hoverEnabled: !Kirigami.Settings.isMobile
	
	opacity: (model.hidden == true || model.hidden == "true" )? 0.5 : 1
	
	padding: 0
	bottomPadding: padding
	rightPadding: padding
	leftPadding: padding
	topPadding: padding
	
	background: null
	
	//dragging still needs more work
	Drag.active: _mouseArea.drag.active && control.draggable
	Drag.dragType: Drag.Automatic
	Drag.supportedActions: Qt.CopyAction
	Drag.mimeData:
	{
		"text/uri-list": model.path
	}	
	
	MouseArea
	{
		id: _mouseArea
		anchors.fill: parent
		acceptedButtons:  Qt.RightButton | Qt.LeftButton
		drag.target: control.draggable ? parent : undefined
		
		onClicked:
		{
			if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
				rightClicked()
				else	
					control.clicked(mouse)
		}
		
		onPressed: 
		{	
			if(control.draggable)
				loader.grabToImage(function(result)
				{
					parent.Drag.imageSource = result.url
				})
				
				control.pressed(mouse)			
		}
		
		onPressAndHold : control.pressAndHold(mouse)
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
		size: Maui.Style.iconSizes.small
		Kirigami.Theme.backgroundColor: Kirigami.Theme.highlightColor
		Kirigami.Theme.textColor: Kirigami.Theme.highlightedTextColor
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
		Kirigami.Theme.backgroundColor: Kirigami.Theme.highlightColor
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
				anchors.centerIn: parent
				source: model.thumbnail ? model.thumbnail : undefined
				height: Math.min(folderSize, sourceSize.height)
				width: isDetails ? folderSize : Math.min(control.width * 0.9, sourceSize.width)
				//				sourceSize.width: width
				//				sourceSize.height: height
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				fillMode: Image.PreserveAspectCrop
				cache: false
				asynchronous: true
				smooth: true
				
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
				sourceComponent: img.status === Image.Ready ? undefined : iconComponent
			}
		}
	}
	
	Component
	{
		id: iconComponent
		
		Kirigami.Icon
		{
			source: model.icon
			fallback: "qrc:/assets/application-x-zerosize.svg"
			height: folderSize
			width: height
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
					color: control.hightlightedColor
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
				Layout.alignment: Qt.AlignRight
				
				Label
				{
					Layout.alignment: Qt.AlignRight					
					Layout.fillHeight: true
					horizontalAlignment: Qt.AlignRight
					verticalAlignment: Qt.AlignBottom
					elide: Qt.ElideRight
					wrapMode: Text.NoWrap
					font.pointSize: Maui.Style.fontSizes.small
					color: labelColor
					opacity: isCurrentListItem ? 1 : 0.5
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
					color: labelColor
					opacity: isCurrentListItem ? 1 : 0.5
				}
			}
		}		
	}
	
	Item
	{
		anchors
		{
			fill: parent
			topMargin: control.topPadding
			bottomMargin: control.bottomPadding
			leftMargin: control.leftPadding
			rightMargin: control.rightPadding
			margins: control.padding
		}
		
		Rectangle
		{
			visible: control.isDetails && control.isCurrentListItem
			anchors.fill: parent
			border.color: Kirigami.Theme.highlightColor
			color: "transparent"
			radius: control.radius
		}
		
		Rectangle
		{
			anchors.fill: parent			
			color: !control.isDetails? "transparent" : (control.isCurrentListItem || (control.hovered && control.isDetails) ? Kirigami.Theme.highlightColor :
			index % 2 === 0 ? Qt.lighter( Kirigami.Theme.backgroundColor,1.2) :  Kirigami.Theme.backgroundColor)		
			radius: control.radius
			opacity: control.isCurrentListItem || control.hovered ? 0.4 : 1
			
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
				Layout.maximumWidth: folderSize
				Layout.row: 1
				Layout.column: 1
				Layout.alignment: Qt.AlignCenter
				Layout.leftMargin: isDetails ? Maui.Style.space.medium : 0
				
				Loader
				{
					id: loader
					anchors.centerIn: parent
					sourceComponent: model.mime ? (model.mime.indexOf("image") > -1 && showThumbnails ? imgComponent :
					iconComponent) : iconComponent				
				}
				
				Maui.Badge
				{
					iconName: "link"
					anchors.left: parent.left
					anchors.bottom: parent.bottom
					visible: (model.issymlink == true) || (model.issymlink == "true")
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
				Layout.maximumHeight: (isDetails ? parent.height :  Maui.Style.fontSizes.default * 5)
				Layout.minimumHeight: (isDetails ? parent.height :  control.height - folderSize - Maui.Style.space.tiny)
				Layout.preferredHeight: (isDetails ? parent.height : control.height - folderSize - Maui.Style.space.tiny)
				
				Layout.row: isDetails ? 1 : 2
				Layout.column: isDetails ? 2 : 1
				
				Layout.leftMargin: isDetails ? space.medium : 0
				
				sourceComponent: model.label && model.label.length && showLabel? labelComponent : undefined			
			}
			
			
			Loader
			{
				id: detailsInfoLoader
				sourceComponent: isDetails && showDetailsInfo ? detailsComponent : undefined
				Layout.fillWidth: isDetails && showDetailsInfo
				Layout.maximumHeight: ( isDetails && showDetailsInfo ? parent.height :  fontSizes.default * 5)
				Layout.minimumHeight: ( isDetails && showDetailsInfo ? parent.height :  control.height - folderSize - Maui.Style.space.tiny)
				Layout.preferredHeight: ( isDetails && showDetailsInfo ? parent.height : control.height - folderSize - Maui.Style.space.tiny)
				Layout.maximumWidth: control.width * (isMobile ? 0.5 : 0.3)
				Layout.row:  isDetails && showDetailsInfo ? 1 : 2
				Layout.column: isDetails && showDetailsInfo ? 3 : 0
				Layout.rightMargin: Maui.Style.space.medium
			}		
		}
	}	
}
