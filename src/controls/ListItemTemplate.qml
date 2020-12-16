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

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui

/**
 * ListItemTemplate
 * A global sidebar for the application window that can be collapsed.
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

    implicitHeight: _layout.implicitHeight

    /**
      * text1 : string
      */
    property alias text1 : _label1.text

    /**
      * text2 : string
      */
    property alias text2 : _label2.text

    /**
      * text3 : string
      */
    property alias text3 : _label3.text

    /**
      * text4 : string
      */
    property alias text4 : _label4.text

    /**
      * label1 : Label
      */
    property alias label1 : _label1

    /**
      * label2 : Label
      */
    property alias label2 : _label2

    /**
      * label3 : Label
      */
    property alias label3 : _label3

    /**
      * label4 : Label
      */
    property alias label4 : _label4

    /**
      * iconItem : Item
      */
    property alias iconItem : _iconLoader.item

    /**
      * iconVisible : bool
      */
    property alias iconVisible : _iconContainer.visible

    /**
      * leftLabels : ColumnLayout
      */
    property alias leftLabels : _leftLabels

    /**
      * rightLabels : ColumnLayout
      */
    property alias rightLabels : _rightLabels

    /**
      * spacing : int
      */
    property alias spacing : _layout.spacing

    /**
      * layout : RowLayout
      */
    property alias layout : _layout

    /**
      * background : Rectangle
      */
    property alias background : _background

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
      * hovered : bool
      */
    property bool hovered : false

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

    /**
      * margins : int
      */
    property int margins: 0

    /**
      * rightMargin : int
      */
    property int rightMargin: Maui.Style.space.medium

    /**
      * leftMargin : int
      */
    property int leftMargin: Maui.Style.space.medium

    /**
      * topMargin : int
      */
    property int topMargin: margins

    /**
      * bottomMargin : int
      */
    property int bottomMargin: margins

    /**
      * iconComponent : Component
      */
    property Component iconComponent :  _iconContainer.visible ? _iconComponent : null

    /**
      * toggled
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

    Rectangle
    {
        id: _background
        visible: false
        anchors.fill: parent
    }

    RowLayout
    {
        id: _layout
        anchors.fill: parent
        anchors.margins: control.margins
        anchors.leftMargin: control.leftMargin
        anchors.rightMargin: control.rightMargin
        anchors.topMargin: control.topMargin
        anchors.bottomMargin: control.bottomMargin

        spacing: Maui.Style.space.small

        Item
        {
            Layout.preferredHeight: _emblem.height
            visible: _emblem.visible
        }

        Maui.Badge
        {
            id: _emblem

            visible: control.checkable || control.checked

            size: Math.min(Maui.Style.iconSizes.medium, _layout.height)

            color: control.checked ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)

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
        
        Item
        {
            id: _iconContainer
            visible: (control.width > Kirigami.Units.gridUnit * 10) && (iconSource.length > 0 || imageSource.length > 0)
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.fillWidth: !control.labelsVisible
            Layout.preferredWidth: Math.max(control.iconSizeHint, control.imageSizeHint) + Maui.Style.space.medium

            Layout.preferredHeight: Math.max(control.iconSizeHint, control.imageSizeHint) + Maui.Style.space.medium

            Loader
            {
                id: _iconLoader
                anchors.centerIn: parent

                width: Math.min(parent.height, Math.max(control.iconSizeHint, control.imageSizeHint))

                height: width

                sourceComponent: control.iconComponent
            }
        }

        ColumnLayout
        {
            id: _leftLabels
            visible: control.labelsVisible
            Layout.fillHeight: true
            Layout.fillWidth: true
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
            }
        }

        ColumnLayout
        {
            id: _rightLabels
            visible: control.width >  Kirigami.Units.gridUnit * 15 && control.labelsVisible && control.height > 32
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
                verticalAlignment: _label4.visible ? Qt.AlignBottom :  Qt.AlignVCenter

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
                verticalAlignment: _label3.visible ? Qt.AlignTop : Qt.AlignVCenter

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
