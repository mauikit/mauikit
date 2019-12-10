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
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0
import "private"

Maui.ItemDelegate
{
    id: control 
    
    property int folderSize : Maui.Style.iconSizes.big
    property int emblemSize: Maui.Style.iconSizes.medium
    property bool showLabel : true
    property bool showEmblem : false
    property bool showTooltip : false
    property bool showThumbnails : false
    property bool isSelected : false    
    property bool keepEmblemOverlay : false    
    property string rightEmblem
    property string leftEmblem
    
    property alias dropArea : _dropArea    
    
    
    isCurrentItem : GridView.isCurrentItem || isSelected    
    
    signal emblemClicked(int index)
    signal rightEmblemClicked(int index)
    signal leftEmblemClicked(int index)
    signal contentDropped(var drop)
    
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered && control.showTooltip
    ToolTip.text: model.tooltip ? model.tooltip : model.path 
    
    background: null
    
    DropArea 
    {
        id: _dropArea
        anchors.fill: parent
        enabled: control.draggable
        
        Rectangle 
        {
            anchors.fill: parent
            radius: Maui.Style.radiusV
            color: control.Kirigami.Theme.highlightColor		
            visible: parent.containsDrag
        }
        
        onDropped:
        {
            control.contentDropped(drop)
        }
    }
    
    Drag.active: mouseArea.drag.active && control.draggable
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction
    Drag.mimeData:
    {
        "text/uri-list": model.path
    }
    
    
    Maui.Badge
    {
        id: _leftEmblemIcon
        iconName: control.leftEmblem
        visible: (control.hovered || control.keepEmblemOverlay || control.isSelected) && control.showEmblem  && control.leftEmblem
        z: mouseArea.z + 1
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked: leftEmblemClicked(index)
        size: Maui.Style.iconSizes.small
    }
    
    Maui.Badge
    {
        id: _rightEmblemIcon
        iconName: rightEmblem
        visible: (control.hovered || control.keepEmblemOverlay) && control.showEmblem && control.rightEmblem
        z: 999
        size: Maui.Style.iconSizes.medium
        anchors.top: parent.top
        anchors.right: parent.right
        onClicked: rightEmblemClicked(index)
    }
    
    Component
    {
        id: _imgComponent
        
        Image
        {
            id: img
            anchors.centerIn: parent
            source: model.thumbnail && model.thumbnail.length ? model.thumbnail : ""
            height: Math.min (parent.height, img.implicitHeight)
            width: Math.min(parent.width, img.implicitWidth)
            sourceSize.width: width
            sourceSize.height: height
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            fillMode: Image.PreserveAspectCrop
            cache: true
            asynchronous: true
            smooth: !Kirigami.Settings.isMobile
            
            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: img.width
                    height: img.height
                    Rectangle
                    {
                        anchors.centerIn: parent
                        width: img.width
                        height: img.height
                        radius: Maui.Style.radiusV
                    }
                }
            }
        }
    }
    
    Component
    {
        id: _iconComponent
        
        Item
        {
            anchors.fill: parent
            Kirigami.Icon
            {
                anchors.centerIn: parent
                source: model.icon
                fallback: "qrc:/assets/application-x-zerosize.svg"
                height: Math.min(control.folderSize, parent.width)
                width: height
            }
        }
    }
    
    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: Maui.Style.space.tiny
        opacity: (model.hidden == true || model.hidden == "true" )? 0.5 : 1
        
        Loader
        {
            id: _loader
            sourceComponent: model.mime ? (Maui.FM.checkFileType(Maui.FMList.IMAGE, model.mime) && control.showThumbnails && model.thumbnail && model.thumbnail.length? _imgComponent : _iconComponent) : _iconComponent
            Layout.preferredHeight: Math.min(control.folderSize, width)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            Layout.margins: Maui.Style.unit		
        }        
        
        Item
        {
            Layout.margins: Maui.Style.space.tiny
            Layout.fillHeight: true
            Layout.fillWidth: true
            
            Label
            {
                id: label
                text: model.label
                width: parent.width
                anchors.centerIn: parent
                height: Math.min(implicitHeight + Maui.Style.space.medium, _layout.height - _loader.height)
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                elide: Qt.ElideRight
                wrapMode: Text.Wrap
                color: control.Kirigami.Theme.textColor		
                
                Rectangle
                {
                    anchors.fill: parent
                    
                    Behavior on color
                    {
                        ColorAnimation
                        {
                            duration: Kirigami.Units.longDuration
                        }
                    }
                    color: control.isCurrentItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : control.Kirigami.Theme.backgroundColor
                    
                    radius: control.radius
                    border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"
                }
            }
        }        
        
    }
}
