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
    focus: true
    
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    readonly property int barHeight : Maui.Style.iconSizes.large  + Maui.Style.space.large

    property var selectedPaths: []
    property var selectedItems: []
    
    property alias selectionList : selectionList
    property alias anim : anim
    property alias model : selectionList.model
    property alias count : selectionList.count
    
    property color animColor : "black"
    property int position: Qt.Horizontal
    property string iconName : "overflow-menu"
    property bool iconVisible: true
    
    /**
     * if singleSelection is set to true then only a single item is selected
     * at time, and replaced with a newe item appended
     **/
    property bool singleSelection: false
    
    signal iconClicked()
    signal cleared()
    signal exitClicked()
    signal itemClicked(int index)
	signal itemPressAndHold(int index)
	
	signal itemAdded(var item)
	signal itemRemoved(var item)
	
	signal pathAdded(string path)
	signal pathRemoved(string path)
	
	signal clicked(var mouse)
	signal rightClicked(var mouse)
	
    implicitHeight: if(position === Qt.Horizontal)
                barHeight
            else if(position === Qt.Vertical)
                parent.height
            else
                undefined
    
    implicitWidth: if(position === Qt.Horizontal)
               parent.width
           else if(position === Qt.Vertical)
               barHeight
           else
               undefined
    
    
    visible: selectionList.count > 0

    Rectangle
    {
        id: bg
        anchors.fill: parent
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.6)
        radius: Maui.Style.radiusV
        opacity: 1
        border.color: Kirigami.Theme.backgroundColor
        
        
        MouseArea
        {
			anchors.fill: parent
			acceptedButtons: Qt.RightButton | Qt.LeftButton
			
			onClicked:
			{
				if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
					control.rightClicked(mouse)
					else
						control.clicked(mouse)
			}
			
			onPressAndHold : 
			{
				if(Kirigami.Settings.isMobile)
					control.rightClicked(mouse)
			}
			
			
        }
        
        SequentialAnimation
        {
			id: anim
			PropertyAnimation
			{
				target: bg
				property: "opacity"
				easing.type: Easing.InOutQuad
				from: 0.5
				to: 1
				duration: 600
			}
		}
    }

    Maui.Badge
    {
        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.left

        iconName: "window-close"
        Kirigami.Theme.backgroundColor: Kirigami.Theme.negativeTextColor
        Kirigami.Theme.textColor: Kirigami.Theme.highlightedTextColor
        z: parent.z +1
        onClicked:
        {
            clear()
            exitClicked()
        }
    }

    Maui.Badge
    {
        Kirigami.Theme.backgroundColor: Kirigami.Theme.highlightColor
        text: selectionList.count
        z: parent.z +1

        anchors.verticalCenter: parent.top
        anchors.horizontalCenter: parent.right
        onClicked: clear()        
    }

    GridLayout
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.small
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

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: Maui.Style.space.small
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

            ListView
            {
                id: selectionList
                anchors.fill: parent              
                
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                keyNavigationEnabled: true
                interactive: Kirigami.Settings.isMobile
                boundsBehavior: !Kirigami.Settings.isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
                orientation: if(position === Qt.Horizontal)
                                 ListView.Horizontal
                             else if(position === Qt.Vertical)
                                 ListView.Vertical
                             else
                                 undefined
                clip: true
                focus: true
                
                spacing: Maui.Style.space.small                
                
                ScrollBar.horizontal: ScrollBar 
                {
					policy: Kirigami.Settings.isMobile? Qt.ScrollBarAlwaysOff : Qt.ScrollBarAsNeeded				
				}
                
                model: ListModel{}
                
                delegate: Maui.GridBrowserDelegate
                {
                    id: delegate
                    isCurrentItem: ListView.isCurrentItem
                    height: selectionList.height
                    width: height
                    folderSize: Maui.Style.iconSizes.big
                    showLabel: true
                    keepEmblemOverlay: true
                    showEmblem: !Kirigami.Settings.isMobile
                    showTooltip: true
                    showThumbnails: true
                    emblemSize: Maui.Style.iconSizes.small

                    Connections
                    {
                        target: delegate
                        onLeftEmblemClicked: removeAtIndex(index)
                        onClicked: control.itemClicked(index)
						onPressAndHold: control.itemPressAndHold(index)
                    }
                }
            }
        }
        
        Item
        {
            Layout.fillWidth: position === Qt.Vertical
            Layout.fillHeight: position === Qt.Horizontal
            Layout.preferredWidth: Maui.Style.iconSizes.medium
            Layout.preferredHeight: Maui.Style.iconSizes.medium
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

            Layout.margins: Maui.Style.space.medium

            ToolButton
            {
                visible: iconVisible
                anchors.centerIn: parent
                icon.name: control.iconName
                icon.color: control.Kirigami.Theme.textColor
                onClicked: iconClicked()
            }
        }
    }
    
    onVisibleChanged:
    {
        if(position === Qt.Vertical) return
    }    
    
    Keys.onEscapePressed:
    {
		control.exitClicked();
		event.accepted = true
	}

    Keys.onBackPressed:
    {
        control.exitClicked();
        event.accepted = true
    }
    
    function clear()
    {
        selectedPaths = []
        selectedItems = []
        selectionList.model.clear()
		control.cleared()		
    }
    
    function itemAt(index)
	{
		if(index < 0 ||  index > selectionList.count)
			return
			
		return selectionList.model.get(index)		 
	}
    
    function removeAtIndex(index)
    {
		if(index < 0)
			return
		
		const item = selectionList.model.get(index)
        const path = item.path
        if(contains(path))
        {
            selectedPaths.splice(index, 1)
            selectedItems.splice(index, 1)
            selectionList.model.remove(index)
			control.itemRemoved(item)
			control.pathRemoved(path)
		}
    }
    
    function removeAtPath(path)
	{
		removeAtIndex(indexOf(path))
	}	
	
	function indexOf(path)
	{
		return control.selectedPaths.indexOf(path)
	}
    
    function append(item)
    {
		const index  = selectedPaths.indexOf(item.path)
        if(index < 0)
        {
            if(control.singleSelection)
                clear()

            selectedItems.push(item)
            selectedPaths.push(item.path)
            
            selectionList.model.append(item)
            selectionList.positionViewAtEnd()
			selectionList.currentIndex = selectionList.count - 1
			
			control.itemAdded(item)
			control.pathAdded(item.path)
			
        }else
        {
			selectionList.currentIndex = index
//             notify(item.icon, qsTr("Item already selected!"), String("The item '%1' is already in the selection box").arg(item.label), null, 4000)
        }
         
        animate(Kirigami.Theme.backgroundColor)
    }
    
	function animate(color)
    {
        animColor = color
        anim.running = true
    }
    
    function getSelectedPathsString()
    {
        return String(""+selectedPaths.join(","))
    }
    
    function contains(path)
	{
		return control.selectedPaths.includes(path)
	}
}
