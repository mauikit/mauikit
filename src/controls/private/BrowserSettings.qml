import QtQml 2.1
import org.kde.mauikit 1.0 as Maui

QtObject 
{
    property var filters : []
    property int filterType : Maui.FMList.NONE  
    property bool onlyDirs: false
    property int sortBy: Maui.FMList.MODIFIED
    property var trackChanges
    property var saveDirProps
    
    onFilterTypeChanged: setSettings()
    onFiltersChanged : setSettings()
    onOnlyDirsChanged: setSettings()
    onSortByChanged : setSettings()
    onTrackChangesChanged: setSettings()
    onSaveDirPropsChanged: setSettings()
}

