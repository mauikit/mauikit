import QtQuick 2.13
import QtQml 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

/**
 * AltBrowser
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.Page
{
    id: control

    /**
      * currentView : Item
      */
    readonly property Item currentView : control.viewType === AltBrowser.ViewType.List ? _listView : _gridView

    /**
      * ViewType : enum
      */
    enum ViewType
    {
        Grid,
        List
    }

    /**
      * viewType : AltBrowser.ViewType
      */
    property int viewType: AltBrowser.ViewType.List

    /**
      * currentIndex : int
      */
    property int currentIndex : -1
    Binding on currentIndex
    {
        when: control.currentView
        value: control.currentView.currentIndex
    }

    /**
      * listDelegate : Component
      */
    property Component listDelegate : null

    /**
      * gridDelegate : Component
      */
    property Component gridDelegate : null

    /**
      * model : var
      */
    property var model : null

    /**
      * enableLassoSelection : bool
      */
    property bool enableLassoSelection: false

    /**
      * selectionMode : bool
      */
    property bool selectionMode: false

    /**
      * holder : Holder
      */
    property alias holder : _holder

    /**
      * gridView : GridView
      */
    readonly property alias gridView : _gridView

    /**
      * listView : ListBrowser
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
