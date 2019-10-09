
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

Maui.Dialog
{
	id: control

	defaultButtons: false
		widthHint: 0.9
		heightHint: 0.8
		
		maxWidth: Maui.Style.unit * 400
		maxHeight: Maui.Style.unit * 250
		
		page.padding: Maui.Style.space.small
		
		footBar.middleContent: ToolButton
		{
			icon.name: "link"
			onClicked: Qt.openUrlExternally(Maui.App.webPage)			
		}
		
		footBar.rightContent: ToolButton
		{
			icon.name: "love"
			onClicked: Qt.openUrlExternally(Maui.App.donationPage)
		}
		
		footBar.leftContent: ToolButton
		{
			icon.name: "documentinfo"
			onClicked: Qt.openUrlExternally(Maui.App.reportPage)			
		}
		
		RowLayout
		{
			id: layout
			anchors.centerIn: parent
			width: parent.width
			height: parent.height * 0.7
			spacing: Maui.Style.space.big
			
			Item
			{
				visible: parent.width > control.maxWidth * 0.7
				Layout.fillHeight: true
				Layout.margins: Maui.Style.space.small
				Layout.alignment: Qt.AlignVCenter          
				Layout.preferredWidth: Maui.Style.iconSizes.huge
				
				Image
				{
					anchors.centerIn: parent
					source: Maui.App.iconName
					width: Math.max(Maui.Style.iconSizes.huge, parent.width)
					height: width
					sourceSize.width: width
					sourceSize.height: height
					
					asynchronous: true
					
					fillMode: Image.PreserveAspectFit
				}
			}    
			
			Kirigami.ScrollablePage
			{
				id: _descriptionItem
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				Kirigami.Theme.backgroundColor: "transparent"
				padding: 0
				leftPadding: padding
				rightPadding: padding
				topPadding: padding
				bottomPadding: padding
				
				ColumnLayout
				{
					id: _columnInfo
					spacing: Maui.Style.space.medium
					
					Label
					{
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft
						color: Kirigami.Theme.textColor
						text: Maui.App.name
						font.weight: Font.Bold
						font.bold: true
						font.pointSize: Maui.Style.fontSizes.huge
						elide: Text.ElideRight
						wrapMode: Text.NoWrap
					}	
					
					Label
					{
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft
						color:  Qt.lighter(Kirigami.Theme.textColor, 1.2)
						text: Maui.App.version
						font.weight: Font.Light
						font.pointSize: Maui.Style.fontSizes.default
						elide: Text.ElideRight
						wrapMode: Text.WrapAtWordBoundaryOrAnywhere
					}				
					
					Label
					{
						color: Kirigami.Theme.textColor
						Layout.fillWidth: true
						
						text: qsTr("By ") + Maui.App.org
						font.pointSize: Maui.Style.fontSizes.default
						elide: Text.ElideRight
						wrapMode: Text.WrapAtWordBoundaryOrAnywhere
					}
					
					Label
					{
						id: body
						Layout.fillWidth: true
						text:  Maui.App.description
						color: Kirigami.Theme.textColor
						font.pointSize: Maui.Style.fontSizes.default
						elide: Text.ElideRight
						wrapMode: Text.WrapAtWordBoundaryOrAnywhere
					}
					
					Kirigami.Separator
					{
						Layout.fillWidth: true
						Layout.margins: Maui.Style.space.tiny
						opacity: 0.4
					}
					
					Label
					{
						color: Kirigami.Theme.textColor
						Layout.fillWidth: true
						
						text: qsTr("Powered by") + " MauiKit " + Maui.App.mauikitVersion + " and Kirigami."
						font.pointSize: Maui.Style.fontSizes.default
						elide: Text.ElideRight
						wrapMode: Text.WrapAtWordBoundaryOrAnywhere
					}
				}
			}			
		}
}
