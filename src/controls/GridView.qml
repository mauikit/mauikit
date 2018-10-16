
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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.impl 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import QtGraphicalEffects 1.0

Item
{
	id: control
	
	property int cellWidth: unit * 200
	property int cellHeight: unit * 200
	property int spacing: space.medium
	property int itemSize: 0
	
	property alias model : gridView.model
	property alias delegate : gridView.delegate
	property alias contentY: gridView.contentY
	property alias currentIndex : gridView.currentIndex
	property alias count : gridView.count
	
	property alias topMargin: gridView.topMargin
	property alias bottomMargin: gridView.bottomMargin
	property alias rightMargin: gridView.rightMargin
	property alias leftMarging: gridView.leftMargin
	
	property bool centerContent: false
	property bool adaptContent: false 
			
	signal areaClicked(var mouse)
	signal areaRightClicked()
	
	GridView
	{
		id: gridView
		
		anchors
		{
			leftMargin: scrollBar.visible ? 0 : scrollBar.width
		}
		
		flow: GridView.FlowLeftToRight
		clip: true
		focus: true
		anchors.horizontalCenter: centerContent ? parent.horizontalCenter :
		undefined
		width: centerContent ? Math.min(model.count, 
										Math.floor(parent.width/cellWidth))*cellWidth :
										parent.width
		height: parent.height
		cellWidth: control.cellWidth 
		cellHeight: control.cellHeight
		//        maximumFlickVelocity: albumSize*8
		
		boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
		flickableDirection: Flickable.AutoFlickDirection
		snapMode: GridView.SnapToRow
		highlightMoveDuration: 0
		interactive: true
		ScrollBar.vertical: ScrollBar{ id:scrollBar; visible: true}
		onWidthChanged: adaptContent? control.adaptGrid() : undefined
		
	
		MouseArea
		{
			anchors.fill: parent
			z: -1
			acceptedButtons:  Qt.RightButton | Qt.LeftButton
			onClicked: control.areaClicked(mouse)
			onPressAndHold: control.areaRightClicked()
		}									
	}
	
	
	function adaptGrid()
	{
		var amount = parseInt(gridView.width / (itemSize + spacing), 10)
		var leftSpace = parseInt(gridView.width  - ( amount * (itemSize + spacing) ), 10)
		var size = parseInt((itemSize + spacing) + (parseInt(leftSpace/amount, 10)), 10)
		
		size = size > itemSize + spacing ? size : itemSize + spacing
		
		cellWidth = size
	}
}
