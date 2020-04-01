import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control    
    
    property alias currentView : viewLoader.item
    enum ViewType 
    {
        Grid,
        List
    }
    
    property int viewType: AltBrowser.ViewType.List
    property int currentIndex : -1
    
    property Component listDelegate : null
    property Component gridDelegate : null
    property var model : null
    
    property bool enableLassoSelection: false    
    property alias holder : _holder
   
    
    property Maui.GridView gridView : Maui.GridView
    {
        id: _dummyGridView
    }
    
    property Maui.ListBrowser listView : Maui.ListBrowser
    {
        id: _dummyListBrowser
    }    
       
    Loader
    {
        id: viewLoader
        anchors.fill: parent
        focus: true
        sourceComponent: switch(control.viewType)
        {
            case AltBrowser.ViewType.Grid: return gridViewComponent
            case AltBrowser.ViewType.List: return listViewComponent
        }
    }
    
    
    Maui.Holder
    {
        id: _holder
    }
    
    Component
    {
        id: gridViewComponent
        
        Maui.GridView
        {
            currentIndex: control.currentIndex
            model: control.model
            delegate: control.gridDelegate
            enableLassoSelection: control.enableLassoSelection
            cellHeight: _dummyGridView.cellHeight
            cellWidth: _dummyGridView.cellWidth
            itemSize: _dummyGridView.itemSize  
            margins: _dummyGridView.margins
            topPadding: _dummyGridView.topPadding            
        }
    }
    
    Component
    {
        id: listViewComponent
        
        Maui.ListBrowser
        {
            currentIndex: control.currentIndex
            model: control.model
            delegate: control.listDelegate
            enableLassoSelection: control.enableLassoSelection
            
            itemSize: _dummyListBrowser.itemSize
//             section: _dummyListBrowser.section
            margins: _dummyListBrowser.margins
            spacing: _dummyListBrowser.spacing
            topPadding: _dummyListBrowser.topPadding            
        }
    }    
}
