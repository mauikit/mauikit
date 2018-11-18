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
import org.kde.kirigami 2.2 as Kirigami

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
	
	default property alias content : page.content
		
	property alias swipeViewContent : content.data
	property alias swipeView : swipeView
	
	property alias acceptButton : _acceptButton
	property alias rejectButton : _rejectButton		
	property alias textEntry : _textEntry
	property alias page : page
	property alias footBar : page.footBar
	property alias headBar: page.headBar
	property alias headBarTitle: page.headBarTitle
		
	signal accepted()
	signal rejected()
	
	maxWidth: unit * 300
	maxHeight: _pageContent.implicitHeight + page.footBar.height + page.margins + space.huge
	
	widthHint: 0.9
	heightHint: 0.9
	z: 1
    clip: false
	
	Maui.Popup
	{
		id: _confirmationDialog
// 		title: qsTr("Are you sure?")
// 		message: qsTr("Click Accept to finish or Cancel to abort.")
// 		
// 		onAccepted: 
// 		{
// 			control.accepted()
// 			close()
// 		}
// 		
// 		onRejected: 
// 		{
// 			close()
// 			control.close()
// 		}
	}
	
	Maui.Badge
	{
		iconName: "window-close"
		colorScheme.backgroundColor: hovered ?  dangerColor : colorScheme.altColor

		anchors
		{
			verticalCenter: parent.top
			horizontalCenter: parent.left			
		}

		z: control.z+1
		
		onClicked:
		{
			rejected()
			close()
		}		
	}
	
	Maui.Page
	{
		id: page
		headBar.visible: headBar.count > 2
		anchors.fill: parent
		footBar.dropShadow: false
		footBar.drawBorder: false
		margins: space.big
		clip: true
		headBarExit: false
		colorScheme.backgroundColor : control.colorScheme.backgroundColor
		footBar.visible: defaultButtons || footBar.count > 1
		footBar.colorScheme.backgroundColor: colorScheme.backgroundColor
		footBar.margins: space.big
		footBar.rightContent: Row
		{			
			spacing: space.big
			Maui.Button
			{
				id: _rejectButton
				visible: defaultButtons
				colorScheme.textColor: dangerColor
				colorScheme.borderColor: dangerColor
				colorScheme.backgroundColor: "transparent"
				
				text: rejectText
				onClicked: rejected()
				
			}
			
			Maui.Button
			{
				id: _acceptButton	
				visible: defaultButtons
				colorScheme.backgroundColor: infoColor
				colorScheme.textColor: "white"
				text: acceptText
				onClicked: 
				{
					if(confirmationDialog)
						_confirmationDialog.open()
					else
						accepted()
				}
			}
		} 
		
		content: SwipeView
		{
			id: swipeView
			anchors.fill: parent
			interactive: false
			clip: true
			
			background: Rectangle
			{
				color: "transparent"
			}
			
			contentItem: ListView 
			{
				id: content
				implicitHeight: contentHeight
				orientation: ListView.Horizontal
				interactive: swipeView.interactive
				model: swipeView.contentModel
				boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
				flickableDirection: Flickable.AutoFlickDirection
				snapMode: GridView.SnapToRow
				highlightMoveDuration: 0
				clip: true
				currentIndex: swipeView.currentIndex
				
				ScrollIndicator.vertical: ScrollIndicator {}
			}
			
			Item
            {
				ColumnLayout        
				{
					id: _pageContent
					anchors.centerIn: parent
					width: parent.width
					height: implicitHeight
					spacing: space.medium
				
					Label
					{
						width: parent.width
						height: visible ? implicitHeight : 0
						
						visible: title.length > 0
						
						Layout.fillWidth: visible            
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						
						clip: true
						color: colorScheme.textColor
						text: title
						font.weight: Font.Thin
						font.bold: true
						font.pointSize: fontSizes.huge
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

						TextArea
						{
							id: body
							padding: 0
							
							width: parent.width
							height: parent.height
							enabled: false
							text: message
							textFormat : TextEdit.AutoText
							color: colorScheme.textColor
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
						clip: true
						
						Maui.TextField
						{
							id: _textEntry
							anchors.fill: parent
							onAccepted: control.accepted()					
						}
					}			
				}				
			}
		}			
	}
}
