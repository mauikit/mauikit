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
                sourceSize.width:control.imageWidth
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
                            anchors.fill: parent
                            radius: control.maskRadius                          
                        }
                    }
                }
                
                Rectangle
                {
                    anchors.fill: parent
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.8)   
                    radius: control.maskRadius
                    opacity: 0.2
                    color: control.hovered ? control.Kirigami.Theme.highlightColor : "transparent"
                    
                    Kirigami.Icon
                    {
                        anchors.centerIn: parent
                        height: Math.min(22, parent.height * 0.4)
                        width: height
                        source: "folder-images"
                        isMask: true
                        color: parent.border.color
                        opacity: 1 - img.progress
                    }
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
                height: Math.min(parent.height, control.iconSizeHint)
                width: height
                color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                
                ColorOverlay
                {
                    visible: control.hovered
                    opacity: 0.3
                    anchors.fill: parent
                    source: parent
                    color: control.Kirigami.Theme.highlightColor
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
                Layout.fillHeight: true
                Layout.maximumHeight: control.imageSource ? control.imageSizeHint : control.iconSizeHint
                Layout.minimumHeight: control.imageSource ? control.imageSizeHint : control.iconSizeHint 
                
                Loader
                {
                    id: _iconLoader
                    anchors.fill: parent
                    sourceComponent: _iconContainer.visible ? (control.imageSource ? _imgComponent : (control.iconSource ?  _iconComponent : null) ): null                    

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
                
                Rectangle
                {
                    visible: !control.labelsVisible 
                    anchors.fill: parent
                    
                    Behavior on color
                    {
                        ColorAnimation
                        {
                            duration: Kirigami.Units.longDuration
                        }
                    }
                    
                    color: control.isCurrentItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : control.Kirigami.Theme.backgroundColor
                    
                    radius: Maui.Style.radiusV
                    border.width: 2
                    border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"                    
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
                    color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor                }
                
            }
        }
}
