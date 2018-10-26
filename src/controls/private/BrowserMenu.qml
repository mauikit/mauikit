import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import FMList 1.0

Maui.Menu
{ 
    property int pasteFiles : 0

    Maui.MenuItem
    {
		checkable: true
		checked: selectionMode
		text: qsTr("Selection mode")
        onTriggered: selectionMode = !selectionMode
    }

    MenuSeparator { }

  
    Maui.MenuItem
    {
        text: qsTr("Show previews")
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
        text: qsTr("Show hidden files")
		checkable: true
		checked: list.hidden
        onTriggered:
        {
			list.hidden = !list.hidden
            close()
        }
    }

    MenuSeparator { }

    Maui.MenuItem
    {
        text: qsTr("New folder")
		onTriggered: 
		{
			newFolderDialog.open()
			close()
		}
    }

    Maui.MenuItem
    {
        text: qsTr("New file")
		onTriggered: 
		{
			newFileDialog.open()
			close()
		}
    }

    Maui.MenuItem
    {
        text: qsTr("Bookmark")
		onTriggered: 
		{
			bookmarkFolder([currentPath])
			close()
		}
    }

    MenuSeparator { }
    
    Maui.MenuItem
    {
        text: qsTr("Paste ")+"["+pasteFiles+"]"
        enabled: pasteFiles > 0
        onTriggered: paste()
    }
    
    MenuSeparator { }
    
    Maui.MenuItem
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
    }

    function show()
    {
        if(currentPathType === FMList.PLACES_PATH
			|| currentPathType === FMList.TAGS_PATH)
        {
            if(isCopy)
                pasteFiles = copyPaths.length
            else if(isCut)
                pasteFiles = cutPaths.length

            popup()
        }
    }
}
