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
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Item
{
    id: control
    focus: true
    
    default property list<Action> actions
    
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    readonly property int barHeight : Maui.Style.iconSizes.large  + Maui.Style.space.medium 
    
    property var selectedPaths: []
    property var selectedItems: []
    
    property alias selectionList : selectionList
    property alias model : selectionList.model
    property alias count : selectionList.count
    
    
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
    
    implicitHeight: barHeight
    
    implicitWidth: _layout.implicitWidth + Maui.Style.space.big
    
    visible: control.count > 0
    
    Rectangle
    {
        id: _bg2
        property bool showList : false
        height: showList ?  Math.min(400, selectionList.contentHeight) + Maui.Style.space.big : 0
        width:  showList ? parent.width  : 0
          color: Qt.lighter(Kirigami.Theme.backgroundColor)
        radius: Maui.Style.radiusV 
        
        y:  ((height) * -1) + Maui.Style.space.tiny
        
       
        x: showList ? 0 : Maui.Style.space.big
        opacity: showList ? 1 : .97
        
        Behavior on height
    {

        NumberAnimation
        {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    
     Behavior on width
    {

        NumberAnimation
        {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    Behavior on opacity
    {
        NumberAnimation
        {
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.InOutQuad
        }
    }
        
        ListView
        {
            id: selectionList
            anchors.fill: parent   
            anchors.margins: Maui.Style.space.medium
            visible: _bg2.height > 10
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
            keyNavigationEnabled: true
            interactive: Kirigami.Settings.isMobile
            boundsBehavior: !Kirigami.Settings.isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
            orientation: ListView.Vertical
                    clip: true
                    focus: true
                    
                    spacing: Maui.Style.space.small                
                    
                    ScrollBar.vertical: ScrollBar 
                    {
                        policy: Qt.ScrollBarAsNeeded
                        
                    }
                    
                    model: ListModel{}
                    
                    delegate: Maui.ListBrowserDelegate
                    {
                        id: delegate
                        isCurrentItem: ListView.isCurrentItem
                        height: Maui.Style.rowHeight * 1.5
                        width: parent.width
                        folderSize: Maui.Style.iconSizes.medium
                        showLabel: true
                        keepEmblemOverlay: true
                        leftEmblem: "list-remove"
                        showEmblem: false
                        showTooltip: true
                        showThumbnails: true
                        emblemSize: Maui.Style.iconSizes.small
                        Kirigami.Theme.backgroundColor: "transparent"
                        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
                        
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
    
    Rectangle
    {
        id: bg
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        radius: Maui.Style.radiusV        
        
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
        
    }
    
    Maui.ToolBar
    {
        id: _layout
        anchors.fill: parent
        
        background: null
        
        leftContent: Maui.Badge
        {
            id: _counter
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.margins: Maui.Style.space.medium
            text: selectionList.count
            radius: Maui.Style.radiusV
            
            Kirigami.Theme.backgroundColor: _bg2.showList ? Kirigami.Theme.highlightColor : Qt.darker(bg.color)
            border.color: "transparent"
            
            onClicked: 
            {
               _bg2.showList = !_bg2.showList
            }
            
            Component.onCompleted:
            {
               _counter.item.font.pointSize= Maui.Style.fontSizes.big

            }
            
            SequentialAnimation
        {
            id: anim
//             PropertyAnimation
//             {
//                 target: _counter
//                 property: "opacity"
//                 easing.type: Easing.InOutQuad
//                 from: 0.5
//                 to: 1
//                 duration: 600
//             }
//             
PropertyAnimation
            {
                target: _counter
                property: "radius"
                easing.type: Easing.InOutQuad
                from: target.height
                to: Maui.Style.radiusV
                duration: 200
            }
        }
        }
        
        rightContent: [
        
          
                Repeater
            {
                model: control.actions
                
                ToolButton
                {                  
                    Kirigami.Theme.colorSet: control.Kirigami.Theme.colorSet
                    action: modelData
                 
                }
            
            },
        
           ToolButton
            {
                icon.name: "dialog-close"
            onClicked: control.clear()
            Kirigami.Theme.colorSet: control.Kirigami.Theme.colorSet
          
            }          
            
        ]
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
