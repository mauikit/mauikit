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
    focus: true
    default property list<Action> actions 
    property list<Action> hiddenActions
    
    property int display : ToolButton.IconOnly
    
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    readonly property int barHeight : Maui.Style.iconSizes.large  + Maui.Style.space.medium

    readonly property alias uris: _private._uris
    readonly property alias items: _private._items

    property alias selectionList : selectionList
    property alias count : selectionList.count
    
    property int maxListHeight : 400
    
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
                
                emblem.visible: true
                emblem.iconName: "list-remove"
                emblem.border.color: emblem.Kirigami.Theme.textColor
              				
				Connections
				{
					target: _template.emblem
					onClicked: control.removeAtIndex(index)
				}
				
            }
        
    }

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

    signal uriAdded(string uri)
    signal uriRemoved(string uri)

    signal clicked(var mouse)
    signal rightClicked(var mouse)

    implicitHeight: barHeight

    implicitWidth: _layout.implicitWidth + Maui.Style.space.big + (height * 2)

    visible: control.count > 0

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
        radius: Maui.Style.radiusV
        focus: true
        y:  ((height) * -1) + control.height
        x: 0

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

        Maui.ListBrowser
        {
			anchors.fill: parent
			anchors.topMargin: Maui.Style.space.medium
			anchors.bottomMargin: control.height
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
			Layout.margins: Maui.Style.space.medium
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
		Layout.margins: Maui.Style.space.medium
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
	}	
	
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
