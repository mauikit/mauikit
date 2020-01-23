import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import "."

Item
{
	id: control	
	
	property var urls : []
	property string mimeType
	
	Loader
	{
		id: _shareDialogLoader
		active: !isAndroid
		source: "ShareDialogLinux.qml"
	}	
	
	function open()
	{		
		if(Maui.Handy.isAndroid)
		{
			Maui.Android.shareDialog(control.urls[0])
			return;
		}
		
		if(Maui.Handy.isLinux)
		{
			console.log(control.urls)
			_shareDialogLoader.item.urls = control.urls
			_shareDialogLoader.item.mimeType = control.mimeType ? control.mimeType : Maui.FM.getFileInfo(control.urls[0]).mime				
			_shareDialogLoader.item.open()
			return;
		}		
	}
	
	function close()
	{
		if(Maui.Handy.isLinux)			
			_shareDialogLoader.item.close()
	}
}
