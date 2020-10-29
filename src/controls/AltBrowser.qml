import QtQuick 2.13
import QtQml 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control    
    
    readonly property Item currentView : control.viewType === AltBrowser.ViewType.List ? _listView : _gridView
    
    enum ViewType 
    {
        Grid,
        List
    }
    
    property int viewType: AltBrowser.ViewType.List
    property int currentIndex : -1
    Binding on currentIndex
    {
        when: control.currentView
        value: control.currentView.currentIndex        
    }    
    
    property Component listDelegate : null
    property Component gridDelegate : null
    
    property var model : null
    
    property bool enableLassoSelection: false   
    property bool selectionMode: false
    property alias holder : _holder   
    
    readonly property alias gridView : _gridView
    readonly property alias listView : _listView    
    
    flickable: control.viewType === AltBrowser.ViewType.List ? _listView.flickable : _gridView.flickable   
    
    Maui.Holder
    {
        id: _holder
        anchors.fill: parent
    }
    
    Maui.GridView
    {
        id: _gridView
        anchors.fill: parent
        visible: control.viewType === AltBrowser.ViewType.Grid
        currentIndex: control.currentIndex
        model: control.model
        delegate: control.gridDelegate
        enableLassoSelection: control.enableLassoSelection
        selectionMode: control.selectionMode
        adaptContent: true
    }
    
    Maui.ListBrowser
    {
        anchors.fill: parent
        id: _listView
        visible: control.viewType === AltBrowser.ViewType.List
        currentIndex: control.currentIndex
        model: control.model
        delegate: control.listDelegate
        enableLassoSelection: control.enableLassoSelection
        selectionMode: control.selectionMode
    }
    
}
