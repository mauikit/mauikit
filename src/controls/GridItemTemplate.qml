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

Item
{
    id: control

    default property alias content: _layout.data

//     implicitHeight: _layout.implicitHeight
    implicitWidth: _layout.implicitWidth

    property alias text1 : _label1.text

    property alias label1 : _label1
    property alias iconItem : _iconLoader.item
    property alias iconVisible : _iconContainer.visible
    property int iconSizeHint : Maui.Style.iconSizes.big
    property string imageSource
    property string iconSource
    
    property alias emblem : _emblem

    property bool isCurrentItem: false
    property bool labelsVisible: true

    property int fillMode :Image.PreserveAspectCrop

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
            sourceSize.width: width
            sourceSize.height: height
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            fillMode: control.fillMode
            cache: true
            asynchronous: true
            smooth: true

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

        Kirigami.Icon
        {
            anchors.centerIn: parent
            source: control.iconSource
            fallback: "qrc:/assets/application-x-zerosize.svg"
            height: Math.min(parent.height, control.iconSizeHint)
            width: height
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

            Loader
            {
                id: _iconLoader
                height: Math.min(control.iconSizeHint, parent.height)
                width: control.iconSizeHint
                anchors.centerIn: parent
                sourceComponent: _iconContainer.visible ? (control.imageSource ? _imgComponent : (control.iconSource ?  _iconComponent : null) ): null
                
                Maui.Badge
                {
                    id: _emblem
                    
                    size: Maui.Style.iconSizes.medium        
                    anchors.margins: Maui.Style.space.medium
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    border.color: Kirigami.Theme.textColor                    
                } 
                
                DropShadow
                {
                    anchors.fill: _emblem
                    visible: _emblem.visible
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 8.0
                    samples: 17
                    color: "#80000000"
                    source: _emblem
                }
            }
        }
        
        Label
        {
            id: _label1
            visible: control.labelsVisible
            Layout.margins: Maui.Style.space.tiny
            Layout.preferredHeight: Math.min(implicitHeight + Maui.Style.space.medium, parent.height * 0.3)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
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
                
                radius: Maui.Style.radiusV
                border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"
            }
        }
    }
}
