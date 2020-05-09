
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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{
    id: control
    
    defaultButtons: false
    widthHint: 0.9
    heightHint: 0.8

    maxWidth: Maui.Style.unit * 400
    maxHeight: Maui.Style.unit * 250

    page.padding: 0
    footBar.visible: true
    footBar.middleContent: ToolButton
    {
        icon.name: "link"
        visible: true
        onClicked: Qt.openUrlExternally(Maui.App.webPage)
    }

    footBar.rightContent: ToolButton
    {
        icon.name: "love"
        onClicked: Qt.openUrlExternally(Maui.App.donationPage)
    }

    footBar.leftContent: ToolButton
    {
        icon.name: "documentinfo"
        onClicked: Qt.openUrlExternally(Maui.App.reportPage)
    }

    RowLayout
    {
        id: layout
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Maui.Style.space.medium

        Item
        {
            visible:  parent.width > control.maxWidth * 0.7
            Layout.fillHeight: true
            Layout.margins: Maui.Style.space.medium
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Maui.Style.iconSizes.huge + Maui.Style.space.big

            Image
            {
                id: _imgIcon
                anchors.centerIn: parent
                source: Maui.App.iconName
                width: Math.min(Maui.Style.iconSizes.huge, parent.width)
                height: width
                sourceSize.width: width
                sourceSize.height: height
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }

            DropShadow
            {
                anchors.fill: _imgIcon
                horizontalOffset: 0
                verticalOffset: 0
                radius: 8.0
                samples: 17
                color: "#80000000"
                source: _imgIcon
            }
        }

        Kirigami.ScrollablePage
        {
            id: _descriptionItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Kirigami.Theme.backgroundColor: "transparent"
			padding: Maui.Style.space.medium
            leftPadding: padding
            rightPadding: padding
            topPadding: padding*3
            bottomPadding: padding

            ColumnLayout
            {
                id: _columnInfo
                width: parent.width
                spacing: Maui.Style.space.medium
                
                Label
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    color: Kirigami.Theme.textColor
                    text: Maui.App.displayName
                    font.weight: Font.Bold
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.enormous * 1.3
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    color:  Qt.lighter(Kirigami.Theme.textColor, 1.2)
                    text: Maui.App.version
                    font.weight: Font.Light
                    font.pointSize: Maui.Style.fontSizes.default
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Label
                {
                    id: body
                    Layout.fillWidth: true
                    text:  Maui.App.description
                    color: Kirigami.Theme.textColor
                    font.pointSize: Maui.Style.fontSizes.default
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Label
                {
                    color: Kirigami.Theme.textColor
                    Layout.fillWidth: true
                    text: qsTr("By ") + Maui.App.org
                    font.pointSize: Maui.Style.fontSizes.default
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
               
                Kirigami.Separator
                {
                    Layout.fillWidth: true
                    Layout.margins: Maui.Style.space.tiny
                    opacity: 0.4
                }
                
                Label
                {
                    visible: _creditsRepeater.count > 0
                    color: Kirigami.Theme.textColor
                    Layout.fillWidth: true
                    text: qsTr("Credits")
                    font.pointSize: Maui.Style.fontSizes.default
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                
                Repeater
                {
                    id: _creditsRepeater
                    model: Maui.App.credits
                    
                    Column
                    {
                        Label
                        {
                            color: Kirigami.Theme.textColor
                            Layout.fillWidth: true
                            text: modelData.name
                            font.pointSize: Maui.Style.fontSizes.default
                            elide: Text.ElideRight
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }  
                        
                        Label
                        {
                            color: Kirigami.Theme.textColor
                            Layout.fillWidth: true
                            text: modelData.email
                            font.pointSize: Maui.Style.fontSizes.default
                            elide: Text.ElideRight
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                        
                        Label
                        {
                            color: Kirigami.Theme.textColor
                            Layout.fillWidth: true
                            text: modelData.year
                            font.pointSize: Maui.Style.fontSizes.default
                            elide: Text.ElideRight
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                    }                    
                }
                
                Kirigami.Separator
                {
                    Layout.fillWidth: true
                    Layout.margins: Maui.Style.space.tiny
                    opacity: 0.4
                }
                
                Label
                {
                    color: Kirigami.Theme.textColor
                    Layout.fillWidth: true
                    
                    text: qsTr("Powered by") + " <a href='https://mauikit.org'>MauiKit</a> " +
                    Maui.App.mauikitVersion + " and  <a href='https://kde.org/products/kirigami'>Kirigami</a>"
                    font.pointSize: Maui.Style.fontSizes.default
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                
            }
        }
    }
}
