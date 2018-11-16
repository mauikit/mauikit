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
		
	footBar.rightContent: Maui.Button
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
			}
		}
		
		Maui.Holder
		{
			visible: _listView.count == 0
			emoji: "qrc:/assets/ElectricPlug.png" 
			isMask: false
			isGif: false
			emojiSize: iconSizes.huge
			title: qsTr("No accounts yet!")
			body: qsTr("Start adding new accounts to sync your files, music, contacts, images, notes, etc...")
		}
	}
	
	function addAccount(server, user, password)
	{
		if(server.length && user.length && password.length)
			_syncingList.insert({server: server, user: user, password: password})
	}
}
