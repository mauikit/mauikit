pragma Singleton
import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

Menu
{ 
    property int pasteFiles : 0
    
    //   popup.z : 999
    
    /* Maui.MenuItem
     *        {
     *            che
     *            ckable: true
     *            checked: saveDirProps
     *            text: qsTr("Per dir props")
     *            onTriggered: saveDirProps = !saveDirProps
}*/
    // 		property list<QtObject> actions: t_actions
    
    MenuItem
    {
        action: _previewAction
    }
    
    MenuItem
    {
        action: _hiddenAction
    }
    
    MenuItem
    {
        action: _bookmarkAction
    }
    
    MenuItem
    {
        action: _newFolderAction
    }
    
    MenuItem
    {
        action: _newDocumentAction
    }
    
    
    MenuItem
    {
        action: _pasteAction
    }
    
    
    function show()
    {
        if(currentPathType === Maui.FMList.PLACES_PATH || currentPathType === Maui.FMList.TAGS_PATH || currentPathType === Maui.FMList.CLOUD_PATH)
        {
            if(isCopy)
                pasteFiles = copyItems.length
                else if(isCut)
                    pasteFiles = cutItems.length
                    
                    popup()
        }
    }
}

