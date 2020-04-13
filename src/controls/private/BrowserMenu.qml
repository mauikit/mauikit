import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

Menu
{ 	
    id: control
    MenuItem
    {
		icon.name: "bookmark-new"
		text: qsTr("Bookmark")
		onTriggered: bookmarkFolder([currentPath])
//         enabled: _optionsButton.enabled
    }
    
    MenuItem
    {
		icon.name: "folder-add"
		text: qsTr("New folder")
//         enabled: _optionsButton.enabled

		onTriggered:
		{
			dialogLoader.sourceComponent= newFolderDialogComponent
			dialog.open()
		}
    }
    
    MenuItem
    {
		icon.name: "document-new"
		text: qsTr("New file")
//         enabled: _optionsButton.enabled

		onTriggered:
		{
			dialogLoader.sourceComponent= newFileDialogComponent
			dialog.open()
		}
    }

    MenuSeparator {}
    
    MenuItem
    {
		text: qsTr("Paste")
//         enabled: _optionsButton.enabled

		icon.name: "edit-paste"
		// 		enabled: control.clipboardItems.length > 0
		onTriggered: paste()
    }

    MenuSeparator {}
    
    MenuItem
    {
		text: qsTr("Select all")
		icon.name: "edit-select-all"
		onTriggered: selectAll()
    }
    
    function show(parent = control, x, y)
    {       
            popup(parent, x, y)        
    }
}

