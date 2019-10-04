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
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ItemDelegate
{
	id: control
	
	isCurrentItem : ListView.isCurrentItem
	
	property alias quickButtons : _buttonsRow.data
	property bool showMenuIcon: true
	
	property alias label1 : _label1
	property alias label2 : _label2
	property alias label3 : _label3
	property alias label4 : _label4
	property alias iconImg : _icon
	property int radius : Maui.Style.radiusV
	
	SwipeDelegate
	{
		id: _swipeDelegate
		anchors.fill: parent
		hoverEnabled: true
		clip: true
		Kirigami.Theme.colorSet: Kirigami.Theme.Button
		Kirigami.Theme.inherit: false
		swipe.enabled: showMenuIcon
	
// 	Rectangle
// 		{
// 			id: _bg
// 			visible: swipe.position < 0
// 			Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
// 			Kirigami.Theme.inherit: false
// 			anchors.fill: parent
// 			color: Kirigami.Theme.backgroundColor
// 			border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
// 			radius: control.radius
// 			z: background.z -1
// 		}
// 		
// 		
// 		DropShadow
// 		{
// 			visible: _bg.visible
// 			anchors.fill: background
// 			horizontalOffset: 5
// 			verticalOffset: 0
// 			radius: 8.0
// 			samples: 17
// 			color: Qt.darker(_bg.color, 5)
// 			source: background
// 		}

background: null
		
		RowLayout
		{
			id: _layout
			anchors.fill: parent
			Item
			{
				visible: control.width > Kirigami.Units.gridUnit * 15
				Layout.preferredWidth: visible ? parent.height : 0
				Layout.fillHeight: visible
				Layout.margins: Maui.Style.space.medium
				
				Kirigami.Icon
				{
					id: _icon
					width: Maui.Style.iconSizes.large
					height: width
					anchors.centerIn: parent
				}
			}
			
			
			Item
			{
				id: _info
				
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				ColumnLayout
				{
					anchors.fill: parent
					
					Label
					{
						id: _label1
						visible: text.length
						Layout.fillHeight: visible
						Layout.fillWidth: visible
						font.pointSize: Maui.Style.fontSizes.big
						font.bold: true
						font.weight: Font.Bold
						elide: Text.ElideMiddle
						color: Kirigami.Theme.textColor
					}
					
					Label
					{
						id: _label2
						visible: text.length
						Layout.fillHeight: visible
						Layout.fillWidth: visible
						font.pointSize: Maui.Style.fontSizes.small
						font.weight: Font.Light
						wrapMode: Text.WrapAtWordBoundaryOrAnywhere
						elide: Text.ElideRight
						color: Kirigami.Theme.textColor
					}
				}
			}
			
			Item
			{
				visible: control.width >  Kirigami.Units.gridUnit * 30
				Layout.fillHeight: visible
				Layout.fillWidth: visible
				clip: true
				
				ColumnLayout
				{
					anchors.fill: parent
					
					Label
					{
						id: _label3
						visible: text.length
						Layout.fillHeight: visible
						Layout.fillWidth: visible
						Layout.alignment: Qt.AlignRight
						horizontalAlignment: Qt.AlignRight
						font.pointSize: Maui.Style.fontSizes.small
						font.weight: Font.Light
						wrapMode: Text.WrapAnywhere
						elide: Text.ElideMiddle
						color: Kirigami.Theme.textColor
					}
					
					Label
					{
						id: _label4
						visible: text.length
						Layout.fillHeight: visible
						Layout.fillWidth: visible
						Layout.alignment: Qt.AlignRight
						horizontalAlignment: Qt.AlignRight
						font.pointSize: Maui.Style.fontSizes.small
						font.weight: Font.Light
						wrapMode: Text.WrapAnywhere
						elide: Text.ElideMiddle
						color: Kirigami.Theme.textColor
					}
				}
			}
			
			
			Item
			{
				Layout.fillHeight: true
				Layout.preferredWidth: Math.max(Maui.Style.space.big, _buttonsRow.implicitWidth)
				Layout.alignment: Qt.AlignRight
				Layout.margins: Maui.Style.space.big
				
				Row
				{
					id: _buttonsRow
					anchors.centerIn: parent
					spacing: Maui.Style.space.medium
					ToolButton
					{
						visible: showMenuIcon
						icon.name: "overflow-menu"
						onClicked: _swipeDelegate.swipe.position < 0 ? _swipeDelegate.swipe.close() : _swipeDelegate.swipe.open(SwipeDelegate.Right)
					}
				}
			}
		}
		
		swipe.right: Row
		{
			id: _rowActions
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: Maui.Style.space.big
			padding: Maui.Style.space.medium
			
			ToolButton
			{
				icon.name: "draw-star"
				anchors.verticalCenter: parent.verticalCenter
				//            onClicked:
				//            {
				//                control.favClicked(index)
				//                swipe.close()
				//            }
				
				//            icon.color: model.fav == "1" ? "yellow" : _bg.Kirigami.Theme.textColor
			}
			
			ToolButton
			{
				icon.name: "document-share"
				anchors.verticalCenter: parent.verticalCenter
				//            onClicked: if(isAndroid) Maui.Android.shareContact(model.id)
				//            icon.color: _bg.Kirigami.Theme.textColor
			}
			
			ToolButton
			{
				icon.name: "message-new"
				anchors.verticalCenter: parent.verticalCenter
				//            icon.color: _bg.Kirigami.Theme.textColor
				//            onClicked:
				//            {
				//                _messageComposer.contact = list.get(index)
				//                _messageComposer.open()
				//                swipe.close()
				//            }
			}
			
			ToolButton
			{
				icon.name: "call-start"
				anchors.verticalCenter: parent.verticalCenter
				//            icon.color: _bg.Kirigami.Theme.textColor
				
				//            onClicked:
				//            {
				//                if(isAndroid)
				//                    Maui.Android.call(model.tel)
				//                else
				//                    Qt.openUrlExternally("call://" + model.tel)
				
				//                swipe.close()
				//            }
			}
		}
	}
	
}
