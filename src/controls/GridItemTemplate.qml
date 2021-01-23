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
import org.kde.mauikit 1.3 as Maui

/**
 * GridItemTemplate
 * A template with a icon or image and a bottom label..
 *
 *
 *
 *
 *
 *
 */
Item
{
    id: control

    /**
      * content : data
      */
    default property alias content: _layout.data

    /**
      * text1 : string
      */
    property alias text1 : _label1.text

    /**
      * label1 : Label
      */
    property alias label1 : _label1

    /**
      * iconItem : Item
      */
    property alias iconItem : _iconLoader.item

    /**
      * iconVisible : bool
      */
    property alias iconVisible : _iconContainer.visible

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
    property int imageWidth : iconSizeHint

    /**
      * imageHeight : int
      */
    property int imageHeight : iconSizeHint

    /**
      * imageSource : string
      */
    property string imageSource

    /**
      * iconSource : string
      */
    property string iconSource

    /**
      * checkable : bool
      */
    property bool checkable : false

    /**
      * checked : bool
      */
    property bool checked : false

    /**
      * isCurrentItem : bool
      */
    property bool isCurrentItem: false

    /**
      * labelsVisible : bool
      */
    property bool labelsVisible: true

    /**
      * fillMode : Image.fillMode
      */
    property int fillMode : Image.PreserveAspectCrop

    /**
      * maskRadius : int
      */
    property int maskRadius: Maui.Style.radiusV

    /**
      * hovered : bool
      */
    property bool hovered: false

    /**
      * imageBorder : bool
      */
    property bool imageBorder: true

     /**
      * iconComponent : Component
      */
    property Component iconComponent :  _iconContainer.visible ? _iconComponent : null


    /**
      * toggled :
      */
    signal toggled(bool state)

    Component
    {
        id: _iconComponent
        
        Maui.IconItem
        {
            iconSource: control.iconSource
            imageSource: control.imageSource
            
            highlighted: control.isCurrentItem
            hovered: control.hovered
            
            iconSizeHint: control.iconSizeHint
            imageSizeHint: control.imageSizeHint
            
            imageWidth: control.imageWidth
            imageHeight: control.imageHeight
            
            fillMode: control.fillMode
            maskRadius: control.maskRadius
            imageBorder: control.imageBorder
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
                sourceComponent: control.iconComponent

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

                    Maui.CheckMark
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
            visible: control.labelsVisible && _label1.text
            Layout.fillHeight: true
            Layout.preferredHeight: Math.min(_label1.implicitHeight, height)
            Layout.fillWidth: true

            Rectangle
            {
                width: parent.width
                height: Math.min(_label1.implicitHeight + Maui.Style.space.tiny, parent.height)
                anchors.centerIn: parent
                Behavior on color
                {
                    ColorAnimation
                    {
                        duration: Kirigami.Units.longDuration
                    }
                }

                color: control.isCurrentItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9))

                radius: Maui.Style.radiusV
                border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"
            }

            Label
            {
                id: _label1
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                anchors.fill: parent
                anchors.margins: Maui.Style.space.tiny
                elide: Qt.ElideRight
                wrapMode: Text.Wrap
                color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
            }
        }
    }
}
