/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

/**
 * SelectionBar
 *
 * A bar to group selected items with a list of actions to perform to the selection.
 * The list of actions is  positioned into a Kirigami ActionToolBar.
 * This control provides methods to append and query elements added to it. To add elements to it, it is necesary to map them,
 * so an item is mapped to an unique id refered here as an URI.
 */
Item
{
    id: control

    implicitHeight: barHeight + padding
    implicitWidth: _layout.implicitWidth + Maui.Style.space.big + (height * 2)

    visible: control.count > 0
    focus: true

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    /**
      * actions : list<Action>
      * Default list of actions, the actions are positioned into a Kirigami ActionToolBar.
      */
    default property list<Action> actions

    /**
      * hiddenActions : list<Action>
      * List of action that wont be shown, and instead will always hidden and listed in the overflow menu.
      */
    property list<Action> hiddenActions

    /**
      * padding : int
      *
      */
    property int padding : 0

    /**
      * barHeight : int
      * height of the selection bar withouh the padding.
      */
    property int barHeight: Maui.Style.toolBarHeightAlt

    /**
      * display : int
      * Preferred display mode of the visible actions. As icons only, or text beside icons... etc.
      */
    property int display : root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

    /**
      * maxListHeight : int
      * The selectionbar can list the grouped items under a collapsable list. This property defines the maximum height the list can take.
      * This can be changed to avoid overlapping the list with other components.
      */
    property int maxListHeight : 400

    /**
      * radius : int
      * By default the selectionbar was designed to be floating and thus has a rounded border corners.
      * This property allows to change the border radius.
      */
    property int radius: Maui.Style.radiusV

    /**
     * singleSelection : bool
     * if singleSelection is set to true then only a single item can be appended,
     * if another item is added then it replaces the previous one.
     **/
    property bool singleSelection: false

    /**
      * uris : var
      * List of URIs associated to the grouped elements.
      */
    readonly property alias uris: _private._uris

    /**
      * items : var
      * List of items grouped.
      */
    readonly property alias items: _private._items

    /**
      * selectionList : ListBrowser
      * The component where the grouped items are listed.
      */
    readonly property alias selectionList : selectionList

    /**
      * count : int
      * Size of the elements grouped.
      */
    readonly property alias count : selectionList.count

    /**
      * background : Rectangle
      * The default style of the background. This can be customized by changing its properties.
      */
    property alias background : bg

    /**
      * listDelegate : Component
      * Delegate to be used in the component where the grouped elements are listed.
      */
    property Component listDelegate: Maui.ItemDelegate
    {
        id: delegate
        height: Maui.Style.rowHeight * 1.5
        width: ListView.view.width

        Kirigami.Theme.backgroundColor: "transparent"
        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor

        onClicked: control.itemClicked(index)
        onPressAndHold: control.itemPressAndHold(index)

        Maui.ListItemTemplate
        {
            id: _template
            anchors.fill: parent
            iconVisible: false
            labelsVisible: true
            label1.text: model.uri

            checkable: true
            checked: true
            onToggled: control.removeAtIndex(index)
        }
    }

    /**
      * cleared :
      * Triggered when the selection is cleared by using the close button or calling the clear method.
      */
    signal cleared()

    /**
      * exitClicked :
      * Triggered when the selection bar is closed by using the close button or the close method.
      */
    signal exitClicked()

    /**
      * itemClicked :
      * Triggered when an item in the selection list view is clicked.
      */
    signal itemClicked(int index)

    /**
      * itemPressAndHold :
      * Triggered when an item in the selection list view is pressed and hold.
      */
    signal itemPressAndHold(int index)

    /**
      * itemAdded :
      * Triggered when an item newly added to the selection.
      */
    signal itemAdded(var item)

    /**
      * itemRemoved :
      * Triggered when an item has been removed from the selection.
      */
    signal itemRemoved(var item)

    /**
      * uriAdded :
      * Triggered when an item newly added to the selection. This signal only sends the refered URI of the item.
      */
    signal uriAdded(string uri)

    /** uriRemoved:
      * Triggered when an item has been removed from the selection. This signal only sends the refered URI of the item.
      */
    signal uriRemoved(string uri)

    /**
      * clicked :
      * Triggered when an empty area of the selectionbar has been clicked.
      */
    signal clicked(var mouse)

    /**
      * rightClicked :
      * Triggered when an empty area of the selectionbar has been right clicked.
      */
    signal rightClicked(var mouse)

    /**
      * urisDropped :
      * Triggered when a group of URIs has been dropped.
      */
    signal urisDropped(var uris)

    property QtObject m_private : QtObject
    {
        id: _private
        property var _uris : []
        property var _items : []
    }

    Item
    {
        id: _container
        anchors.centerIn: parent
        implicitHeight: control.barHeight
        width: parent.width

        Rectangle
        {
            id: _listContainer
            property bool showList : false
            height: showList ? Math.min(Math.min(400, control.maxListHeight), selectionList.contentHeight) + control.barHeight + Maui.Style.space.big : 0
            width: parent.width
            color: Qt.lighter(Kirigami.Theme.backgroundColor)
            border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
            radius:  control.radius
            focus: true
            y: ((height) * -1) + parent.implicitHeight
            x: parent.x

            opacity: showList ? 1 : .97

            Behavior on height
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }


            Maui.ListBrowser
            {
                anchors.fill: parent
                anchors.topMargin: Maui.Style.space.medium
                anchors.bottomMargin: _container.height
                id: selectionList
                visible: _listContainer.height > 10
                spacing: Maui.Style.space.small
                model: ListModel{}

                delegate: control.listDelegate
            }
        }

        DropShadow
        {
            id: rectShadow
            anchors.fill: _listContainer
            cached: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 16
            color: "#333"
            smooth: true
            source: _listContainer
        }


        Rectangle
        {
            id: bg
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            radius: control.radius
            border.color: Qt.darker(Kirigami.Theme.backgroundColor, 2.2)


            MouseArea
            {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.LeftButton

                onClicked:
                {
                    if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                        control.rightClicked(mouse)
                        else
                            control.clicked(mouse)
                }

                onPressAndHold :
                {
                    if(Kirigami.Settings.isMobile)
                        control.rightClicked(mouse)
                }
            }
        }

        RowLayout
        {
            id: _rowLayout
            anchors.fill: parent
            clip: true
            spacing: 0

            Maui.Badge
            {
                Kirigami.Theme.colorSet: control.Kirigami.Theme.colorSet
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.margins: Maui.Style.space.tiny
                radius: Maui.Style.radiusV
                onClicked: control.exitClicked()
                Kirigami.Theme.backgroundColor: Qt.darker(bg.color)
                border.color: "transparent"

                Maui.X
                {
                    height: Maui.Style.iconSizes.medium - 10
                    width: height
                    anchors.centerIn: parent
                    color: parent.hovered ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                }
            }

            Kirigami.ActionToolBar
            {
                id: _layout
                clip: true
                position: ToolBar.Footer
//                spacing: Maui.Style.space.medium
                Layout.fillWidth: true
                Layout.fillHeight: true
                actions: control.actions
                hiddenActions: control.hiddenActions

                display: control.display
                alignment: Qt.AlignHCenter
            }

            Maui.Badge
            {
                id: _counter
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.margins: Maui.Style.space.tiny
                text: selectionList.count
                radius: Maui.Style.radiusV

                Kirigami.Theme.backgroundColor: _listContainer.showList ?
                Kirigami.Theme.highlightColor : Qt.darker(bg.color)
                border.color: "transparent"

                onClicked:
                {
                    _listContainer.showList = !_listContainer.showList
                }

                Component.onCompleted:
                {
                    _counter.item.font.pointSize= Maui.Style.fontSizes.big

                }

                SequentialAnimation
                {
                    id: anim

                    PropertyAnimation
                    {
                        target: _counter
                        property: "radius"
                        easing.type: Easing.InOutQuad
                        from: target.height
                        to: Maui.Style.radiusV
                        duration: 200
                    }
                }

                Maui.Rectangle
                {
                    opacity: 0.3
                    anchors.fill: parent
                    anchors.margins: 4
                    visible: _counter.hovered
                    color: "transparent"
                    borderColor: "white"
                    solidBorder: false
                }

                MouseArea
                {
                    id: _mouseArea
                    anchors.fill: parent
                    propagateComposedEvents: true
                    property int startX
                    property int startY
                    Drag.active: drag.active
                    Drag.hotSpot.x: 0
                    Drag.hotSpot.y: 0
                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.CopyAction
                    Drag.keys: ["text/plain","text/uri-list"]

                    onPressed:
                    {
                        if( mouse.source !== Qt.MouseEventSynthesizedByQt)
                        {
                            drag.target = _counter
                            _counter.grabToImage(function(result)
                            {
                                _mouseArea.Drag.imageSource = result.url
                            })

                            _mouseArea.Drag.mimeData = { "text/uri-list": control.uris.join("\n")}

                            startX = _counter.x
                            startY = _counter.y

                        }else mouse.accepted = false
                    }

                    onReleased :
                    {
                        _counter.x = startX
                        _counter.y = startY
                    }
                }
            }

        }

        Maui.Rectangle
        {
            opacity: 0.2
            anchors.fill: parent
            anchors.margins: 4
            visible: _dropArea.containsDrag
            color: "transparent"
            borderColor: "white"
            solidBorder: false
        }

         Rectangle
        {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            radius: bg.radius - 0.5
            border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
            opacity: 0.4
        }
    }

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            control.urisDropped(drop.urls)
        }
    }

    Keys.onEscapePressed:
    {
        control.exitClicked();
    }

    Keys.onBackPressed:
    {
        control.exitClicked();
        event.accepted = true
    }

    /**
      * Removes all the items from the selection.
      */
    function clear()
    {
        _private._uris = []
        _private._items = []
        _listContainer.showList = false
        selectionList.model.clear()
        control.cleared()
    }

    /**
      * Returns an item at a given index
      */
    function itemAt(index)
    {
        if(index < 0 ||  index > selectionList.count)
            return
            return selectionList.model.get(index)
    }

    /**
      * Remove a single item at a given index
      */
    function removeAtIndex(index)
    {
        if(index < 0)
            return

            const item = selectionList.model.get(index)
            const uri = item.uri

            if(contains(uri))
            {
                _private._uris.splice(index, 1)
                _private._items.splice(index, 1)
                selectionList.model.remove(index)
                control.itemRemoved(item)
                control.uriRemoved(uri)
            }
    }

    /**
      * Removes an item from thge selection at a given URI
      */
    function removeAtUri(uri)
    {
        removeAtIndex(indexOf(uri))
    }

    /**
      *  Return the index of an item in the selection given its URI
      */
    function indexOf(uri)
    {
        return _private._uris.indexOf(uri)
    }

    /**
      * Append a new item to the selection associated to the given URI
      */
    function append(uri, item)
    {
        const index  = _private._uris.indexOf(uri)
        if(index < 0)
        {
            if(control.singleSelection)
                clear()

                _private._items.push(item)
                _private._uris.push(uri)

                item.uri = uri
                selectionList.model.append(item)
                selectionList.flickable.positionViewAtEnd()
                selectionList.currentIndex = selectionList.count - 1

                control.itemAdded(item)
                control.uriAdded(uri)

        }else
        {
            selectionList.currentIndex = index
            //             notify(item.icon, i18n("Item already selected!"), String("The item '%1' is already in the selection box").arg(item.label), null, 4000)
        }

        animate()
    }

    /**
      * Animates the control to cath the attention.
      */
    function animate()
    {
        anim.running = true
    }

    /**
      * Returns a single string with all the URIs separated by a comma.
      */
    function getSelectedUrisString()
    {
        return String(""+_private._uris.join(","))
    }

    /**
      * Returns true if the selection contains an item associated to a given URI.
      */
    function contains(uri)
    {
        return _private._uris.includes(uri)
    }
}
