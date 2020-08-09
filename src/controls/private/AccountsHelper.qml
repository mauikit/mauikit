import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.Dialog
{	
	id: control
	
	maxHeight: 350* Maui.Style.unit
	maxWidth: maxHeight
	page.margins: Maui.Style.contentMargins
	page.title: i18n("Accounts")
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
	acceptButton.text: i18n("Add account...") 
	onAccepted: _syncDialog.open()		

    footBar.leftContent: ToolButton
    {
        icon.name: "documentinfo"
        onClicked: Qt.openUrlExternally("https://mauikit.org/cloud")
    }

	Maui.BaseModel
	{
		id: _syncingModel
		list: Maui.App.accounts
	}
	
	Maui.Dialog
	{
		id: _removeDialog
		
		maxWidth: Maui.Style.unit * 400
		title: i18n("Remove Account")
		message: i18n("Are you sure you want to remove this account?")
		page.margins: control.page.margins
		
		rejectButton.text: i18n("Delete Account")
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
			text: i18n("Delete Account and Files")			
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
			text: i18n("Remove...")
			Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
			
			onTriggered: _removeDialog.open()
		}		
	}
	
	ListView
	{
		id: _listView
		Layout.fillHeight: true
		Layout.fillWidth: true
		model: _syncingModel
		delegate: Maui.ListDelegate 
		{
			id: delegate
			label: model.label
			label2: model.server
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
			isMask: true
			isGif: false
            emojiSize: Maui.Style.iconSizes.huge
            emoji: "qrc:/assets/dialog-information.svg"
            title: i18n("No accounts yet!")
			body: i18n("Start adding new accounts to sync your files, music, contacts, images, notes, etc...")
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
