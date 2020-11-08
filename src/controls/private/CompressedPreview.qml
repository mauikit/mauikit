import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
	id: control
	anchors.fill: parent
	
	footBar.rightContent: Button
	{
        text: i18n("Extract")
    }
    
    footBar.leftContent: Button
	{
        text: i18n("Add")
    }
	
	Maui.ListBrowser
	{
        id: _listView
        anchors.fill: parent
        model:  Maui.FM.getEntries(currentUrl)
        margins: Maui.Style.space.medium
        
        delegate: Maui.ItemDelegate
        {            
            height: Maui.Style.rowHeight* 1.5
            width: ListView.view.width
            
            Maui.ListItemTemplate
            {
                anchors.fill: parent
                iconSource: modelData.icon
                iconSizeHint: Maui.Style.iconSizes.medium
                label1.text: modelData.label
                label2.text: modelData.date
            }
        }
	}
}
