
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
	property string appName : Maui.App.name
	property string appVersion : Maui.App.version
	property string organizationName : Maui.App.org
	property string organizationDomain : Maui.App.domain
	property string appDescription : Maui.App.description
	property string appLink: "www.maui-project.org"
	property string appDonation: ""
	property string appIcon: Maui.App.iconName
	
	defaultButtons: false
		widthHint: 0.9
		heightHint: 0.8
		
		maxWidth: unit * 400
		maxHeight: unit * 250
		
		page.padding: space.small
		
		
		footBar.middleContent: ToolButton
		{
			icon.name: "link"
			onClicked: Maui.FM.openUrl(control.appLink)
			
		}
		
		footBar.rightContent: ToolButton
		{
			icon.name: "love"
			onClicked: Maui.FM.openUrl(control.appDonation)
			
		}
		
		footBar.leftContent: ToolButton
		{
			icon.name: "documentinfo"
		}		
		
		RowLayout
		{
			id: layout
			anchors.centerIn: parent
			width: parent.width
			height: parent.height * 0.7	
			
			
			Item
			{
				Layout.fillHeight: true		
				Layout.margins: space.small
				Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
				Layout.minimumWidth: iconSizes.huge
				Layout.maximumWidth: iconSizes.huge
				Layout.preferredWidth: iconSizes.huge
				Layout.minimumHeight: iconSizes.huge           
				
				clip: true 
				
				Image
				{
					source: control.appIcon
					width: iconSizes.huge
					height: width
					sourceSize.width: width
					sourceSize.height: height
					horizontalAlignment: Qt.AlignHCenter
					asynchronous: true
					
					fillMode: Image.PreserveAspectFit
				}
			}			
			
			Item
			{
				id: _descriptionItem
				Layout.fillWidth: true
				Layout.fillHeight: true			
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				ScrollView
				{
					anchors.fill: parent
					
					contentHeight: _columnInfo.implicitHeight
					
					padding: 0
					clip: true
					
					ColumnLayout
					{
						
						id: _columnInfo
						width: parent.width
						spacing: 0
						Label
						{
							Layout.fillWidth: true						
							Layout.alignment: Qt.AlignLeft
							clip: true
							width: parent.width
							height: parent.height
							color: Kirigami.Theme.textColor
							text: appName
							font.weight: Font.Bold
							font.bold: true
							font.pointSize: fontSizes.huge
						}
						
						Label
						{
							Layout.fillWidth: true
							// 					Layout.preferredHeight: fontSizes.default
							
							Layout.alignment: Qt.AlignLeft
							clip: true 
							
							width: parent.width
							height: parent.height
							color:  Qt.lighter(Kirigami.Theme.textColor, 1.2)
							text: appVersion
							font.pointSize: fontSizes.default
							
						}
						
						Label
						{
							id: body
							// 					Layout.fillWidth: true
							// 					Layout.fillHeight: true
							Layout.preferredWidth:_descriptionItem.width
							
							padding: 0
							// 				placeholderText: qsTr("App description")
							enabled: false
							text: appDescription
// 							textFormat : TextEdit.AutoText
							color: Kirigami.Theme.textColor
							font.pointSize: fontSizes.default
							wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
							
							clip: true
							// 				background: Rectangle
							// 				{
							// 					color: "transparent"
							// 				}
						}
						
						Kirigami.Separator
						{
							Layout.fillWidth: true
							Layout.preferredHeight: 1
							Layout.alignment: Qt.AlignLeft
							Layout.margins: space.big
							opacity: 0.4
						}
						
						Label
						{
							color: Kirigami.Theme.textColor
							Layout.preferredWidth:_descriptionItem.width							
							
							text: qsTr("Built with MauiKit " + Maui.App.mauikitVersion + " and Kirigami." )
							font.pointSize: fontSizes.default
							wrapMode: TextEdit.WrapAnywhere
							
							
						}
					}
					
				}
				
			}
			
			            
			
			
			
			
			//          Item
			//         {
			//             Layout.fillWidth: true
			//             Layout.fillHeight: true
			//             Layout.row: 5
			//             Layout.column: 2
			//             Layout.margins: space.big
			//             Layout.alignment: Qt.AlignLeft | Qt.AlignTop
			//
			//             Label
			//             {
			//                 color: textColor
			//                 width: parent.width
			//                 height: parent.height
			//
			//                 text: "MauiKit " + app.mauikit + " Qt " +app.qt
			//                 font.pointSize: fontSizes.default
			//                  wrapMode: TextEdit.WrapAnywhere
			//
			//             }
			//         }
			
		}		
		
}
