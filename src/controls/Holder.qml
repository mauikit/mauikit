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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.0 as Kirigami
import "private"

Item
{
	id: control
	anchors.fill: parent
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
	property string emoji
	property string message
	property string title
	property string body
	
	property bool isMask : true
	property bool isGif : false
	property int emojiSize : iconSizes.large
	
	property bool enabled: true
	
	signal actionTriggered()
	
	clip: true
	focus: true

	Component
	{
		id: imgComponent
		
		Image
		{
			id: imageHolder
			
			width: emojiSize
			height: emojiSize
			sourceSize.width: width
			sourceSize.height: height
			source: emoji
			asynchronous: true
			horizontalAlignment: Qt.AlignHCenter
			
			fillMode: Image.PreserveAspectFit
			
			
			HueSaturation
			{
				anchors.fill: parent
				source: parent
				saturation: -1
				lightness: 0.3
				visible: isMask
			}
		}
	}
	
	Component
	{
		id: animComponent
		AnimatedImage
		{ 
			id: animation; 
			source: emoji			
		}
	}
	
	Column
	{
		anchors.centerIn: parent
		height: implicitHeight
		width: parent.width * 0.7
		
		Loader
		{
			id: loader			
			height: control.emoji ? emojiSize : 0
			width: height
			anchors.horizontalCenter: parent.horizontalCenter
		
			sourceComponent: control.emoji ? (isGif ? animComponent : imgComponent) : undefined
		}
		
		
		Label
		{
			id: textHolder
			width: parent.width
		
			opacity: 0.5
			text: message ? qsTr(message) : "<h3>"+title+"</h3><p>"+body+"</p>"
			font.pointSize: fontSizes.default
			
			padding: space.medium
			font.bold: true
			textFormat: Text.RichText
			horizontalAlignment: Qt.AlignHCenter
			elide: Text.ElideRight
			color: colorScheme.textColor
			wrapMode: Text.Wrap
			
			MouseArea
			{
				anchors.fill: parent
				enabled: control.enabled
				onClicked: actionTriggered()
				
				hoverEnabled: true
				
				Rectangle
				{
					anchors.fill: parent
					color: parent.hovered ? control.colorScheme.backgroundColor : "transparent"
					radius: radiusV
				}
				
			}
		}
	}
	
	
}


