import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

QtObject
{
	property Maui.FMList browser
	property bool visible: !browser.pathExists || browser.pathEmpty || !browser.contentReady
	property string emoji: 
	{
		if(browser.pathExists && browser.pathEmpty)
			"qrc:/assets/folder-add.svg" 
			else if(!browser.pathExists)
				"qrc:/assets/dialog-information.svg"
				else if(!browser.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
					"qrc:/assets/edit-find.svg"
					else if(!browser.contentReady)
						"qrc:/assets/view-refresh.svg"
	}
	
	property string title :
	{
		if(browser.pathExists && browser.pathEmpty)
			qsTr("Folder is empty!")
			else if(!browser.pathExists)
				qsTr("Folder doesn't exists!")
				else if(!browser.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
					qsTr("Searching for content!")
					else if(!browser.contentReady)
						qsTr("Loading content!")					
						
	}
	
	property string body:
	{
		if(browser.pathExists && browser.pathEmpty)
			qsTr("You can add new files to it")
			else if(!browser.pathExists)
				qsTr("Create Folder?")
				else if(!browser.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
					qsTr("This might take a while!")
					else if(!browser.contentReady)
						qsTr("Almost ready!")	
	}
	
	property int emojiSize: Maui.Style.iconSizes.huge
	
}
