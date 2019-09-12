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
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Item
{
    id: control
    Kirigami.Theme.inherit: false    
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary    
    
    property var selectedPaths: []
    property var selectedItems: []
    
    property alias selectionList : selectionList
    property alias anim : anim
    property alias model : selectionList.model
    property alias count : selectionList.count
    
    property int barHeight : itemHeight + space.large
    property color animColor : "black"
    property int itemHeight: iconSizes.big + space.big
    property int itemWidth:  iconSizes.big + (isMobile? space.big : space.large) + space.big
    property int position: Qt.Horizontal
    property string iconName : "overflow-menu"
    property bool iconVisible: true
    
    /**
	 * if singleSelection is set to true then only a single item is selected
	 * at time, and replaced with a newe item appended
	 **/
	
    property bool singleSelection: false
    
    signal iconClicked()
    signal modelCleared()
    signal exitClicked()
    
    height: if(position === Qt.Horizontal)
                barHeight
            else if(position === Qt.Vertical)
                parent.height
            else
                undefined
    
    width: if(position === Qt.Horizontal)
               parent.width
           else if(position === Qt.Vertical)
               barHeight
           else
               undefined
    
    
    visible: selectionList.count > 0
    
    
    Drag.keys: control.selectedPaths
    
    
    Drag.active: _mouseArea.drag.active
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction
    
    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent        
        drag.target: parent
        onPressed: selectionList.grabToImage(function(result)
        {
            console.log("PRESSED SELECTIONBOX", control.selectedPaths.join(","))
            parent.Drag.imageSource = result.url
        })
    }
    
    Rectangle
    {
        id: bg
        anchors.fill: parent
//         Kirigami.Theme.colorSet: Kirigami.Theme.Complementary    
        color: Kirigami.Theme.backgroundColor
        radius: radiusV

        opacity: 1
        border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
		
       
    }
    
    
    GridLayout
    {
        anchors.fill: parent
        rows: if(position === Qt.Horizontal)
                  1
              else if(position === Qt.Vertical)
                  4
              else
                  undefined
        
        columns: if(position === Qt.Horizontal)
                     4
                 else if(position === Qt.Vertical)
                     1
                 else
                     undefined
                     
        
        Maui.Badge
        {
            anchors.verticalCenter: parent.top
            anchors.horizontalCenter: parent.left
            Layout.column: if(position === Qt.Horizontal)
                               1
                           else if(position === Qt.Vertical)
                               1
                           else
                               undefined
            
            Layout.row: if(position === Qt.Horizontal)
                            1
                        else if(position === Qt.Vertical)
                            1
                        else
                            undefined
            
            iconName: "window-close"
			Kirigami.Theme.backgroundColor: dangerColor
			Kirigami.Theme.textColor: Kirigami.Theme.highlightedTextColor
			
			onClicked:
            {
                selectionList.model.clear()
                exitClicked()
            }
        }
        
        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.column: if(position === Qt.Horizontal)
                               2
                           else if(position === Qt.Vertical)
                               1
                           else
                               undefined
            
            Layout.row: if(position === Qt.Horizontal)
                            1
                        else if(position === Qt.Vertical)
                            2
                        else
                            undefined
            
            Layout.alignment: if(position === Qt.Horizontal)
                                  Qt.AlignVCenter
                              else if(position === Qt.Vertical)
                                  Qt.AlignHCenter
                              else
                                  undefined
            ListView
            {
                id: selectionList
                anchors.fill: parent
                
                 SequentialAnimation
        {
            id: anim
            PropertyAnimation
            {
                target: selectionList
                property: "y"
                easing.type: Easing.InOutQuad
                from: (-200)
                to: 0
                duration: 100
            }
        }       
                
                boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
                orientation: if(position === Qt.Horizontal)
                                 ListView.Horizontal
                             else if(position === Qt.Vertical)
                                 ListView.Vertical
                             else
                                 undefined
                clip: true
                spacing: space.small
                
                focus: true
                interactive: true
                model: ListModel{}
                
                delegate: Maui.IconDelegate
                {
                    id: delegate
                    
                    anchors.verticalCenter: position === Qt.Horizontal ? parent.verticalCenter : undefined
                    anchors.horizontalCenter: position === Qt.Vertical ? parent.horizontalCenter : undefined
                    height:  itemHeight
                    width: itemWidth
                    folderSize: iconSizes.big
                    showLabel: true
                    emblemAdded: true
                    keepEmblemOverlay: true
                    showEmblem: true
                    showSelectionBackground: false
                    labelColor: Kirigami.Theme.textColor
                    showTooltip: true
                    showThumbnails: true
                    emblemSize: iconSizes.small
                    leftEmblem: "list-remove"
					Kirigami.Theme.highlightColor: Kirigami.Theme.highlightColor
					Kirigami.Theme.backgroundColor: Kirigami.Theme.complementaryBackgroundColor
					Kirigami.Theme.textColor: Kirigami.Theme.textColor
                    
                    Connections
                    {
                        target: delegate
                        onLeftEmblemClicked: removeSelection(index)
                    }
                }
                
            }
        }
        
        Item
        {
            Layout.alignment: if(position === Qt.Horizontal)
                                  Qt.AlignRight || Qt.AlignVCenter
                              else if(position === Qt.Vertical)
                                  Qt.AlignCenter
                              else
                                  undefined
            Layout.fillWidth: position === Qt.Vertical
            Layout.fillHeight: position === Qt.Horizontal
            Layout.maximumWidth: iconSizes.medium
            Layout.column: if(position === Qt.Horizontal)
                               3
                           else if(position === Qt.Vertical)
                               1
                           else
                               undefined
            
            Layout.row: if(position === Qt.Horizontal)
                            1
                        else if(position === Qt.Vertical)
                            3
                        else
                            undefined
            
            Layout.margins: space.big 
            
            ToolButton
            {
                visible: iconVisible
                anchors.centerIn: parent
                icon.name: control.iconName
                icon.color: control.Kirigami.Theme.textColor
                onClicked: iconClicked()
            }
        }
        
        Maui.Badge
        {
			Kirigami.Theme.backgroundColor: Kirigami.Theme.highlightColor			
            text: selectionList.count
            
            anchors.verticalCenter: parent.top
            anchors.horizontalCenter: parent.right
            Layout.column: if(position === Qt.Horizontal)
                               4
                           else if(position === Qt.Vertical)
                               1
                           else
                               undefined
            
            Layout.row: if(position === Qt.Horizontal)
                            1
                        else if(position === Qt.Vertical)
                            4
                        else
                            undefined          
            onClicked:
            {
                clear()
                modelCleared()
            }
        }
    }
    
    onVisibleChanged:
    {
        if(position === Qt.Vertical) return
        
        if(typeof(riseContent) === "undefined") return
        
        if(control.visible)
            riseContent()
        else
            dropContent()
    }
    
    function clear()
    {
        selectedPaths = []
        selectedItems = []
        selectionList.model.clear()
    }
    
    function removeSelection(index)
    {
        var path = selectionList.model.get(index).path
        if(selectedPaths.indexOf(path) > -1)
        {
            selectedPaths.splice(index, 1)
            selectedItems.splice(index, 1)
            selectionList.model.remove(index)
        }
    }
    
    function append(item)
    {
        if(selectedPaths.indexOf(item.path) < 0)
        {
			if(control.singleSelection)
				clear()
			
            selectedItems.push(item)
            selectedPaths.push(item.path)
            
            //             for(var i = 0; i < selectionList.count ; i++ )
            //                 if(selectionList.model.get(i).path === item.path)
            //                 {
            //                     selectionList.model.remove(i)
            //                     return
            //                 }
            
            selectionList.model.append(item)
            selectionList.positionViewAtEnd()
        }
    }
    
    function animate(color)
    {
        animColor = color
        anim.running = true
    }  
    
    function getSelectedPathsString()
    {
        var paths = ""+selectedPaths.join(",")
        return paths
    }
}
