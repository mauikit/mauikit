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

    implicitHeight: Maui.Style.rowHeight
//     implicitWidth: _layout.implicitWidth

    property alias text1 : _label1.text
    property alias text2 : _label2.text
    property alias text3 : _label3.text
    property alias text4 : _label4.text
    
    property alias label1 : _label1
    property alias label2 : _label2
    property alias label3 : _label3
    property alias label4 : _label4
    property alias iconItem : _iconLoader.item
    property alias iconVisible : _iconContainer.visible
    
    property alias leftLabels : _leftLabels
    property alias rightLabels : _rightLabels
    
    property int iconSizeHint : Maui.Style.iconSizes.big
    property int imageSizeHint : iconSizeHint
    
    property int imageWidth : imageSizeHint
    property int imageHeight : imageSizeHint
    
    property string imageSource
    property string iconSource    
    
    property bool checkable : false
    property bool checked : false
    
    property bool isCurrentItem: false
    property bool labelsVisible: true
    property bool hovered : false
    
    property int fillMode : Image.PreserveAspectCrop
    property int maskRadius: Maui.Style.radiusV
        
    signal toggled(bool state)
    
    Component
    {
        id: _imgComponent

        Image
        {
            id: img
            anchors.centerIn: parent
            source: control.imageSource
            height: Math.min(parent.height, control.imageSizeHint)
            width: height
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
                    height: Math.min(22, parent.height * 0.7)
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

        Item
        {
            Kirigami.Icon
            {
                source: control.iconSource
                anchors.centerIn: parent
                fallback: "qrc:/assets/application-x-zerosize.svg"
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
    }

    RowLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: Maui.Style.space.tiny
        
        Item
        {
            id: _checkBoxContainer
            visible: control.checkable || control.checked
            
            Layout.fillHeight: true
            Layout.preferredWidth: _emblem.size * 2
            
            Maui.Badge
            {
                id: _emblem
                
                size: Math.min(Maui.Style.iconSizes.medium, parent.height)
                
                anchors.centerIn: parent
                
                color: control.checked ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)
                
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
        }      

        Item
        {
            id: _iconContainer
            visible: (control.width > Kirigami.Units.gridUnit * 10) && (iconSource.length > 0 || imageSource.length > 0)
            Layout.fillHeight: true
            Layout.fillWidth: !control.labelsVisible
            Layout.leftMargin: _checkBoxContainer.visible ? 0 : Maui.Style.space.tiny
            Layout.preferredWidth: Math.min(parent.height, Math.max(control.iconSizeHint, imageSizeHint) + Maui.Style.space.medium)  
            
            Loader
            {                
                id: _iconLoader
                width: Math.min(parent.height, Math.max(control.iconSizeHint, imageSizeHint) )           
                height: width
                anchors.centerIn: parent
                sourceComponent: _iconContainer.visible ? (control.imageSource ? _imgComponent : (control.iconSource ?  _iconComponent : null) ): null
            }
        }

        ColumnLayout
        {
            id: _leftLabels
            visible: control.labelsVisible
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.tiny 
            Layout.leftMargin: _iconContainer.visible || _checkBoxContainer.visible ? 0 : Maui.Style.space.small
            spacing: 0

            Label
            {
                id: _label1
                visible: text.length
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: _label2.visible ? Qt.AlignBottom :  Qt.AlignVCenter

                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.default
            }

            Label
            {
                id: _label2
                visible: text.length
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: _label1.visible ? Qt.AlignTop : Qt.AlignVCenter
                
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                
                color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                opacity: control.isCurrentItem ? 0.8 : 0.6
                
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.medium
            }
        }

        ColumnLayout
        {
            id: _rightLabels
			visible: control.width >  Kirigami.Units.gridUnit * 15 && control.labelsVisible
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.tiny 
            spacing: 0

            Label
            {
                id: _label3
                visible: text.length > 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Qt.AlignRight
                font.pointSize: Maui.Style.fontSizes.small
                font.weight: Font.Light
                wrapMode: Text.NoWrap
                elide: Text.ElideMiddle
                color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                opacity: control.isCurrentItem ? 0.8 : 0.6
            }

            Label
            {
                id: _label4
                visible: text.length > 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Qt.AlignRight
                font.pointSize: Maui.Style.fontSizes.small
                font.weight: Font.Light
                wrapMode: Text.NoWrap
                elide: Text.ElideMiddle
                color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                opacity: control.isCurrentItem ? 0.8 : 0.6
            }
        }
    }

}
