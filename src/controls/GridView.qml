
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

import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.impl 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtGraphicalEffects 1.0

Kirigami.ScrollablePage
{
    id: control

    property int itemSize: 0
    onItemSizeChanged :  gridView.size_ = itemSize    

    property alias cellWidth: gridView.cellWidth
    property alias cellHeight: gridView.cellHeight
    property alias model : gridView.model
    property alias delegate : gridView.delegate
    property alias contentY: gridView.contentY
    property alias currentIndex : gridView.currentIndex
    property alias count : gridView.count
    property alias cacheBuffer : gridView.cacheBuffer

    property alias topMargin: gridView.topMargin
    property alias bottomMargin: gridView.bottomMargin
    property alias rightMargin: gridView.rightMargin
    property alias leftMarging: gridView.leftMargin
    property alias holder : _holder
    property alias gridView : gridView

    property bool centerContent: false //deprecrated
    property bool adaptContent: true

    signal areaClicked(var mouse)
    signal areaRightClicked()

    spacing: Maui.Style.space.medium

    Kirigami.Theme.backgroundColor: "transparent"
    padding: 0
    leftPadding: control.ScrollBar.visible ? padding : control.ScrollBar.width
    rightPadding: padding
    topPadding: padding
    bottomPadding: padding
    focus: true

	Behavior on cellWidth
	{
		NumberAnimation
		{
			duration: Kirigami.Units.longDuration 
			easing.type: Easing.InQuad
		}
	}     
    
    GridView
    {
        id: gridView
        
        //nasty trick
        property int size_    
        Component.onCompleted:
        {
			gridView.size_ = control.itemSize
        }

        flow: GridView.FlowLeftToRight
        clip: true
        focus: true

        cellWidth: control.itemSize
        cellHeight: control.itemSize

        boundsBehavior: !Kirigami.Settings.isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
        flickableDirection: Flickable.AutoFlickDirection
        snapMode: GridView.NoSnap
        highlightMoveDuration: 0
        interactive: true
        onWidthChanged: adaptContent? control.adaptGrid() : undefined

        Maui.Holder
        {
            id: _holder
            anchors.fill : parent
        }
        
             PinchArea
    {
		anchors.fill: parent
		z: -1
		onPinchStarted:
		{
			console.log("pinch started")
		}
		
		onPinchUpdated:
		{
			
		}
		
		onPinchFinished:
		{
			console.log("pinch finished")
			resizeContent(pinch.scale)
		}
		
		MouseArea
		{
			anchors.fill: parent
			propagateComposedEvents: true
			acceptedButtons:  Qt.RightButton | Qt.LeftButton
			onClicked: control.areaClicked(mouse)
			onPressAndHold: control.areaRightClicked()
// 			scrollGestureEnabled : false 
			
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
		}
	}
    }
    


    function resizeContent(factor)
    {
        if(factor > 1)
        {
			gridView.size_ = gridView.size_ + 10
			control.cellHeight = control.cellHeight + 10
        }
        else
        {
			gridView.size_ = gridView.size_ - 10
			control.cellHeight = control.cellHeight - 10
        }

        if(adaptContent)
            control.adaptGrid()
    }

    function adaptGrid()
    {
        var amount = parseInt(gridView.width / (gridView.size_), 10)
        var leftSpace = parseInt(gridView.width  - ( amount * (gridView.size_) ), 10)
		var size = parseInt((gridView.size_) + (parseInt(leftSpace/amount, 10)), 10)
// 		size = size > gridView.size_? size : gridView.size_
		control.cellWidth = size
    }    
}
