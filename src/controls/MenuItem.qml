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
import QtQuick.Controls 2.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.0 as Kirigami
import "private"

MenuItem
{
	id: control	
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
	
	width: parent.width
	height: control.visible ? rowHeight : 0
	spacing: space.medium
	font.pointSize: fontSizes.default
	
	icon.width: iconSizes.medium
	icon.height: iconSizes.medium
	
	Component
	{
		id: _iconComponent
		
		Item
		{
			anchors.fill: parent
			
			Maui.ToolButton
			{
				id: _controlIcon
				anchors.centerIn: parent
				iconName: control.icon.name
				size: control.icon.height
				isMask: true
				enabled: false
				iconColor: _controlLabel.color
			}
		}
	}
	
	contentItem: RowLayout
	{
		anchors.fill: control
		anchors.leftMargin: control.checkable ? control.indicator.width + control.spacing + space.big : control.spacing
		anchors.rightMargin: control.spacing
		
		Loader
		{
			id: _iconLoader	
			Layout.fillHeight: true
			Layout.preferredWidth: control.icon.name.length ? control.icon.width + space.medium : 0
			Layout.alignment: Qt.AlignVCenter
			
			sourceComponent: control.icon.name.length ? _iconComponent : undefined			
		}
		
		Item
		{
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignVCenter
			Layout.leftMargin: control.icon.name.length ? space.medium : 0
			
			Label
			{
				id: _controlLabel
				visible: control.text
				height: parent.height
				width: parent.width
				verticalAlignment:  Qt.AlignVCenter
				horizontalAlignment: Qt.AlignLeft
				
				text: control.action ? control.action.text : control.text
				font: control.font
				elide: Text.ElideRight
				
				color: control.hovered && !control.pressed ? colorScheme.highlightedTextColor : colorScheme.textColor
			}
		}
	}	
	
	indicator: CheckIndicator
	{
		id: _checkIndicator
		root: control
    }

	background: Item
	{
		anchors.fill: parent
		implicitWidth: Kirigami.Units.gridUnit * 8
		implicitHeight: rowHeight
		
		Rectangle 
		{
			anchors.fill: parent
			color: colorScheme.highlightColor
			opacity: control.hovered && !control.pressed ? 1 : 0
			Behavior on opacity { NumberAnimation { duration: 150 } }
		}
	}	
}
