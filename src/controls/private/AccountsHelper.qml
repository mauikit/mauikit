import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{	
	id: control
	
	maxHeight: 300* Maui.Style.unit
	maxWidth: maxHeight
	
	property alias model : _syncingModel
	property alias list : _syncingModel.list
	
	Maui.SyncDialog
	{
		id: _syncDialog
		onAccepted:
		{
			control.addAccount(serverField.text, userField.text, passwordField.text);
			close();
		}
	}
	rejectButton.visible: false
	acceptButton.text: qsTr("Add account") 
	onAccepted: _syncDialog.open()		
	
	Maui.BaseModel
	{
		id: _syncingModel
		list: Maui.App.accounts
	}
	
	Maui.Dialog
	{
		id: _removeDialog
		
		maxWidth: Maui.Style.unit * 400
		title: qsTr("Remove account?")
		message: qsTr("Are you sure you want to remove this account?")
		
		rejectButton.text: qsTr("Delete account")
		// 			rejectButton.visible: false
		
		onRejected: 
		{
			var account = Maui.App.accounts.get(_listView.currentIndex)
			console.log(account.label)
			control.removeAccount(account.server, account.user)
			close()
		}
		
		
		footBar.rightContent: Button
		{
			text: qsTr("Delete account and files")			
			onClicked: 
			{
				var account = Maui.App.accounts.get(_listView.currentIndex)
				control.removeAccountAndFiles(account.server, account.user)
				close()
			}
		}
	}
	
	Menu
	{	
		id: _menu
		
		MenuItem
		{
			text: qsTr("Remove...")
			Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
			
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
			radius: Maui.Style.radiusV
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
			emojiSize: Maui.Style.iconSizes.huge
			title: qsTr("No accounts yet!")
			body: qsTr("Start adding new accounts to sync your files, music, contacts, images, notes, etc...")
		}
		
	}
	
	function addAccount(server, user, password)
	{
        if(user.length)
            Maui.App.accounts.registerAccount({server: server, user: user, password: password})
	}
	
	function removeAccount(server, user)
	{
		if(server.length && user.length)
			Maui.App.accounts.removeAccount(server, user)
	}
	
	function removeAccountAndFiles(server, user)
	{
		if(server.length && user.length)
			Maui.App.accounts.removeAccountAndFiles(server, user)
	}
}
