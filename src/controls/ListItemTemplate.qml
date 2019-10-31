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

    property alias label1 : _label1
    property alias label2 : _label2
    property alias label3 : _label3
    property alias label4 : _label4
    property alias iconItem : _iconLoader.item
    property alias iconVisible : _iconContainer.visible
    property int iconSizeHint : Maui.Style.iconSizes.big
    property string imageSource
    property string iconSource
    
    property bool isCurrentItem: false

    Component
    {
        id: _imgComponent

        Item
        {
            anchors.fill: parent
            
            Image
            {
                id: img
                anchors.centerIn: parent
                source: control.imageSource
                height: Math.min(parent.height, control.iconSizeHint)
                width: height
                sourceSize.width: width
                sourceSize.height: height
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                fillMode: Image.PreserveAspectCrop
                cache: false
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

            Loader
            {
                anchors.centerIn: parent
                sourceComponent: img.status === Image.Ready ? undefined : _iconComponent
            }
        }
    }


    Component
    {
        id: _iconComponent

        Kirigami.Icon
        {
            source: control.iconSource
            anchors.centerIn: parent
            fallback: "qrc:/assets/application-x-zerosize.svg"
            height: Math.min(parent.height, control.iconSizeHint)
            width: height
        }
    }


    RowLayout
    {
        id: _layout
        anchors.fill: parent

        spacing: Maui.Style.space.small

        Item
        {
            id: _iconContainer
            visible: (control.width > Kirigami.Units.gridUnit * 15)
            Layout.preferredWidth: Math.max(control.height, control.iconSizeHint)
            Layout.fillHeight: true

            Loader
            {
                id: _iconLoader
                height: control.iconSizeHint
                width: control.iconSizeHint
                anchors.centerIn: parent
                sourceComponent: _iconContainer.visible ? (control.imageSource ? _imgComponent : (control.iconSource ?  _iconComponent : null) ): null
            }
        }


        ColumnLayout
        {
            Layout.fillHeight: visible
            Layout.fillWidth: visible
            Layout.margins: Maui.Style.space.small

            Label
            {
                id: _label1
                visible: text.length
                Layout.fillWidth: visible
                Layout.fillHeight: visible
                verticalAlignment: _label2.visible ? Qt.AlignBottom :  Qt.AlignVCenter

                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                color: control.Kirigami.Theme.textColor
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.default
            }

            Label
            {
                id: _label2
                visible: text.length
                Layout.fillWidth: visible
                Layout.fillHeight: visible
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.medium
                wrapMode: Text.NoWrap
                verticalAlignment: _label1.visible ? Qt.AlignTop : Qt.AlignVCenter
                elide: Text.ElideRight
                color: control.Kirigami.Theme.textColor
                opacity: control.isCurrentItem || hovered ? 0.8 : 0.6
            }
        }

        ColumnLayout
        {
            visible: control.width >  Kirigami.Units.gridUnit * 15
            Layout.fillHeight: visible
            Layout.fillWidth: visible
            Layout.margins: Maui.Style.space.small

            Label
            {
                id: _label3
                visible: text.length > 0
                Layout.fillHeight: visible
                Layout.fillWidth: visible
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Qt.AlignRight
                font.pointSize: Maui.Style.fontSizes.small
                font.weight: Font.Light
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideMiddle
                color: control.Kirigami.Theme.textColor
                opacity: control.isCurrentItem || hovered ? 0.8 : 0.6
			}

            Label
            {
                id: _label4
                visible: text.length > 0
                Layout.fillHeight: visible
                Layout.fillWidth: visible
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Qt.AlignRight
                font.pointSize: Maui.Style.fontSizes.small
                font.weight: Font.Light
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideMiddle
                color: control.Kirigami.Theme.textColor
                opacity: control.isCurrentItem || hovered ? 0.8 : 0.6
			}
        }
    }

}
