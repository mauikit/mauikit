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

import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import "../private" as Private

SwipeView
{
    id: control
    interactive: Maui.Handy.isTouch
    clip: true
    focus: true
    
    property int maxViews : 4
    property Maui.ToolBar toolbar : window().headBar
    
    readonly property int index : -1
    
    readonly property QtObject actionGroup : Private.ActionGroup
    {
        id: _actionGroup	
        currentIndex : control.currentIndex
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
        
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: 0
        highlightMoveDuration: 0
        highlightFollowsCurrentItem: true
        highlightResizeDuration: 0		
        
        preferredHighlightEnd: width
        // 		highlight: Item {}
        highlightMoveVelocity: -1
        highlightResizeVelocity: -1
        
        maximumFlickVelocity: 4 * (control.orientation === Qt.Horizontal ? width : height)	
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
            
            if(obj.MauiLab.AppView.title || obj.MauiLab.AppView.iconName)
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
    
    readonly property QtObject history : QtObject
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
    
    function goBack()
    {
        console.log("TRYING TO GO BACK", history.indexes())
        control.setCurrentIndex(history.pop())
    }
}
