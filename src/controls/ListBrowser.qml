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
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.9 as Kirigami

Item
{
    id: control

    implicitHeight: contentHeight + margins*2
    implicitWidth: contentWidth + margins*2

    property int itemSize : Maui.Style.iconSizes.big
    property bool checkable : false

    property alias model : _listView.model
    property alias delegate : _listView.delegate
    property alias section : _listView.section
    property alias contentY: _listView.contentY
    property alias currentIndex : _listView.currentIndex
    property alias currentItem : _listView.currentItem
    property alias count : _listView.count
    property alias cacheBuffer : _listView.cacheBuffer
    property alias orientation: _listView.orientation
    property alias snapMode: _listView.snapMode
    property alias spacing: _listView.spacing
    property alias flickable : _listView
    property alias scrollView : _scrollView

    property alias contentHeight : _listView.contentHeight
    property alias contentWidth : _listView.contentWidth

    property int margins : control.enableLassoSelection ?  Maui.Style.space.medium : Maui.Style.space.small

    property int topMargin: margins
    property int bottomMargin: margins
    property int rightMargin: margins
    property int leftMargin: margins

    property int verticalScrollBarPolicy: ScrollBar.AsNeeded
    property int horizontalScrollBarPolicy:  _listView.orientation === Qt.Horizontal ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

    property alias holder : _holder

    property bool enableLassoSelection : false
    property bool selectionMode: false
    property alias lassoRec : selectLayer

    signal itemsSelected(var indexes)
    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)
    signal itemToggled(int index, bool state)
    signal areaClicked(var mouse)
    signal areaRightClicked()
    signal keyPress(var event)

    Kirigami.Theme.colorSet: Kirigami.Theme.View

    Keys.enabled : true
    Keys.forwardTo : _listView

    ScrollView
    {
        id: _scrollView
        anchors.fill: parent
        ScrollBar.horizontal.policy: control.horizontalScrollBarPolicy
        ScrollBar.vertical.policy: control.verticalScrollBarPolicy

        ListView
        {
            id: _listView
            
            property alias position : _hoverHandler.point.position
            property var selectedIndexes : []
                       
            anchors.fill: parent
            anchors.rightMargin: Kirigami.Settings.hasTransientTouchInput ? control.rightMargin: parent.ScrollBar.vertical.visible ? parent.ScrollBar.vertical.width + control.rightMargin : control.rightMargin
            anchors.bottomMargin: Kirigami.Settings.hasTransientTouchInput ? control.bottomMargin : parent.ScrollBar.horizontal.visible ? parent.ScrollBar.horizontal.height + control.bottomMargin : control.bottomMargin

            anchors.leftMargin: control.leftMargin
            anchors.topMargin: control.topMargin
            anchors.margins: control.margins

            focus: true
            clip: control.clip
            spacing: control.enableLassoSelection ? Maui.Style.space.big : Maui.Style.space.medium
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
            
            onPositionChanged: 
            {
                if(_hoverHandler.hovered && position.x < control.width * 0.25 &&  _hoverHandler.point.pressPosition.y != position.y)
                {
                    const index = _listView.indexAt(position.x, position.y)
                    if(!selectedIndexes.includes(index) && index > -1 && index < _listView.count)
                    {
                         selectedIndexes.push(index)
                         control.itemsSelected([index])  
                    }
                }                
            }
            
            HoverHandler
            {
                id: _hoverHandler
                margin: Maui.Style.space.big
                enabled: control.enableLassoSelection && control.selectionMode && !_listView.flicking  
                acceptedDevices: PointerDevice.TouchScreen
                acceptedPointerTypes : PointerDevice.Finger 
                grabPermissions : PointerHandler.CanTakeOverFromAnything  
                
                onHoveredChanged:
                {
                    if(!hovered)
                    {
                        _listView.selectedIndexes = []   
                    }
                }
            } 

            Maui.Holder
            {
                id: _holder
                anchors.fill : parent
            }

//             Kirigami.WheelHandler
//             {
//                 id: wheelHandler
//                 target: parent
//             }

            MouseArea
            {
                id: _mouseArea
                z: -1
                enabled: !Kirigami.Settings.hasTransientTouchInput && !Maui.Handy.isAndroid
                anchors.fill: parent
                propagateComposedEvents: true
                //             preventStealing: true
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
                    if (mouse.source === Qt.MouseEventNotSynthesized)
                    {
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
                }

                onPressAndHold:
                {
                    if ( mouse.source !== Qt.MouseEventNotSynthesized && control.enableLassoSelection && !selectLayer.visible )
                    {
                        selectLayer.visible = true;
                        selectLayer.x = mouseX;
                        selectLayer.y = mouseY;
                        selectLayer.newX = mouseX;
                        selectLayer.newY = mouseY;
                        selectLayer.width = 0
                        selectLayer.height = 0;
                        mouse.accepted = true
                    }else
                    {
                        mouse.accepted = false
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
    
    MouseArea
    {
        height: parent.height
        width: control.width * 0.25
        propagateComposedEvents: true
        preventStealing: true
        enabled: _hoverHandler.enabled && Kirigami.Settings.hasTransientTouchInput     
    }
    
}


