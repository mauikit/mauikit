import QtQuick 2.13
import QtQml 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

/**
 * AltBrowser
 * A convinient way of switching from a grid to a list view.
 *
 * The AltBrowser makes use of the GridView and ListBrowser components,
 * there is a property to dinamically switch between the two.
 *
 * For some navigation patterns is a good idea to provide a grid view when the application screen size is wide enough
 * to fit much more information and a list view when the space is contrained since the list is much more compact,
 * and makes navigation much more quicker, for this
 * one could use the viewType property binded to a size condition.
 *
 */
Maui.Page
{
    id: control

    /**
      * currentView : Item
      * The current view being used, the GridView or the ListBrowser.
      * To access the precise view use the aliases for the GridView or ListView.
      */
    readonly property Item currentView : control.viewType === AltBrowser.ViewType.List ? _listView : _gridView

    /**
      * ViewType : enum
      * Grid = the GridView
      * List = the ListBrowser
      */
    enum ViewType
    {
        Grid,
        List
    }

    /**
      * viewType : AltBrowser.ViewType
      * Defines which view is going to be in use. The options  are defined in the Viewtype enumeration.
      */
    property int viewType: AltBrowser.ViewType.List

    /**
      * currentIndex : int
      * The index of the current item selected in either view type.
      * This value is synced to both view types.
      */
    property int currentIndex : -1
    Binding on currentIndex
    {
        when: control.currentView
        value: control.currentView.currentIndex
    }

    /**
      * listDelegate : Component
      * The delegate to be used by the ListBrowser.
      */
    property Component listDelegate : null

    /**
      * gridDelegate : Component
      * The delegate to be used by the GridView.
      */
    property Component gridDelegate : null

    /**
      * model : var
      * The shared data model to be used by both view types.
      */
    property var model : null

    /**
      * enableLassoSelection : bool
      * Allow the lasso selection for multiple items with mouse or track based input methods.
      */
    property bool enableLassoSelection: false

    /**
      * selectionMode : bool
      * Allow the selection mode, which sets the views in the mode to accept drag and hover to select multiple
      * items.
      */
    property bool selectionMode: false

    /**
      * holder : Holder
      * Item to set a place holder emoji and message.
      * For more details on its properties check the Holder component.
      *
      */
    property alias holder : _holder

    /**
      * gridView : GridView
      * The GridView used as the grid view alternative.
      */
    readonly property alias gridView : _gridView

    /**
      * listView : ListBrowser
      * The ListBrowser used as the list view alternative.
      */
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
