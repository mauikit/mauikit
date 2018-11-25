import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

import SyncingModel 1.0 
import SyncingList 1.0

Maui.Dialog
{
	
	id: control
	defaultButtons: false
		
		maxHeight: 300* unit
		maxWidth: maxHeight
		
		Maui.SyncDialog
		{
			id: _syncDialog
			onAccepted:
			{
				control.addAccount(serverField.text, userField.text, passwordField.text);
				close();
			}
		}
		
		footBar.margins: 0
		footBar.middleContent: Maui.Button
		{
			colorScheme.textColor: "white"
			colorScheme.backgroundColor: suggestedColor
			text: qsTr("Add account")
			onClicked: _syncDialog.open()
		}
		
		SyncingModel
		{
			id: _syncingModel
			list: _syncingList
		}
		
		SyncingList
		{
			id: _syncingList
		}
		
		Maui.Dialog
		{
			id: _removeDialog
			
			maxWidth: unit * 400
			title: qsTr("Remove account?")
			message: qsTr("Are you sure you want to remove this account?")
			
			acceptButton.text: qsTr("Delete account")
			rejectButton.visible: false
			
			onAccepted: 
			{
				var account = _syncingList.get(_listView.currentIndex)
				console.log(account.label)
				control.removeAccount(account.server, account.user)
				close()
			}
			
			footBar.rightContent: Maui.Button
			{
				text: qsTr("Delete account and files")			
				onClicked: 
				{
					var account = _syncingList.get(_listView.currentIndex)
					control.removeAccountAndFiles(account.server, account.user)
					close()
				}
			}
		}
		
		Maui.Menu
		{	
			id: _menu
			Maui.MenuItem
			{
				text: qsTr("Edit...")
				onTriggered:
				{
					previewer.show(control.items[0].path)
					close()
				}
			}
			
			Maui.MenuItem
			{
				text: qsTr("Remove...")
				colorScheme.textColor: dangerColor
				
				onTriggered: _removeDialog.open()
			}
			
		}
		
		ListView
		{
			id: _listView
			anchors.fill: parent
			model: _syncingModel
			delegate: Maui.ListDelegate 
			{
				id: delegate
				label: model.label
				radius: radiusV
				Connections
				{
					target: delegate
					onClicked:
					{
						_listView.currentIndex = index				
					}	
					
					onPressAndHold:
					{
						_listView.currentIndex = index
						_menu.popup()	
					}
					
					onRightClicked:
					{
						_listView.currentIndex = index
						_menu.popup()	
					}
					
				}
			}
			
			Maui.Holder
			{
				visible: _listView.count == 0
				isMask: false
				isGif: false
				emojiSize: iconSizes.huge
				title: qsTr("No accounts yet!")
				body: qsTr("Start adding new accounts to sync your files, music, contacts, images, notes, etc...")
			}
			
		}
		
		function addAccount(server, user, password)
		{
			if(user.length)
				_syncingList.insert({server: server, user: user, password: password})
		}
		
		function removeAccount(server, user)
		{
			if(server.length && user.length)
				_syncingList.removeAccount(server, user)
		}
		
		function removeAccountAndFiles(server, user)
		{
			if(server.length && user.length)
				_syncingList.removeAccountAndFiles(server, user)
		}
}
