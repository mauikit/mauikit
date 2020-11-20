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

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.kde.purpose 1.0 as Purpose

Maui.Dialog
{
    id: control

    /**
      *
      */
    property var urls : []

    /**
      *
      */
    property string mimeType

    widthHint: 0.9

    maxHeight: 500
    maxWidth: 500
    page.margins: 0

    verticalAlignment: Qt.AlignBottom

    defaultButtons: true

    rejectButton.visible: false
    acceptButton.text: i18n("Open with")
    onAccepted:  control.openWith()

    page.title: i18n("Share with")
    headBar.visible: true

    headBar.leftContent: ToolButton
    {
        visible: _purpose.depth>1;
        icon.name: "go-previous"
        onClicked: _purpose.pop()
    }

    Maui.OpenWithDialog
    {
        id: _openWithDialog
        urls: control.urls
    }

    stack: Purpose.AlternativesView
    {
        id: _purpose
        Layout.fillWidth: true
        Layout.fillHeight: true
        pluginType: 'Export'
        clip: true

        inputData :
        {
            'urls': [control.urls[0]],
            'mimeType':control.mimeType
        }

        delegate: Maui.AlternateListItem
        {
            width: ListView.view.width
            height: Maui.Style.rowHeight * 2

            Maui.ListItemTemplate
            {
                anchors.fill: parent

                label1.text: model.display
                iconSource: model.iconName
                iconSizeHint: Maui.Style.iconSizes.big
            }

            onClicked: _purpose.createJob(index)
        }
    }

    /**
     *
     */
    function openWith()
    {
        _openWithDialog.open()
        control.close()
    }
}

