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
import "private"

Maui.Dialog
{
	
	title: qsTr("Sync...")
	message: qsTr("Enter your server address to sync your information.")
	entryField: true
	acceptText: qsTr("Continue")
	rejectText: qsTr("Cancel")
	textEntry.placeholderText: "Server Address"
	
	property alias webView: webViewer.item
	
	onAccepted: 
	{
		console.log("SERVER ADRESS", textEntry.text)
		swipeView.currentIndex = 1
		syncPopup.open()
		
	}
	
	Maui.Popup
	{
		id: syncPopup
		
	}
	
	swipeViewContent: 
	[
	
	
	Item{
		SyncLinux
		{
			anchors.fill: parent
		}
	},
	
	Rectangle
	{
		color: "pink"
		height: 200
		width: 290
		Loader
	{
		id: webViewer	
		height: parent.height
		width: parent.width
		source: isAndroid ? "qrc:/maui/kit/private/SyncAndroid.qml" :
		"qrc:/maui/kit/private/SyncLinux.qml"
		
		onVisibleChanged:
		{
			if(!visible) webView.url = "about:blank"
		}
		
	}
	}
	
	]
	
}
