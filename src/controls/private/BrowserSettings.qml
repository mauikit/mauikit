import QtQml 2.1
import org.kde.mauikit 1.0 as Maui

QtObject 
{
    property var filters : []
    property int filterType : Maui.FMList.NONE
    property bool onlyDirs : false
    property int sortBy : Maui.FM.loadSettings("SortBy", "SETTINGS", Maui.FMList.LABEL)
    property bool trackChanges : false
    property bool saveDirProps : false
}

