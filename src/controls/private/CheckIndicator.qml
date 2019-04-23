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
import QtQml 2.12

import org.kde.mauikit 1.0 as Maui

Rectangle
{
	
	property QtObject root
	
	x: parent.mirrored ? parent.width - width - parent.rightPadding : parent.spacing
	y: parent.topPadding + (parent.availableHeight - height) / 2
	
	height: iconSizes.small * 1.2
	width: height		
	
	visible: parent.checkable
	
	color: "transparent"
		
	
	Rectangle
	{
		anchors.fill: parent
		color: root.checked ? colorScheme.highlightColor : colorScheme.viewBackgroundColor;
		opacity: 0.4
		radius: radiusV	
		z: -1
	}
	
	Maui.ToolButton
	{
		visible: root.checked
		enabled: false
		iconName: "checkbox"
		iconColor: root.colorScheme.textColor
		size: parent.height * 0.8
		anchors.centerIn: parent
	}
	
	border.color: root.checked ? colorScheme.highlightColor : colorScheme.borderColor;
	radius: radiusV
}

