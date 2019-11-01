import QtQml 2.1
import org.kde.mauikit 1.0 as Maui

QtObject 
{
    property var filters
    property int filterType 
    property bool onlyDirs: false
    property int sortBy
    property bool trackChanges
    property bool saveDirProps : false
    
    onFilterTypeChanged: setSettings()
    onFiltersChanged : setSettings()
    onOnlyDirsChanged: setSettings()
    onSortByChanged : setSettings()
    onTrackChangesChanged: setSettings()
    onSaveDirPropsChanged: setSettings()
}

