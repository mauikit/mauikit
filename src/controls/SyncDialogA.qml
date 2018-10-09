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
	id: control
	
	title: qsTr("Sync...")
	message: qsTr("Enter your server address to sync your information.")
	entryField: true
	acceptText: swipeView.currentIndex === 0 ? qsTr("Continue") : qsTr("Finish")
	rejectText: swipeView.currentIndex === 0 ? qsTr("Cancel") : qsTr("Return")
	textEntry.placeholderText: "Server Address"
	
	maxHeight: swipeView.currentIndex === 0 ? unit * 300 : unit * 600
	maxWidth:swipeView.currentIndex === 0 ? unit * 300 : unit * 500
	
	onAccepted:
	{
		if(swipeView.currentIndex === 0)
		{
			
			swipeView.currentIndex = 1
			webView.url = textEntry.text
			
		}else
		{
			console.log("login")
		}
	}
	
	onRejected:
	{
		if(swipeView.currentIndex === 1)
		{
			swipeView.currentIndex = 0
		}else
		{
			close()
		}
	}
	
	
	swipeViewContent: 
	[
	
	Item
	{
		
		SyncAndroid
		{
			id: webView
			anchors.fill: parent			
		}
	}
	
	]
	
}
