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

Kirigami.ScrollablePage
{
    id: control    
    
    property int itemSize : Maui.Style.iconSizes.big
    property bool checkable : false
    
    property bool showPreviewThumbnails: true
    
    property alias model : _listView.model
    property alias delegate : _listView.delegate
    property alias section : _listView.section
    property alias contentY: _listView.contentY
    property alias currentIndex : _listView.currentIndex
    property alias currentItem : _listView.currentItem
    property alias count : _listView.count
    property alias cacheBuffer : _listView.cacheBuffer
    property alias orientation: _listView.orientation
    
    property int margins : 0
    property alias topMargin: _listView.topMargin
    property alias bottomMargin: _listView.bottomMargin
    property alias rightMargin: _listView.rightMargin
    property alias leftMargin: _listView.leftMargin
    property alias listView: _listView
    property alias holder : _holder
    
    property bool enableLassoSelection : false  
    property alias lassoRec : selectLayer
    
    signal itemsSelected(var indexes) 
    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)
	signal itemToggled(int index, bool state)
    signal areaClicked(var mouse)
    signal areaRightClicked()   
    signal keyPress(var event)
    
    spacing: Maui.Style.space.tiny
    contentWidth: _listView.contentWidth
    
    focus: true	
    padding: 0
    leftPadding: padding
    rightPadding: padding
    topPadding: padding
    bottomPadding: padding

    Keys.enabled: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View       
    supportsRefreshing: false
    
    ListView
    {	
        id: _listView
        focus: true
        clip: control.clip           
        spacing: control.spacing
        snapMode: ListView.NoSnap
        boundsBehavior: !Kirigami.Settings.isMobile? Flickable.StopAtBounds : 
        Flickable.OvershootBounds
        
        interactive: Kirigami.Settings.hasTransientTouchInput
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        highlightResizeDuration : 0
        
        keyNavigationEnabled : true
        keyNavigationWraps : true
        Keys.onPressed: control.keyPress(event)
		
		topMargin: control.margins
		bottomMargin: control.margins
		leftMargin: control.margins
		rightMargin: control.margins
        
        Maui.Holder
        {
            id: _holder
            anchors.fill : parent		
        }	
        
        delegate: Maui.ListBrowserDelegate
        {
            id: delegate
            width: parent.width
            leftPadding: Maui.Style.space.small
            rightPadding: Maui.Style.space.small
            padding: 0
            iconSizeHint : height
            checkable: control.checkable
            showThumbnails: control.showPreviewThumbnails
            
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
                
                onToggled:
                {
					control.currentIndex = index
					control.itemToggled(index, state)
				}
            }
        }    
        
        MouseArea
        {
            id: _mouseArea
            z: -1
            anchors.fill: parent
            propagateComposedEvents: false
            preventStealing: true
            acceptedButtons:  Qt.RightButton | Qt.LeftButton
            
            
            onClicked:
            {
				control.areaClicked(mouse)
				control.forceActiveFocus()
				
				if(mouse.button === Qt.RightButton)
				{
					control.areaRightClicked()
					return
				}				
			}
			
            onPositionChanged: 
            {
				if(_mouseArea.pressed && control.enableLassoSelection && selectLayer.visible)
				{
                    if(mouseX >= selectLayer.newX)
                    {
                        selectLayer.width = (mouseX + 10) < (control.x + control.width) ? (mouseX - selectLayer.x) : selectLayer.width;
                    } else {
                        selectLayer.x = mouseX < control.x ? control.x : mouseX;
                        selectLayer.width = selectLayer.newX - selectLayer.x;
                    }
                    
                    if(mouseY >= selectLayer.newY) {
                        selectLayer.height = (mouseY + 10) < (control.y + control.height) ? (mouseY - selectLayer.y) : selectLayer.height;
                        if(!_listView.atYEnd &&  mouseY > (control.y + control.height))
                            _listView.contentY += 10
                    } else {
                        selectLayer.y = mouseY < control.y ? control.y : mouseY;
                        selectLayer.height = selectLayer.newY - selectLayer.y;
                        
                        if(!_listView.atYBeginning && selectLayer.y === 0)
                            _listView.contentY -= 10                                
                    }
                }               
            }                
            
            onPressed:
            {
				if (mouse.source !== Qt.MouseEventNotSynthesized) 
				{
					mouse.accepted = false
				}
				
				if(control.enableLassoSelection && mouse.button === Qt.LeftButton )
				{
					selectLayer.visible = true;
					selectLayer.x = mouseX;
					selectLayer.y = mouseY;
					selectLayer.newX = mouseX;
					selectLayer.newY = mouseY;
					selectLayer.width = 0
					selectLayer.height = 0;						
				} 				
			}
			            
            onReleased: 
            {                    
				if(mouse.button !== Qt.LeftButton || !control.enableLassoSelection || !selectLayer.visible)
				{
					mouse.accepted = false
					return;
				}
				
				if(selectLayer.y > _listView.contentHeight)
				{
					return selectLayer.reset();
				}
				
				var lassoIndexes = []
                var limitY =  mouse.y === lassoRec.y ?  lassoRec.y+lassoRec.height : mouse.y
                                
                for(var y = lassoRec.y; y < limitY; y+=10)
                {    
                    const index = _listView.indexAt(_listView.width/2,y+_listView.contentY)
                    if(!lassoIndexes.includes(index) && index>-1 && index< _listView.count)
                        lassoIndexes.push(index)
                }                    
                
                control.itemsSelected(lassoIndexes)
				selectLayer.reset()
            }            
        }
        
        Maui.Rectangle 
        {
            id: selectLayer
            property int newX: 0
            property int newY: 0
            height: 0
            width: 0
            x: 0
            y: 0
            visible: false
            color: Qt.rgba(control.Kirigami.Theme.highlightColor.r,control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2)
            opacity: 0.7
            
            borderColor: control.Kirigami.Theme.highlightColor
            borderWidth: 2
            solidBorder: false
            
            function reset()
			{
				selectLayer.x = 0;
				selectLayer.y = 0;
				selectLayer.newX = 0;
				selectLayer.newY = 0;
				selectLayer.visible = false;
				selectLayer.width = 0;
				selectLayer.height = 0;
			}
        }      
    }   
    
}


