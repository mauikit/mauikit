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
import "private" as Private

Rectangle
{
    id: control
    
    implicitHeight: Maui.Style.rowHeight
//     implicitWidth:  _loader.item.implicitWidth
        
    property string url : ""
    property bool pathEntry: false
    
    readonly property alias list : _pathList
    readonly property alias model : _pathModel
    readonly property alias item : _loader.item
        
    signal pathChanged(string path)
    signal homeClicked()
    signal placeClicked(string path)
    signal placeRightClicked(string path)
    
    onUrlChanged: append()
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    
    color: Kirigami.Theme.backgroundColor
    radius: Maui.Style.radiusV
    border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
    
    Loader
    {
        id: _loader
        anchors.fill: parent
        sourceComponent: pathEntry ? _pathEntryComponent : _pathCrumbsComponent
    }
    
    Maui.BaseModel
    {
        id: _pathModel
        list: _pathList
    }
    
    Maui.PathList
    {
        id: _pathList
    }
    
    Component
    {
        id: _pathEntryComponent
        
        Maui.TextField
        {
            id: entry
            text: control.url
            focus: true
            inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
            Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
            Kirigami.Theme.backgroundColor: "transparent"
            horizontalAlignment: Qt.AlignLeft
            onAccepted:
            {
                pathChanged(text)
                showEntryBar()
            }
            
            background: Rectangle
            {
                color: "transparent"
            }
            
            actions.data: ToolButton
            {
                icon.name: "go-next"
                icon.color: control.Kirigami.Theme.textColor
                onClicked:
                {
                    pathChanged(entry.text)
                    showEntryBar()
                }
            }
            
//             Keys.enabled: true
//             Keys.onPressed:
//             {
//                 console.log(event.key)
//                 pathEntry = false
//             }
        }
    }
    
    Component
    {
        id: _pathCrumbsComponent
        
        RowLayout
        {
            implicitWidth: _listView.contentWidth + (height * 2) + Maui.Style.space.small
            property alias listView: _listView
            spacing: 0
            
            MouseArea
            {
                Layout.fillHeight: true
                Layout.preferredWidth: height * 1.5
                onClicked: control.homeClicked()
                hoverEnabled: Kirigami.Settings.isMobile
                
                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    source: Qt.platform.os == "android" ?  "user-home-sidebar" : "user-home"
                    color: parent.hovered ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                    width: Maui.Style.iconSizes.medium
                    height: width
                }
            }
            
            Kirigami.Separator
            {
                Layout.fillHeight: true
            }            
            
            ScrollView
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                contentWidth: _listView.contentWidth
                contentHeight: height
                ListView
                {
                    id: _listView
                    anchors.fill: parent
                    
                    property int pathArrowWidth: 8
                    orientation: ListView.Horizontal
                    clip: true
                    spacing: 0
					currentIndex: _pathModel.count - 1
                    focus: true
                    interactive: Maui.Handy.isTouch
                    highlightFollowsCurrentItem: true
                    
                    boundsBehavior: Kirigami.Settings.isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds
                    
                    model: _pathModel
                    
                    delegate: Private.PathBarDelegate
                    {
                        id: delegate
//                         borderColor: ListView.isCurrentItem ?  control.Kirigami.Theme.highlightColor :  control.border.color
                        color: ListView.isCurrentItem || hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
//                         smooth: true
//                         arrowWidth: _listView.pathArrowWidth
                        height: parent.height
                        width: Math.max(Maui.Style.iconSizes.medium * 2, implicitWidth)                        
                        
                        Kirigami.Separator
                        {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                        
                        Connections
                        {
                            target: delegate
                            onClicked:
                            {
                                control.placeClicked(_pathList.get(index).path)
                            }
                            
                            onRightClicked:
                            {
                                control.placeRightClicked(_pathList.get(index).path)
                            }
                            
                            onPressAndHold:
                            {
                                control.placeRightClicked(_pathList.get(index).path)
                            }
                        }
                    }
                    
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: showEntryBar()
                        z: -1
                    }
                }
            }         
            
            MouseArea
            {
                Layout.fillHeight: true
                Layout.preferredWidth: control.height
                onClicked: control.showEntryBar()
                hoverEnabled: Kirigami.Settings.isMobile
                
                Rectangle
                {
                    anchors.fill: parent
                    radius: Maui.Style.radiusV
                    color: parent.containsMouse ?  Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2)  : "transparent"
                    Kirigami.Icon
                    {
                        anchors.centerIn: parent
                        source: "filename-space-amarok"
                        color: control.Kirigami.Theme.textColor
                        width: Maui.Style.iconSizes.medium
                        height: width
                    }
                }
            }
        }
    }
    
    function append()
    {
        _pathList.path = control.url
        
        if(_loader.sourceComponent !== _pathCrumbsComponent)
        {
            return
        }
        
        _loader.item.listView.currentIndex = _loader.item.listView.count-1
        _loader.item.listView.positionViewAtEnd()
    }
    
    function showEntryBar()
    {
        control.pathEntry = !control.pathEntry
        if(_loader.sourceComponent === _pathEntryComponent)
        {
             _loader.item.forceActiveFocus()
        }
    }
}
