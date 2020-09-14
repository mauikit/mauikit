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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

Item
{
    id: control

    default property alias content: _layout.data
        
        //     implicitHeight: _layout.implicitHeight
//         implicitWidth: _layout.implicitWidth
        
        property alias text1 : _label1.text
        
        property alias label1 : _label1
        
        property alias iconItem : _iconLoader.item
        property alias iconVisible : _iconContainer.visible
        
        property int iconSizeHint : Maui.Style.iconSizes.big
        property int imageSizeHint : iconSizeHint
        
        property int imageWidth : iconSizeHint
        property int imageHeight : iconSizeHint
        
        property string imageSource
        property string iconSource
        
        property bool checkable : false
        property bool checked : false
                
        property bool isCurrentItem: false
        property bool labelsVisible: true
        
        property int fillMode : Image.PreserveAspectCrop
        property int maskRadius: Maui.Style.radiusV
        
        property bool hovered: false
        
        property bool imageBorder: true        
        
        signal toggled(bool state)		
        
        Component
        {
            id: _imgComponent
            
            Image
            {
                id: img
                anchors.centerIn: parent
                source: control.imageSource
                height: parent.height
                width: parent.width
                sourceSize.width: control.imageWidth
                sourceSize.height: control.imageHeight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                fillMode: control.fillMode
                cache: true
                asynchronous: true
                smooth: false
                
                layer.enabled: control.maskRadius
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: img.width
                        height: img.height
                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: Math.min(parent.width, img.paintedWidth)
                            height: Math.min(parent.height, img.paintedHeight)
                            radius: control.maskRadius                          
                        }
                    }
                }
                
                Rectangle
                {
                    z: 99999
                    Kirigami.Theme.inherit: false
                    visible: control.imageBorder
                    anchors.centerIn: parent
                    width: Math.min(parent.width, img.paintedWidth)
                    height: Math.min(parent.height, img.paintedHeight)
                    border.color: control.isCurrentItem ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 2.2)
                    radius: control.maskRadius

                    border.width: control.isCurrentItem ? 2 : 1
                    color: "transparent"
                    opacity: 0.6

                    Rectangle
                    {
                        anchors.fill: parent
                        color: "transparent"
                        anchors.margins: 1
                        radius: parent.radius - 0.5
                        border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
                        opacity: 0.3
                    }
                }

                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    height: Math.min(22, parent.height * 0.4)
                    width: height
                    source: "folder-images"
                    isMask: true
                    color: Qt.darker(Kirigami.Theme.backgroundColor, 2.2)
                    opacity: 1 - img.progress
                }

                ColorOverlay
                {
                    anchors.fill: parent

                    visible: control.hovered || control.checked ||control.isCurrentItem
                    opacity: 0.3

                    source: parent
                    color: control.hovered || control.isCurrentItem  ? control.Kirigami.Theme.highlightColor : "#000"
                }
            }
        }
        
        Component
        {
            id: _iconComponent
            
            Kirigami.Icon
            {
                anchors.centerIn: parent
                source: control.iconSource
                fallback: "application-x-zerosize"
                height: Math.floor(Math.min(parent.height, control.iconSizeHint))
                width: height
                color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                
                ColorOverlay
                {
                    visible: control.hovered || control.checked
                    opacity: 0.3
                    anchors.fill: parent
                    source: parent
                    color: control.hovered ? control.Kirigami.Theme.highlightColor : "#000"
                } 
            }            
        }
        
        ColumnLayout
        {
            id: _layout
            anchors.fill: parent
            spacing: Maui.Style.space.tiny
            
            Item
            {
                id: _iconContainer
                Layout.fillWidth: true
                Layout.preferredHeight: control.imageSource ? control.imageSizeHint : control.iconSizeHint 
                
                Loader
                {
                    id: _iconLoader
                    anchors.fill: parent
                    sourceComponent: _iconContainer.visible ? (control.imageSource && control.imageSource.length ? _imgComponent : (control.iconSource && control.iconSource.length ?  _iconComponent : null) ): null

                    Maui.Badge
                    {
                        id: _emblem
                        
                        visible: control.checkable || control.checked
                        
                        size: Maui.Style.iconSizes.medium        
                        anchors.margins: Maui.Style.space.medium
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        
                        color: control.checked ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.5)
                        
                        border.color: Kirigami.Theme.textColor
                        
                        onClicked: 
                        {
							control.checked = !control.checked
							control.toggled(control.checked)
						}
						
                        MauiLab.CheckMark
                        {
							visible: opacity > 0
							color: Kirigami.Theme.highlightedTextColor
							anchors.centerIn: parent
							height: control.checked ? 10 : 0
							width: height
							opacity: control.checked ? 1 : 0
							
							Behavior on height
							{
								NumberAnimation
								{
									duration: Kirigami.Units.shortDuration
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
						}
                    } 
                    
                    DropShadow
                    {
                        anchors.fill: _emblem
                        z: _emblem.z
                        visible: _emblem.visible
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 9.0
                        samples: 18
                        color: "#80000000"
                        source: _emblem
                    }
                }
                
            }
            
            Item
            {
                visible: control.labelsVisible
                
                Layout.fillHeight: true
                Layout.fillWidth: true
                
                Rectangle
                {
                    width: parent.width
                    height: Math.min(_label1.height + Maui.Style.space.small, parent.height)
                    anchors.centerIn: parent
                    Behavior on color
                    {
                        ColorAnimation
                        {
                            duration: Kirigami.Units.longDuration
                        }
                    }
                    
                    color: control.isCurrentItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : control.Kirigami.Theme.backgroundColor
                    
                    radius: Maui.Style.radiusV
                    border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"                    
                }  
 
                Label
                {
                    id: _label1
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    width: control.width
                    height: Math.min(parent.height, implicitHeight)
                    anchors.centerIn: parent
                    elide: Qt.ElideRight
                    wrapMode: Text.Wrap
                    color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor 
                    
                }
                
            }
        }
}
