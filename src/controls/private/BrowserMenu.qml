import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

Menu
{ 
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
                    popup()
        }
    }
}

