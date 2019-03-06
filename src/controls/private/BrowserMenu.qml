import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import FMList 1.0

Maui.Menu
{ 
    property int pasteFiles : 0

  

   /* Maui.MenuItem
    {
		che
		ckable: true
		checked: saveDirProps
		text: qsTr("Per dir props")
		onTriggered: saveDirProps = !saveDirProps
	}*/
	
 
    Maui.MenuItem
    {
        icon.name: "image-preview"
        text: qsTr("Previews")
		checkable: true
		checked: list.preview
        onTriggered:
        {
			list.preview = !list.preview
            close()
        }
    }

    Maui.MenuItem
    {
        icon.name: "visibility"

        text: qsTr("Hidden files")
		checkable: true
		checked: list.hidden
        onTriggered:
        {
			list.hidden = !list.hidden
            close()
        }
    }
    
    Maui.MenuItem
    {
        icon.name: "bookmark-new"
        text: qsTr("Bookmark")
        checkable: true
        checked: modelList.isBookmark 
        
		onTriggered: 
		{
    modelList.isBookmark = !modelList.isBookmark
    newBookmark()
    close()
		}
    }


    MenuSeparator { }

    Maui.MenuItem
    {
        icon.name: "folder-add"
        text: qsTr("New folder")
		onTriggered: 
		{
			dialogLoader.sourceComponent= newFolderDialogComponent
			dialog.open()
			close()
		}
    }

    Maui.MenuItem
    {
        icon.name: "document-new"
        text: qsTr("New file")
		onTriggered: 
		{
			dialogLoader.sourceComponent= newFileDialogComponent
			dialog.open()
			close()
		}
    }
    
    MenuSeparator { visible : pasteItem.enabled}
    
    Maui.MenuItem
    {
		id: pasteItem
        visible: enabled
        text: qsTr("Paste ")+"["+pasteFiles+"]"
        enabled: pasteFiles > 0
        onTriggered: paste()
    }
    
    
   /* Maui.MenuItem
    {
        width: parent.width

        RowLayout
        {
            anchors.fill: parent
            Maui.ToolButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                iconName: "list-add"
                onClicked: zoomIn()
            }

            Maui.ToolButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                iconName: "list-remove"
                onClicked: zoomOut()
            }
        }
    }*/

    function show()
    {
		if(currentPathType === FMList.PLACES_PATH || currentPathType === FMList.TAGS_PATH || currentPathType === FMList.CLOUD_PATH)
        {
            if(isCopy)
                pasteFiles = copyItems.length
            else if(isCut)
                pasteFiles = cutItems.length

            popup()
        }
    }
}
