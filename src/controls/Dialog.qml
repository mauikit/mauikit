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
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Popup
{
	id: control
	
	property string message : ""
	property string title: ""
	
	property string acceptText: "Ok"
	property string rejectText: "No"
	
	property bool defaultButtons: true
	property bool confirmationDialog: false
	property bool entryField: false
	
	default property alias content : page.contentData
		
		property alias acceptButton : _acceptButton
		property alias rejectButton : _rejectButton		
		property alias textEntry : _textEntry
		property alias page : page
		property alias footBar : page.footBar
		property alias headBar: page.headBar
		property alias closeButton: _closeButton
		
		signal accepted()
		signal rejected()
		
		clip: false
		
		maxWidth: unit * 300
		maxHeight: (_pageContent.implicitHeight * 1.2) + page.footBar.height + space.huge + page.padding
		
		widthHint: 0.9
		heightHint: 0.9
		
		Maui.Badge
		{
			id: _closeButton
			iconName: "window-close"
			Kirigami.Theme.backgroundColor: hovered ?  dangerColor : Kirigami.Theme.complementaryBackgroundColor
			Kirigami.Theme.textColor: Kirigami.Theme.highlightedTextColor
			
			anchors
			{
				verticalCenter: parent.top
				horizontalCenter: parent.left
				horizontalCenterOffset: control.width === control.parent.width ? _closeButton.width : 0
			}
			
			z: control.z+999
			
			onClicked:
			{
				// 			rejected()
				close()
			}		
		}
		
		contentItem: Maui.Page
		{
			id: page
			// 		headBar.visible: headBar.count > 2
			anchors.fill: parent
			padding: space.huge
			// 		footBar.dropShadow: false
			// 		footBar.drawBorder: false
			// 		margins: space.big
			// 		headBarExit: false
			// 		colorScheme.backgroundColor : control.colorScheme.backgroundColor
			// 		footBar.visible: defaultButtons || footBar.count > 1
			// 		footBar.colorScheme.backgroundColor: colorScheme.backgroundColor
			// 		footBar.margins: space.big
			footBar.visible: control.defaultButtons || footBar.count > 1
			property QtObject _rejectButton : Button
			{
				id: _rejectButton
				visible: defaultButtons
				Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
				// 				Kirigami.Theme.borderColor: dangerColor
				Kirigami.Theme.backgroundColor: Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.2)
				
				text: rejectText
				onClicked: rejected()
				
			}
			
			property QtObject _acceptButton: Button
			{
				id: _acceptButton	
				visible: defaultButtons
				Kirigami.Theme.backgroundColor: Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.2)
				Kirigami.Theme.textColor: Kirigami.Theme.positiveTextColor
				text: acceptText
				onClicked: accepted()
				
			}
			
			Component
			{
				id: _defaultButtonsComponent
				Row
				{			
					spacing: space.big		
					children: [_rejectButton, _acceptButton]		
				} 	
			}
			footBar.rightContent: Loader
			{
				sourceComponent: control.defaultButtons ? _defaultButtonsComponent : undefined
			}
			
			ColumnLayout        
			{
				id: _pageContent
				anchors.fill: parent
				spacing: space.medium
				
				Label
				{
					width: parent.width
					height: visible ? implicitHeight : 0
					
					visible: title.length > 0
					
					Layout.fillWidth: visible            
					Layout.alignment: Qt.AlignLeft | Qt.AlignTop
					
					color: Kirigami.Theme.textColor
					text: title
					font.weight: Font.Thin
					font.bold: true
					font.pointSize: fontSizes.huge
					elide: Qt.ElideRight
					wrapMode: Text.Wrap
					//                         elide: Qt.ElideRight					
				}
				
				ScrollView
				{
					visible: message.length > 0 
					Layout.fillHeight: visible
					Layout.fillWidth: visible           
					
					Layout.alignment: Qt.AlignLeft | Qt.AlignTop
					padding: 0                
					clip: true
					ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
					contentHeight: body.implicitHeight
					Label
					{
						id: body
						width: _pageContent.width							
						padding: 0							
						enabled: false
						text: message
						textFormat : TextEdit.AutoText
						color: Kirigami.Theme.textColor
						font.pointSize: fontSizes.default
						wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
						elide: Text.ElideLeft
					}
				} 	
				
				Maui.TextField
				{
					id: _textEntry
					// 							anchors.fill: parent
					onAccepted: control.accepted()		
					Layout.fillWidth: entryField
					height: entryField ?  iconSizes.big : 0
					visible: entryField
				}							
			}
		}
}
