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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami


ScrollView
{
    id: control    
    
    property int itemSize : Maui.Style.iconSizes.big
    property bool showEmblem : true
    property bool keepEmblemOverlay : false
    property string rightEmblem
    property string leftEmblem
    
    property bool showDetailsInfo : false
    property bool showPreviewThumbnails: true
    
    property alias model : _listView.model
    property alias delegate : _listView.delegate
    property alias section : _listView.section
    property alias contentY: _listView.contentY
    property alias currentIndex : _listView.currentIndex
    property alias currentItem : _listView.currentItem
    property alias count : _listView.count
    property alias cacheBuffer : _listView.cacheBuffer
    
    property alias topMargin: _listView.topMargin
    property alias bottomMargin: _listView.bottomMargin
    property alias rightMargin: _listView.rightMargin
    property alias leftMarging: _listView.leftMargin
    property alias listView: _listView
    property alias holder : _holder
    
    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)
    
    signal rightEmblemClicked(int index)
    signal leftEmblemClicked(int index)
    
    signal areaClicked(var mouse)
    signal areaRightClicked()   
    signal keyPress(var event)
    
    spacing: 0
    focus: true	
    padding: 0
    leftPadding: padding
    rightPadding: padding
    topPadding: padding
    bottomPadding: padding    
    
    Keys.enabled: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View       
//     supportsRefreshing: false 
    
    ListView
    {	
        id: _listView
        focus: true
        clip: true           
        spacing: Maui.Style.space.tiny
        snapMode: ListView.NoSnap
        boundsBehavior: !Kirigami.Settings.isMobile? Flickable.StopAtBounds : 
        Flickable.OvershootBounds
        
        interactive: true
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        highlightResizeDuration : 0
        
        keyNavigationEnabled : true
        keyNavigationWraps : true
        Keys.onPressed: control.keyPress(event)
// 		ScrollBar.vertical: ScrollBar { }
		
        Maui.Holder
        {
            id: _holder
            anchors.fill : parent		
        }	
        
        delegate: Maui.ListBrowserDelegate
        {
            id: delegate
            width: parent.width
            height: itemSize + Maui.Style.space.big
            leftPadding: Maui.Style.space.small
            rightPadding: Maui.Style.space.small
            padding: 0
            showDetailsInfo: control.showDetailsInfo
            folderSize : itemSize
            showTooltip: true
            showEmblem: control.showEmblem
            keepEmblemOverlay : control.keepEmblemOverlay
            showThumbnails: showPreviewThumbnails
            rightEmblem: control.rightEmblem
            leftEmblem: control.leftEmblem
            
            Connections
            {
                target: delegate
                onClicked:
                {
                    control.currentIndex = index
                    control.itemClicked(index)
                }
                
                onDoubleClicked:
                {
                    control.currentIndex = index
                    control.itemDoubleClicked(index)
                }
                
                onPressAndHold:
                {
                    control.currentIndex = index
                    control.itemRightClicked(index)
                }
                
                onRightClicked:
                {
                    control.currentIndex = index
                    control.itemRightClicked(index)
                }
                
                onRightEmblemClicked:
                {
                    control.currentIndex = index
                    control.rightEmblemClicked(index)
                }
                
                onLeftEmblemClicked:
                {
                    control.currentIndex = index
                    control.leftEmblemClicked(index)
                }
            }
        }
        
        MouseArea
        {
            anchors.fill: parent
            z: -1
            acceptedButtons:  Qt.RightButton | Qt.LeftButton
            onClicked: 
            {
                control.forceActiveFocus()				
                control.areaClicked(mouse)
            }
            onPressAndHold: control.areaRightClicked()
        }
    }  
}


