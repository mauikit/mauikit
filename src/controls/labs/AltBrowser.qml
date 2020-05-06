import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control    
    
    readonly property alias currentView : viewLoader.item
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
    property alias holder : _holder   
    
    readonly property alias gridView : private_.gridView
    readonly property alias listView : private_.listView
    
//     readonly property var section : listView.section
    
    flickable: viewLoader.item ? viewLoader.item.flickable : null
    
    QtObject 
    {
        //before loading the view we use a dummy representation of the possible views, in order to store the properties data. Once the actual view has been loaded then the exposed properties are changed from the dummy representation to the actual view loaded, this allows to preserve and use the bindings for the actual view. The dummy representations are within a private object and exposed as readonly properties to avoid those being changed externally
        
        id: private_
        property Maui.GridView gridView : Maui.GridView
        {
            id: _dummyGridView
        }
        
        Binding on gridView
        {
            delayed: true
            value: control.viewType === AltBrowser.ViewType.Grid ? control.currentView : _dummyGridView 
        }        
        
        property Maui.ListBrowser listView :  Maui.ListBrowser
        {
            id: _dummyListBrowser
        } 
        
        Binding on listView
        {
            delayed: true
            value: control.viewType === AltBrowser.ViewType.List ? control.currentView : _dummyListBrowser 
        }        
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
        
//         onLoaded: 
//         {
//             if(control.currentView)
//             {
//                 switch(control.viewType)
//                 {
//                     case AltBrowser.ViewType.Grid: 
//                     {
//                         private_.gridView = control.currentView
//                         private_.listView = _dummyListBrowser
//                         
//                         break
//                     }
//                     case AltBrowser.ViewType.List: 
//                     {
//                         private_.listView = control.currentView
//                         private_.gridView = _dummyGridView                        
//                         break
//                     }
//                 }                
//             }
//         }
    }    
    
    Maui.Holder
    {
        id: _holder
        anchors.fill: parent
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
            topMargin: _dummyGridView.topMargin  
            adaptContent: true
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
            section.delegate: _dummyListBrowser.section.delegate
            section.property: _dummyListBrowser.section.property
            section.criteria: _dummyListBrowser.section.criteria
            section.labelPositioning: _dummyListBrowser.section.labelPositioning
            margins: _dummyListBrowser.margins
            spacing: _dummyListBrowser.spacing
            topMargin: _dummyListBrowser.topMargin            
        }
    }    
}
