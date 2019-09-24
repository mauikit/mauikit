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

ItemDelegate
{
	id: control
	
	property bool isCurrentListItem :  ListView.isCurrentItem
	property bool labelVisible : true
	property int iconSize : Maui.Style.iconSizes.medium    
	property int radius : Maui.Style.radiusV
	
	property alias label: controlLabel.text
	property alias iconName: controlIcon.source  
	
	signal rightClicked()
	
	width: parent.width
	height: Math.max(control.iconSize + Maui.Style.space.big, Maui.Style.rowHeight)
	
	clip: true
	
	property color itemFgColor : Kirigami.Theme.textColor
	property color labelColor: ListView.isCurrentItem ? Qt.darker(Kirigami.Theme.highlightColor, 3) :
	itemFgColor
	
	hoverEnabled: !Kirigami.Settings.isMobile
	background: null
	padding: 0
	leftPadding: Maui.Style.space.small
	rightPadding: Maui.Style.space.small

	ToolTip.delay: 1000
	ToolTip.timeout: 5000
	ToolTip.visible: hovered 
	ToolTip.text: qsTr(control.label)
	
	MouseArea
	{
		anchors.fill: parent
		acceptedButtons:  Qt.RightButton
		onClicked:
		{
			if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
				rightClicked()
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
			visible: control.isCurrentListItem
			anchors.fill: parent
			border.color: Kirigami.Theme.highlightColor
			color: "transparent"
			radius: control.radius
			
		}
		
		Rectangle
		{
			anchors.fill: parent
			color: control.isCurrentListItem || hovered ? Kirigami.Theme.highlightColor: "transparent"
			opacity: control.hovered || control.isCurrentListItem ? 0.4 : 1	
			radius: control.radius
		}
		
		RowLayout
		{
			anchors.fill: parent
			
			Item
			{
				Layout.fillHeight: true
				Layout.preferredWidth: model.icon ? parent.height : 0
				visible: model.icon !== typeof("undefined")
				
				Kirigami.Icon
				{
					id: controlIcon
					anchors.centerIn: parent
					source: model.icon ? model.icon : ""
					color: control.labelColor
					height: control.iconSize
					width: height
				}
			}
			
			Label
			{
				id: controlLabel
				visible: control.labelVisible
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignVCenter
				verticalAlignment:  Qt.AlignVCenter
				horizontalAlignment: Qt.AlignLeft
				
				text: model.label
				font.bold: false
				elide: Text.ElideRight
				wrapMode: Text.NoWrap
				font.pointSize: Kirigami.Settings.isMobile ? Maui.Style.fontSizes.big :
				Maui.Style.fontSizes.default
				color: control.labelColor
			}
			
			Item
			{
				visible: typeof model.count !== "undefined" && model.count && model.count > 0 && control.labelVisible
				Layout.fillHeight: true
				Layout.preferredWidth: Math.max(Maui.Style.iconSizes.big + Maui.Style.space.small, _badge.implicitWidth)
				Layout.alignment: Qt.AlignRight
				Maui.Badge
				{
					id: _badge
					anchors.centerIn: parent
					text: model.count                
				}
			}		
		}		
	}
	
	
	function clearCount()
	{
		console.log("CLEANING SIDEBAR COUNT")
		model.count = 0
	}
}
