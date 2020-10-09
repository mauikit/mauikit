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
import QtGraphicalEffects 1.0

Item
{
    id: control
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    focus: true

    implicitHeight: contentHeight + margins*2
    implicitWidth: contentWidth + margins*2

    property int itemSize: 0
    property int itemWidth : itemSize
    property int itemHeight : itemSize

    onItemSizeChanged :
    {
        controlView.size_ = itemSize
        control.itemWidth = itemSize
        control.cellWidth = itemWidth
        if(adaptContent)
            control.adaptGrid()
    }

    property alias cellWidth: controlView.cellWidth
    property alias cellHeight: controlView.cellHeight
    property alias model : controlView.model
    property alias delegate : controlView.delegate
    property alias contentY: controlView.contentY
    property alias currentIndex : controlView.currentIndex
    property alias count : controlView.count
    property alias cacheBuffer : controlView.cacheBuffer
    property alias flickable : controlView
    property alias contentHeight : controlView.contentHeight
    property alias contentWidth : controlView.contentWidth

    property int topMargin: margins
    property int bottomMargin: margins
    property int rightMargin: margins
    property int leftMargin: margins
    property int margins: isWide ? Maui.Style.space.medium :  (Kirigami.Settings.isMobile ? 0 : Maui.Style.space.tiny)

    property alias holder : _holder

    property bool adaptContent: true
    property bool enableLassoSelection : false
    property bool selectionMode: false
    property alias lassoRec : selectLayer

    property alias pinchEnabled : _pinchArea.enabled

    signal itemsSelected(var indexes)
    signal areaClicked(var mouse)
    signal areaRightClicked()
    signal keyPress(var event)

    Keys.enabled : true
    Keys.forwardTo : controlView
    
    ScrollView
    {
        anchors.fill: parent

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        GridView
        {            
            id: controlView            
            
            property alias position : _hoverHandler.point.position
            property var selectedIndexes : []
            
            anchors.fill: parent
            anchors.rightMargin: control.rightMargin
            anchors.leftMargin: control.leftMargin
            anchors.bottomMargin: control.bottomMargin
            anchors.topMargin: control.topMargin
            anchors.margins: control.margins

            //nasty trick
            property int size_
            Component.onCompleted:
            {
                controlView.size_ = control.itemWidth
            }

            flow: GridView.FlowLeftToRight
            clip: true
            focus: true

            cellWidth: control.itemWidth
            cellHeight: control.itemHeight

            boundsBehavior: !Kirigami.Settings.isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
            flickableDirection: Flickable.AutoFlickDirection
            snapMode: GridView.NoSnap
            highlightMoveDuration: 0
            interactive: Kirigami.Settings.hasTransientTouchInput
            onWidthChanged: if(adaptContent) control.adaptGrid()
            onCountChanged: if(adaptContent) control.adaptGrid()

            keyNavigationEnabled : true
            keyNavigationWraps : true
            Keys.onPressed: control.keyPress(event)

//             Kirigami.WheelHandler
//             {
//                 id: wheelHandler
//                 target: parent
//             }
            
            onPositionChanged: 
            {
                console.log("===>" +_hoverHandler.point.pressPosition.y, _hoverHandler.point.sceneGrabPosition.y, position.y, _hoverHandler.point.scenePressPosition)
                if(_hoverHandler.hovered && !controlView.moving && _hoverHandler.point.pressPosition.y != position.y)
                {                   
                    const index = controlView.indexAt(position.x, position.y)
                    if(!selectedIndexes.includes(index))
                    {
                         selectedIndexes.push(index)
                         control.itemsSelected([index])  
                    }
                }                
            }
            
            HoverHandler
            {
                id: _hoverHandler
                enabled: control.enableLassoSelection && control.selectionMode && !controlView.flicking
                acceptedDevices: PointerDevice.TouchScreen
                acceptedPointerTypes : PointerDevice.Finger 
                grabPermissions : PointerHandler.ApprovesTakeOverByItems	
                
                onHoveredChanged:
                {
                    if(!hovered)
                    {
                        controlView.selectedIndexes = []   
                    }
                }
            }

            Maui.Holder
            {
                id: _holder
                anchors.fill : parent
            }

            PinchArea
            {
                id: _pinchArea
                anchors.fill: parent
                z: -1
                onPinchFinished:
                {
                    resizeContent(pinch.scale)
                }
            }

            MouseArea
            {
                id: _mouseArea
                z: -1
                enabled: !Kirigami.Settings.hasTransientTouchInput && !Kirigami.Settings.isMobile
                anchors.fill: parent
                propagateComposedEvents: true
//                 preventStealing: true
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

                onWheel:
                {
                    if (wheel.modifiers & Qt.ControlModifier)
                    {
                        if (wheel.angleDelta.y != 0)
                        {
                            var factor = 1 + wheel.angleDelta.y / 600;
                            control.resizeContent(factor)
                        }
                    }else
                        wheel.accepted = false
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
                            if(!controlView.atYEnd &&  mouseY > (control.y + control.height))
                                controlView.contentY += 10
                        } else {
                            selectLayer.y = mouseY < control.y ? control.y : mouseY;
                            selectLayer.height = selectLayer.newY - selectLayer.y;

                            if(!controlView.atYBeginning && selectLayer.y === 0)
                                controlView.contentY -= 10
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

                    if(selectLayer.y > controlView.contentHeight)
                    {
                        return selectLayer.reset();
                    }

                    var lassoIndexes = []
                    const limitX = mouse.x === lassoRec.x ? lassoRec.x+lassoRec.width : mouse.x
                    const limitY =  mouse.y === lassoRec.y ?  lassoRec.y+lassoRec.height : mouse.y

                    for(var i =lassoRec.x; i < limitX; i+=(lassoRec.width/(controlView.cellWidth* 0.5)))
                    {
                        for(var y = lassoRec.y; y < limitY; y+=(lassoRec.height/(controlView.cellHeight * 0.5)))
                        {
                            const index = controlView.indexAt(i,y+controlView.contentY)
                            if(!lassoIndexes.includes(index) && index>-1 && index< controlView.count)
                                lassoIndexes.push(index)
                        }
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

//       MouseArea
//     {
//         anchors.fill: parent
//         propagateComposedEvents: true
//         
//         property point position: Qt.point(mouseX, mouseY)
//         
//         onMouseXChanged: 
//         {
//          console.log("Pos changed")
//              const index = controlView.indexAt(mouseX, mouseY)
//              control.itemsSelected([index])   
//         }
//         
//         onPressed:
//         {
//             
//              mouse.accepted = false
//         }
//     }

        function resizeContent(factor)
        {
            const newSize= control.itemSize * factor

            if(newSize > control.itemSize)
            {
                control.itemSize =  newSize
            }
            else
            {
                if(newSize >= Maui.Style.iconSizes.small)
                    control.itemSize =  newSize
            }
        }

        function adaptGrid()
        {
            var fullWidth = controlView.width
            var realAmount = parseInt(fullWidth / controlView.size_, 10)
            var amount = parseInt(fullWidth / control.cellWidth, 10)

            var leftSpace = parseInt(fullWidth - ( realAmount * controlView.size_ ), 10)
            var size = Math.min(amount, realAmount) >= control.count ? Math.max(control.cellWidth, control.itemSize) : parseInt((controlView.size_) + (parseInt(leftSpace/realAmount, 10)), 10)

            control.cellWidth = size
        }
}
