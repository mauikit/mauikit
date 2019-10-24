import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

Menu
{ 
	contentData: actions
	property list<Action> actions : [ 
    Action
    {
		icon.name: "image-preview"
		text: qsTr("Previews")
		checkable: true
		checked: control.showThumbnails
		onTriggered: control.showThumbnails = !control.showThumbnails
    },
    
	Action
    {
		icon.name: "visibility"
		text: qsTr("Hidden files")
		checkable: true
		checked: control.currentFMList.hidden
		onTriggered: control.currentFMList.hidden = !control.currentFMList.hidden
    },
    
    
	Action
    {
		icon.name: "bookmark-new"
		text: qsTr("Bookmark")
		onTriggered: control.bookmarkFolder([currentPath])
    },
    
	Action
    {
		icon.name: "folder-add"
		text: qsTr("New folder")
		onTriggered:
		{
			dialogLoader.sourceComponent= newFolderDialogComponent
			dialog.open()
		}
    },
    
	Action
    {
		icon.name: "document-new"
		text: qsTr("New file")
		onTriggered:
		{
			dialogLoader.sourceComponent= newFileDialogComponent
			dialog.open()
		}
    },
    
    
	Action
    {
		text: qsTr("Paste")
		icon.name: "edit-paste"
		// 		enabled: control.clipboardItems.length > 0
		onTriggered: paste()
    },
    
	Action
    {
		text: qsTr("Select all")
		icon.name: "edit-select-all"
		onTriggered: control.selectAll()
	},
	
	Action
	{
		text: qsTr("Status bar")
		icon.name: "settings-configure"
		checkable: true
		checked: control.footBar.visible
		onTriggered: control.footBar.visible = !control.footBar.visible
	}
	]
    
    
    function show()
    {
        if(currentPathType === Maui.FMList.PLACES_PATH || currentPathType === Maui.FMList.TAGS_PATH || currentPathType === Maui.FMList.CLOUD_PATH)
        {
                    popup()
        }
    }
}

