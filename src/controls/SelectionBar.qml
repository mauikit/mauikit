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
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Item
{
    id: control

    colorScheme.textColor : colorScheme.altColorText
    
    property var selectedPaths: []
    property alias selectionList : selectionList
    property alias anim : anim
    property int barHeight : iconSizes.big + space.large + space.small
    property color animColor : "black"

    property int position: Qt.Horizontal
    property string iconName : "overflow-menu"
    property bool iconVisible: true

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

    Rectangle
    {
        id: bg
        anchors.fill: parent
        z:-1
        color: colorScheme.altColor
        radius: radiusV
        opacity: 0.6
        border.color: colorScheme.borderColor

        SequentialAnimation
        {
            id: anim
            PropertyAnimation
            {
                target: bg
                property: "color"
                easing.type: Easing.InOutQuad
                from: animColor
                to: Qt.lighter(colorScheme.altColor, 1.2)
                duration: 500
            }
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: riseContent()
        }
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
			colorScheme.backgroundColor: dangerColor
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
                    height:  iconSizes.big + (isMobile ? space.medium : space.big)
                    width: iconSizes.big + (isMobile? space.big : space.large) + space.big
                    folderSize: iconSizes.big
                    showLabel: true
                    emblemAdded: true
                    keepEmblemOverlay: true
                    showSelectionBackground: false
                    labelColor: colorScheme.textColor
                    showTooltip: true
                    showThumbnails: true
                    emblemSize: iconSizes.small
                    leftEmblem: "emblem-remove"

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
            Maui.ToolButton
            {
                visible: iconVisible
                anchors.centerIn: parent
                iconName: control.iconName
                iconColor: control.colorScheme.textColor
                onClicked: iconClicked()
            }
        }

        Maui.Badge
        {
			colorScheme.backgroundColor: highlightColor			
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
        selectionList.model.clear()
    }

    function removeSelection(index)
    {
        var path = selectionList.model.get(index).path
        if(selectedPaths.indexOf(path) > -1)
        {
            selectedPaths.splice(index, 1)
            selectionList.model.remove(index)
        }
    }

    function append(item)
    {
        if(selectedPaths.indexOf(item.path) < 0)
        {
            selectedPaths.push(item.path)

            for(var i = 0; i < selectionList.count ; i++ )
                if(selectionList.model.get(i).path === item.path)
                {
                    selectionList.model.remove(i)
                    return
                }

            selectionList.model.append(item)
            selectionList.positionViewAtEnd()

            if(position === Qt.Vertical) return
            if(typeof(riseContent) === "undefined") return

            riseContent()
        }
    }

    function animate(color)
    {
        animColor = color
        anim.running = true
    }
    
    
}
