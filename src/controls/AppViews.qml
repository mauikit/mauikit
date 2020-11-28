/*
 *   Copyright 2020 Camilo Higuita <milo.h@aol.com>
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
import QtQml 2.14
import QtQuick.Controls 2.14
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.9 as Kirigami

import "private" as Private

/**
 * AppViews
 * Lists the different views declared into a swipe view, that does not jump around
 * when resizing the application window and that takes care of different gestures for switching the views.
 *
 * This component takes care of creating the app views port as buttons in the application main header
 * for switching the views.
 *
 * By default this component is not interactive when using touch gesture, to not steal fcous from other horizontal
 * flickable gestures.
 *
 *
 */
SwipeView
{
    id: control
//     interactive: Kirigami.Settings.hasTransientTouchInput
    interactive: false
    clip: true
    focus: true

    /**
      * maxViews : int
      * Maximum number of views to be shown in the app view port in the header.
      * The rest of views buttons will be collapsed into a menu button.
      */
    property int maxViews : 4

    /**
      * toolbar : ToolBar
      * The toolbar where the app view buttons will be added.
      */
    property Maui.ToolBar toolbar : window().headBar

    /**
      * actionGroup : ActionGroup
      * Access to the view port component where the app view buttons is added.
      */
    property QtObject actionGroup : Private.ActionGroup
    {
        id: _actionGroup
        currentIndex : control.currentIndex
        strech: false
        onCurrentIndexChanged:
        {
            control.currentIndex = currentIndex
            _actionGroup.currentIndex = control.currentIndex
        }

        Component.onCompleted:
        {
            control.toolbar.middleContent.push(_actionGroup)
        }
    }

    currentIndex: _actionGroup.currentIndex
    onCurrentIndexChanged:
    {
        _actionGroup.currentIndex = currentIndex
        control.currentIndex = _actionGroup.currentIndex
    }

    onCurrentItemChanged:
    {
        currentItem.forceActiveFocus()
        _listView.positionViewAtIndex(control.currentIndex , ListView.SnapPosition)
        history.push(control.currentIndex)
    }

    Keys.onBackPressed:
    {
        control.goBack()
    }

    Shortcut
    {
        sequence: StandardKey.Back
        onActivated: control.goBack()
    }

    contentItem: ListView
    {
        id: _listView
        model: control.contentModel
        interactive: control.interactive
        currentIndex: control.currentIndex
        spacing: control.spacing
        orientation: control.orientation
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds

        preferredHighlightBegin: 0
        preferredHighlightEnd: width

        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 0
        highlightFollowsCurrentItem: true
        highlightResizeDuration: 0
        highlightMoveVelocity: -1
        highlightResizeVelocity: -1

        maximumFlickVelocity: 4 * (control.orientation === Qt.Horizontal ? width : height)

        property int lastPos: 0

        onCurrentIndexChanged:
        {
            _listView.lastPos = _listView.contentX
        }

//        Binding on contentX
//        {
//            when: overviewHandler.active
//            delayed: true
//            value: _listView.lastPos + ((overviewHandler.centroid.position.x - overviewHandler.centroid.pressPosition.x) * -1)
//            restoreMode: Binding.RestoreBinding
//        }

        //Item
        //{
            //enabled: Maui.Handy.isTouch
            //parent: window().pageContent
            //z: parent.z + 999
            //anchors.bottom: parent.bottom
            //height: 32
            //anchors.left: parent.left
            //anchors.right: parent.right

            //DragHandler
            //{
                //id: overviewHandler
                //target: null
                //onActiveChanged:
                //{
                    //if(!active)
                    //{
                        //_listView.contentX += (overviewHandler.centroid.position.x - overviewHandler.centroid.pressPosition.x) * -1
                        //_listView.returnToBounds()
                        //_listView.currentIndex = _listView.indexAt(_listView.contentX, 0)
                    //}
                //}
            //}
        //}

    }

    Keys.enabled: true
    Keys.onPressed:
    {
        if((event.key == Qt.Key_1) && (event.modifiers & Qt.ControlModifier))
        {
            if(control.count > -1 )
            {
                control.currentIndex = 0
            }
        }

        if((event.key == Qt.Key_2) && (event.modifiers & Qt.ControlModifier))
        {
            if(control.count > 0 )
            {
                control.currentIndex = 1
            }
        }

        if((event.key == Qt.Key_3) && (event.modifiers & Qt.ControlModifier))
        {
            if(control.count > 1 )
            {
                control.currentIndex = 2
            }
        }

        if((event.key == Qt.Key_4) && (event.modifiers & Qt.ControlModifier))
        {
            if(control.count > 2 )
            {
                control.currentIndex = 3
            }
        }
    }

    Component.onCompleted:
    {
        for(var i in control.contentChildren)
        {
            const obj = control.contentChildren[i]

            if(obj.Maui.AppView.title || obj.Maui.AppView.iconName)
            {
                if(control.actionGroup.items.length < control.maxViews)
                {
                    control.actionGroup.items.push(obj)
                }else
                {
                    control.actionGroup.hiddenItems.push(obj)
                }
            }
        }
    }

    property QtObject history : QtObject
    {
        property var historyIndexes : []

        function pop()
        {
            historyIndexes.pop()
            return historyIndexes.pop()
        }

        function push(index)
        {
            historyIndexes.push(index)
        }

        function indexes()
        {
            return historyIndexes
        }
    }

    /**
      *
      */
    function goBack()
    {
        control.setCurrentIndex(history.pop())
    }
}
