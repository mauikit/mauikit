
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

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.Dialog
{
    id: control

    defaultButtons: false
    persistent: false
    widthHint: 0.9
    heightHint: 0.8

    maxWidth: 350
    maxHeight: 250

    /**
      * mainHeader : AlternateListItem
      */
    property alias mainHeader : _header

    page.padding: 0
    actions: [
        Action
        {
            icon.name: "link"
            text: i18n("Site")
            onTriggered: Qt.openUrlExternally(Maui.App.about.homepage)
        },

        Action
        {
            icon.name: "love"
            text: i18n("Donate")
            onTriggered: Qt.openUrlExternally(Maui.App.donationPage)
        },

        Action
        {
            icon.name: "documentinfo"
            text: i18n("Report")
            onTriggered: Qt.openUrlExternally(Maui.App.about.bugAddress)
        }
    ]

    Maui.AlternateListItem
    {
        id: _header
        Layout.fillWidth: true
        implicitHeight: (_div1.height * 1.5) + Maui.Style.space.big
        alt: true

        Maui.ListItemTemplate
        {
            id: _div1

            width: parent.width 
            height: label2.implicitHeight + label1.implicitHeight
            anchors.centerIn: parent
            imageBorder: false
            imageSource: Maui.App.iconName
            imageWidth: Math.min(Maui.Style.iconSizes.huge, parent.width)
            imageHeight: imageWidth
            fillMode: Image.PreserveAspectFit
            imageSizeHint: imageWidth

            spacing: Maui.Style.space.big
            label1.wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            label1.text: Maui.App.about.displayName
            label1.font.weight: Font.Bold
            label1.font.bold: true
            label1.font.pointSize: Maui.Style.fontSizes.enormous * 1.3

            label2.text:  Maui.App.about.version + "\n" + Maui.App.about.shortDescription
            label2.elide: Text.ElideRight
            label2.wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        Layout.preferredHeight: _credits.implicitHeight + Maui.Style.space.huge
        alt: false

        Column
        {
            id: _credits
            spacing: Maui.Style.space.big
            width: parent.width
            anchors.centerIn: parent

            Repeater
            {
                model: Maui.App.about.authors
                Maui.ListItemTemplate
                {
                    id: _credits
                    iconSource: "view-media-artist"
                    iconSizeHint: Maui.Style.iconSizes.medium
                    width: parent.width
                    height: implicitHeight
                    spacing: Maui.Style.space.medium
                    label1.text: modelData.name
                    label2.text: String("<a href='mailto:%1'>%1</a>").arg(modelData.emailAddress)
                    label3.text: modelData.task
                    
                    Connections
                    {
                        target: _credits.label2
                        function onLinkActivated(link)
                        {
                            Qt.openUrlExternally(link)
                        }
                    }
                }
            }
        }
    }


    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        Layout.preferredHeight: _licenses.implicitHeight + Maui.Style.space.huge
        alt: true

        Column
        {
            id: _licenses
            spacing: Maui.Style.space.big
            width: parent.width
            anchors.centerIn: parent

            Repeater
            {
                model: Maui.App.about.licenses
                Maui.ListItemTemplate
                {
                    iconSource: "license"
                    width: parent.width
                    height: implicitHeight
                    iconSizeHint: Maui.Style.iconSizes.medium
                    spacing: Maui.Style.space.medium
                    label1.text: modelData.name
                }
            }
        }
    }

    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        Layout.preferredHeight: _poweredBy.implicitHeight + Maui.Style.space.huge
        alt: false

        Maui.ListItemTemplate
        {
            id: _poweredBy
            anchors.centerIn: parent
            width: parent.width

            iconSource: "code-context"
            iconSizeHint: Maui.Style.iconSizes.medium
            spacing: Maui.Style.space.medium
            label1.text: "Powered by"
            label2.text: "<a href='https://mauikit.org'>MauiKit</a> " + Maui.App.mauikitVersion
            Connections
            {
                target: _poweredBy.label2
                function onLinkActivated(link)
                {
                    Qt.openUrlExternally(link)
                }
            }
        }
    }


    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        Layout.preferredHeight: _libraries.implicitHeight + Maui.Style.space.huge
        alt: true

        Column
        {
            id: _libraries
            spacing: Maui.Style.space.big
            width: parent.width
            anchors.centerIn: parent

            Repeater
            {
                model: Kirigami.Settings.information
                Maui.ListItemTemplate
                {
                    iconSource: "plugins"
                    width: parent.width
                    height: implicitHeight
                    iconSizeHint: Maui.Style.iconSizes.medium
                    spacing: Maui.Style.space.medium
                    label1.text: modelData
                }
            }
        }
    }


    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        Layout.preferredHeight: _copyRight.implicitHeight + Maui.Style.space.huge
        alt: false
        lastOne: true

        Maui.ListItemTemplate
        {
            id: _copyRight
            anchors.centerIn: parent
            width: parent.width

            iconSizeHint: Maui.Style.iconSizes.medium
            spacing: Maui.Style.space.medium
            label1.text: Maui.App.about.copyrightStatement
            label1.horizontalAlignment: Qt.AlignHCenter
        }
    }
}
