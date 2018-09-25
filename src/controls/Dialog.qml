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
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

Maui.Popup
{
    id: control
    
    property string message : ""
    property string title: ""
    property string acceptText: "Ok"
    property string rejectText: "No"
    property bool defaultButtons: true
    property bool entryField: false
    property alias textEntry : __textEntry
    default property alias content : page.content
	property alias footBar : page.footBar
	property alias headBar: page.headBar
	property alias headBarTitle: page.headBarTitle
        
	signal accepted()
	signal rejected()
        
	maxWidth: unit * 300
	maxHeight: unit * (message.length> 0? 250 : 200)
        
	widthHint: 0.9
	heightHint: 0.9
        
	bottomPadding: space.big
	
	Maui.Page
	{
		id: page
		headBarVisible: false
		anchors.fill: parent
		footBar.dropShadow: false
		footBar.drawBorder: false
		margins: space.big
		footBarVisible: defaultButtons || footBar.count > 2
		
		content: ColumnLayout        
		{
			id: __pageContent
			anchors.fill: parent           
			
			Item
			{
				visible: title.length > 0
				Layout.fillWidth: visible            
				Layout.margins: space.small
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				
				Label
				{
					width: parent.width
					height: parent.visible ? parent.height : 0
					color: textColor
					text: title
					font.weight: Font.Thin
					font.bold: true
					font.pointSize: fontSizes.huge
//                         elide: Qt.ElideRight
					
				}                    
			}        
			
			
			ScrollView
			{
				visible: message.length > 0 
				Layout.fillHeight: visible
				Layout.fillWidth: visible           
				Layout.margins: space.small
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				padding: 0                
				
				TextArea
				{
					id: body
					padding: 0
					
					width: parent.width
					height: parent.height
					enabled: false
					text: message
					textFormat : TextEdit.AutoText
					color: textColor
					font.pointSize: fontSizes.default
					wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
					
					background: Rectangle
					{
						color: "transparent"
					}
				}
			} 
			
			Item
			{
				Layout.fillWidth: entryField
				height: entryField ?  iconSizes.big : 0
				visible: entryField
				
				Maui.TextField
				{
					id: __textEntry
					anchors.fill: parent
					onAccepted: control.accepted()
					
				}
			}
			
		}  
		
		footBar.colorScheme.backgroundColor: "transparent"
		footBar.margins: space.big
		footBar.rightContent: Row
		{
			visible: defaultButtons
			spacing: space.big
			Maui.Button
			{
				colorScheme.textColor: dangerColor
				colorScheme.borderColor: dangerColor
				colorScheme.backgroundColor: viewBackgroundColor
				
				text: rejectText
				onClicked: 
				{
					rejected()
					close()
				}
			}
			
			Maui.Button
			{
				colorScheme.backgroundColor: infoColor
				colorScheme.textColor: "white"
				text: acceptText
				onClicked: accepted()
			}
		} 
		
	}
}
