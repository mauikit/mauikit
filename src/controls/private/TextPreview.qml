import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Editor
{
	id: control
	anchors.fill: parent	
	property url path : currentUrl
	onPathChanged: document.load(path) 
	
	body.readOnly: true
	Kirigami.Theme.backgroundColor: "transparent"
	
	Connections
	{
		target: control.document
		
		onLoaded:
		{
			infoModel.insert(0, {key:"Length", value: control.body.length.toString()})
			infoModel.insert(0, {key:"Line count", value: control.body.lineCount.toString()})
		}
	}
}
