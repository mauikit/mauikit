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

import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

Rectangle
{
    id: control
    
    color: "transparent"
    
    /**
     * iconSizeHint : int
     */
    property bool highlighted: false
    
    /**
     * iconSizeHint : int
     */
    property bool hovered: false
    
    /**
     * iconSizeHint : int
     */
    property int iconSizeHint : Maui.Style.iconSizes.big
    
    /**
     * imageSizeHint : int
     */
    property int imageSizeHint : iconSizeHint
    
    /**
     * imageWidth : int
     */
    property int imageWidth : imageSizeHint
    
    /**
     * imageHeight : int
     */
    property int imageHeight : imageSizeHint
    
    /**
     * imageSource : string
     */
    property string imageSource
    
    /**
     * iconSource : string
     */
    property string iconSource
    
    /**
     * fillMode : Image.fillMode
     */
    property int fillMode : Image.PreserveAspectCrop
    
    /**
     * maskRadius : int
     */
    property int maskRadius: Maui.Style.radiusV
    
    /**
     * imageBorder : bool
     */
    property bool imageBorder: true
    
    
    Loader
    {
        anchors.fill: parent
        
        sourceComponent: control.imageSource ? _imgComponent : (control.iconSource ?  _iconComponent : null)   
        
        Component
        {
            id: _imgComponent
            
            Item
            {
                height: parent.height
                width: parent.width
                
                Image
                {
                    id: img
                    anchors.fill: parent
                    source: control.imageSource

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
                }
                
                Rectangle
                {
                    Kirigami.Theme.inherit: false
                    visible: control.imageBorder
                    anchors.centerIn: parent
                    
                    width: img.status === Image.Ready ? Math.min(parent.width, img.paintedWidth) : parent.width
                    height:  img.status === Image.Ready ? Math.min(parent.height, img.paintedHeight) : parent.height
                    border.color: control.highlighted ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 2.2)
                    radius: control.maskRadius
                    
                    border.width: control.highlighted ? 2 : 1
                    color: "transparent"
                    opacity: 0.8
                    
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
                    visible: img.status !== Image.Ready
                    anchors.centerIn: parent
                    height: Math.min(22, Math.floor( parent.height * 0.7))
                    width: height
                    source: "folder-images"
                    isMask: true
                    color: Kirigami.Theme.textColor
                    opacity: 0.5
                }
                
                ColorOverlay
                {
                    anchors.fill: parent
                    
                    visible: control.hovered || control.checked ||control.highlighted
                    opacity: 0.3
                    
                    source: parent
                    color: control.hovered || control.highlighted  ? control.Kirigami.Theme.highlightColor : "#000"
                }
            }  
        }
        
        Component
        {
            id: _iconComponent
            
            Item
            {
                Kirigami.Icon
                {
                    source: control.iconSource
                    anchors.centerIn: parent
                    fallback: "qrc:/assets/application-x-zerosize.svg"
                    height: Math.floor(Math.min(parent.height, control.iconSizeHint))
                    width: height
                    color: control.highlighted ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                    
                    ColorOverlay
                    {
                        visible: control.hovered
                        opacity: 0.3
                        anchors.fill: parent
                        source: parent
                        color: control.hovered ? control.Kirigami.Theme.highlightColor : "#000"
                    }
                }
            }
        }        
    }
}
