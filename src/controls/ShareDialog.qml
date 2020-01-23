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
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
    id: control
    property var itemUrls : []

    widthHint: 0.9

    maxHeight: Math.max(_layout.contentHeight, maxWidth) + (page.padding * 2.5) + headBar.height
    maxWidth: Maui.Style.unit * 500

    verticalAlignment: Qt.AlignBottom

    defaultButtons: false

    page.title: qsTr("Share with")
    headBar.visible: true

    Kirigami.ScrollablePage
    {
        id: _layout
        anchors.fill: parent
        leftPadding: 0
        rightPadding: 0
        
        Maui.GridBrowser
        {
			id: grid
			width: parent.width
			showEmblem: false
			model: ListModel {}
			onItemClicked:
			{
				grid.currentIndex = index
				triggerService(index)
			}
		}
    }


    onOpened: populate()

    function show(urls)
    {
        if(urls.length > 0)
        {
            itemUrls = urls
            open()
        }
    }

    function populate()
    {
        grid.model.clear()
        var services = Maui.KDE.services(itemUrls[0])
        var devices = Maui.KDE.devices()

        grid.model.append({icon: "internet-mail", label: "Email", email: true})

        if(devices.length > 0)
            for(var i in devices)
            {
                devices[i].icon = "smartphone"
                grid.model.append(devices[i])

            }

        if(services.length > 0)
            for(i in services)
                grid.model.append(services[i])
    }

    function triggerService(index)
    {
        var obj = grid.model.get(index)

        if(obj.serviceKey)
            Maui.KDE.sendToDevice(obj.label, obj.serviceKey, itemUrls)
        else if(obj.email)
            Maui.KDE.attachEmail(itemUrls)
        else
            Maui.KDE.openWithApp(obj.actionArgument, itemUrls)

        close()
    }
}

