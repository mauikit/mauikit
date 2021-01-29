import QtQuick 2.13
import QtQml 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

/*!
\since org.kde.mauikit 1.0
\inqmlmodule org.kde.mauikit
\brief A convinient way of switching from a grid to a list view.

The AltBrowser makes use of the GridView and ListBrowser components,
there is a property to dinamically switch between the two.

For some navigation patterns is a good idea to provide a grid view when the application screen size is wide enough
to fit much more information and a list view when the space is contrained since the list is much more compact,
and makes navigation much more quicker, for this
one could use the viewType property binded to a size condition.
*/
Maui.Page
{
    id: control

    /*!
      The current view being used, the GridView or the ListBrowser.
      To access the precise view use the aliases for the GridView or ListView.
    */
    readonly property Item currentView : control.viewType === AltBrowser.ViewType.List ? _listView : _gridView

    enum ViewType
    {
        Grid,
        List
    }

    /**
      \qmlproperty viewType AltBrowser::ViewType

      Sets the view that's going to be in use.

      The weight can be one of:
      \value ViewType.Grid
      \value ViewType.List      The default

      */
    property int viewType: AltBrowser.ViewType.List

    /*!
      The index of the current item selected in either view type.
      This value is synced to both view types.
    */
    property int currentIndex : -1
    Binding on currentIndex
    {
        when: control.currentView
        value: control.currentView.currentIndex
    }

    /*!
      The delegate to be used by the ListBrowser.
    */
    property Component listDelegate : null

    /*!
      The delegate to be used by the GridView.
    */
    property Component gridDelegate : null

    /*!
      The shared data model to be used by both view types.
    */
    property var model : null

    /*!
      Allow the lasso selection for multiple items with mouse or track based input methods.
    */
    property bool enableLassoSelection: false

    /*!
      Allow the selection mode, which sets the views in the mode to accept drag and hover to select multiple items.
    */
    property bool selectionMode: false

    /*!
      \qmlproperty Holder AltBrowser::holder

      Item to set a place holder emoji and message.
      For more details on its properties check the Holder component.
    */
    property alias holder : _holder

    /*!
      \qmlproperty GridView AltBrowser::gridView

      The GridView used as the grid view alternative.
    */
    readonly property alias gridView : _gridView

    /*!
      \qmlproperty ListBrowser AltBrowser::listView

      The ListBrowser used as the list view alternative.
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
