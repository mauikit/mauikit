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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui


ScrollView
{
    id: control    
    
    property int itemSize : iconSizes.big
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
	property alias header : _listView.header 
	property alias listView: _listView

    
    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)
    
    signal rightEmblemClicked(int index)
    signal leftEmblemClicked(int index)
    
    signal areaClicked(var mouse)
    signal areaRightClicked()   
	
	padding: 0
	spacing: 0
    
    ListView
    {
		anchors.fill: parent
		id: _listView
		//    maximumFlickVelocity: 400
		
		snapMode: ListView.SnapToItem
		boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
		
		keyNavigationEnabled: true
		clip: true
		focus: true
		interactive: true
		highlightFollowsCurrentItem: true
		highlightMoveDuration: 0
		
		width: parent.width
		height: parent.height      
    
        
        model: ListModel { id: listModel }
        delegate: Maui.IconDelegate
        {
            id: delegate
            isDetails: true
            width: parent.width
            height: itemSize + space.big
            
            showDetailsInfo: control.showDetailsInfo
            folderSize : itemSize
            showTooltip: true
            showEmblem: control.showEmblem
            keepEmblemOverlay : control.keepEmblemOverlay
            showThumbnails: showPreviewThumbnails
            rightEmblem: control.rightEmblem
            leftEmblem: control.leftEmblem
            opacity: (model.name).startsWith(".") ? 0.5 : 1
            
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
            onClicked: control.areaClicked(mouse)
            onPressAndHold: control.areaRightClicked()
        }
    }
}


