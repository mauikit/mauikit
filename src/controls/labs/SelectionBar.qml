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
import QtGraphicalEffects 1.0

Item
{
    id: control
    
    implicitHeight: barHeight + padding 
    implicitWidth: _layout.implicitWidth + Maui.Style.space.big + (height * 2)
    
    visible: control.count > 0    
    focus: true    
    
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    
    default property list<Action> actions 
    property list<Action> hiddenActions
    property int padding : 0
    property int barHeight: Maui.Style.toolBarHeightAlt  
    property int display : ToolButton.IconOnly
    property int maxListHeight : 400
    property int radius: Maui.Style.radiusV
    /**
     * if singleSelection is set to true then only a single item is selected
     * at time, and replaced with a newe item appended
     **/
    property bool singleSelection: false
    
    readonly property alias uris: _private._uris
    readonly property alias items: _private._items

    readonly property alias selectionList : selectionList
    readonly property alias count : selectionList.count    
    
    property alias background : bg
    
    readonly property QtObject m_private : QtObject
    {
        id: _private
        property var _uris : []
        property var _items : []
    }

    property Component listDelegate: Maui.ItemDelegate
    {
        id: delegate
        height: Maui.Style.rowHeight * 1.5
        width: parent.width

        Kirigami.Theme.backgroundColor: "transparent"
        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor

        onClicked: control.itemClicked(index)
		onPressAndHold: control.itemPressAndHold(index)
		
		Maui.ListItemTemplate
		{
			id: _template
			anchors.fill: parent                
			iconVisible: false
			labelsVisible: true
			label1.text: model.uri               
			
			checkable: true
			checked: true
			onToggled: control.removeAtIndex(index)	
		}        
	}

    signal iconClicked()
    signal cleared()
    signal exitClicked()
    signal itemClicked(int index)
    signal itemPressAndHold(int index)

    signal itemAdded(var item)
    signal itemRemoved(var item)

    signal uriAdded(string uri)
    signal uriRemoved(string uri)

    signal clicked(var mouse)
    signal rightClicked(var mouse)
    
    signal urisDropped(var uris)

    Item
    {
        id: _container
        anchors.centerIn: parent
        implicitHeight: control.barHeight
        width: parent.width
                
        DropShadow
        {
            id: rectShadow
            anchors.fill: _listContainer
            cached: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 16
            color: "#333"
            smooth: true
            source: _listContainer
        }
        
        Rectangle
        {
            id: _listContainer
            property bool showList : false
            height: showList ? Math.min(Math.min(400, control.maxListHeight), selectionList.contentHeight) + control.height + Maui.Style.space.big : 0
            width: parent.width
            color: Qt.lighter(Kirigami.Theme.backgroundColor)
            radius:  control.radius
            focus: true
            y:  ((height) * -1) + parent.height
            x: parent.x
            
            opacity: showList ? 1 : .97
            
            Behavior on height
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
            
            Maui.ListBrowser
            {
                anchors.fill: parent
                anchors.topMargin: Maui.Style.space.medium
                anchors.bottomMargin: _container.height
                id: selectionList
                padding: 0
                visible: _listContainer.height > 10
                spacing: Maui.Style.space.small
                model: ListModel{}
                background: null
                
                delegate: control.listDelegate			
            }   
        }
        
        Rectangle
        {
            id: bg
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            radius: control.radius
            border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
            
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
        
        RowLayout
        {
            id: _rowLayout
            anchors.fill: parent
            clip: true
            spacing: 0
            
            Maui.Badge
            {            
                Kirigami.Theme.colorSet: control.Kirigami.Theme.colorSet
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.margins: Maui.Style.space.tiny
                radius: Maui.Style.radiusV
                onClicked: control.exitClicked()
                Kirigami.Theme.backgroundColor: Qt.darker(bg.color)
                border.color: "transparent"
                
                Maui.X
                {
                    height: Maui.Style.iconSizes.medium - 10
                    width: height
                    anchors.centerIn: parent
                    color: parent.hovered ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor            
                }
            }		
            
            Maui.ToolBar
            {
                id: _layout
                clip: true
                position: ToolBar.Footer
                
                Layout.fillWidth: true
                Layout.fillHeight: true
                preferredHeight: height
                background: Item{}
                leftSretch: false
                rightSretch: false
                middleContent: Repeater
                {
                    model: control.actions
                    
                    ToolButton
                    {
                        action: modelData
                        display: control.display
                        Kirigami.Theme.colorSet: control.Kirigami.Theme.colorSet
                        
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered || pressed && action.text
                        ToolTip.text: action.text
                    }
                }
                
                rightContent: Maui.ToolButtonMenu
                {
                    visible: content.length > 0
                    content: control.hiddenActions
                }			
            }  		
            
            Maui.Badge
            {
                id: _counter
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.margins: Maui.Style.space.tiny
                text: selectionList.count
                radius: Maui.Style.radiusV
                
                Kirigami.Theme.backgroundColor: _listContainer.showList ?
                Kirigami.Theme.highlightColor : Qt.darker(bg.color)
                border.color: "transparent"
                
                onClicked:
                {
                    _listContainer.showList = !_listContainer.showList
                }
                
                Component.onCompleted:
                {
                    _counter.item.font.pointSize= Maui.Style.fontSizes.big
                    
                }
                
                SequentialAnimation
                {
                    id: anim
                    
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
                
                Maui.Rectangle
                {
                    opacity: 0.3
                    anchors.fill: parent
                    anchors.margins: 4
                    visible: _counter.hovered
                    color: "transparent"
                    borderColor: "white"
                    solidBorder: false
                }
                
                MouseArea
                {
                    id: _mouseArea
                    anchors.fill: parent
                    propagateComposedEvents: true
                    property int startX
                    property int startY
                    Drag.active: drag.active
                    Drag.hotSpot.x: 0
                    Drag.hotSpot.y: 0
                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.CopyAction
                    Drag.keys: ["text/plain","text/uri-list"]
                    
                    onPressed: 
                    {
                        if( mouse.source !== Qt.MouseEventSynthesizedByQt)
                        {
                            drag.target = _counter
                            _counter.grabToImage(function(result)
                            {
                                _mouseArea.Drag.imageSource = result.url
                            })
                            
                            _mouseArea.Drag.mimeData = { "text/uri-list": control.uris.join("\n")}
                            
                            startX = _counter.x
                            startY = _counter.y
                            
                        }else mouse.accepted = false
                    }
                    
                    onReleased :
                    {
                        _counter.x = startX
                        _counter.y = startY
                    }
                }
            }	
            
        }
        
        Maui.Rectangle
        {
            opacity: 0.2
            anchors.fill: parent
            anchors.margins: 4
            visible: _dropArea.containsDrag
            color: "transparent"
            borderColor: "white"
            solidBorder: false
        }
    }
    
    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            control.urisDropped(drop.urls)
        }
    }

    Keys.onEscapePressed:
    {
        control.exitClicked();
    }

    Keys.onBackPressed:
    {
        control.exitClicked();
        event.accepted = true
    }

    function clear()
    {
        _private._uris = []
        _private._items = []
        _listContainer.showList = false
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
        const uri = item.uri

        if(contains(uri))
        {
            _private._uris.splice(index, 1)
            _private._items.splice(index, 1)
            selectionList.model.remove(index)
            control.itemRemoved(item)
            control.uriRemoved(uri)
        }
    }

    function removeAtUri(uri)
    {
        removeAtIndex(indexOf(uri))
    }

    function indexOf(uri)
    {
        return _private._uris.indexOf(uri)
    }

    function append(uri, item)
    {
        const index  = _private._uris.indexOf(uri)
        if(index < 0)
        {
            if(control.singleSelection)
                clear()

            _private._items.push(item)
            _private._uris.push(uri)

            item.uri = uri
            selectionList.model.append(item)
            selectionList.listView.positionViewAtEnd()
            selectionList.currentIndex = selectionList.count - 1

            control.itemAdded(item)
            control.uriAdded(uri)

        }else
        {
            selectionList.currentIndex = index
            //             notify(item.icon, qsTr("Item already selected!"), String("The item '%1' is already in the selection box").arg(item.label), null, 4000)
        }

        animate()
    }

    function animate()
    {
        anim.running = true
    }

    function getSelectedUrisString()
    {
        return String(""+_private._uris.join(","))
    }

    function contains(uri)
    {
        return _private._uris.includes(uri)
    }
}
