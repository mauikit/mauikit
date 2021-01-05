/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2020  camilo <chiguitar@unal.edu.co>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

/**
 * OpenWithDialog
 * A dialog with a list of services associated to the list of URLs.
 *
 * The services listed can open the file type of the file URLs.
 *
 *
 *
 *
 */
Maui.Dialog
{
    id: control

    /**
      * urls : var
      * List of file URLs to look for associated services.
      */
    property var urls : []

    widthHint: 0.9
    page.padding: 0
    maxHeight: _list.contentHeight + (page.padding * 2.5) + headBar.height + Maui.Style.space.huge
    maxWidth: 500

    verticalAlignment: Qt.AlignBottom

    defaultButtons: false

    page.title: i18n("Open with")
    headBar.visible: true

    stack: Maui.ListBrowser
    {
        id: _list
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0
        margins: 0
        model: ListModel {}

        delegate: Maui.AlternateListItem
        {
            width: ListView.view.width
            height: Maui.Style.rowHeight * 2

            Maui.ListItemTemplate
            {
                isCurrentItem: parent.hovered
                anchors.fill: parent
                label1.text: model.label
                label2.text: model.comment
                iconSource: model.icon
                iconSizeHint: Maui.Style.iconSizes.big
            }

            onClicked:
            {
                _list.currentIndex = index
                triggerService(index)
            }
        }
    }

    onOpened: populate()

    /**
      *
      */
    function populate()
    {
        if(urls.length > 0)
        {
            _list.model.clear()
            var services = Maui.KDE.services(control.urls[0])

            for(var i in services)
            {
                _list.model.append(services[i])
            }
        }
    }

    /**
      *
      */
    function triggerService(index)
    {
        const obj = _list.model.get(index)
        Maui.KDE.openWithApp(obj.actionArgument, control.urls)
        close()
    }
}
