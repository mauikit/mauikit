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
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "private"

/**
 * SideBar
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.AbstractSideBar
{
    id: control

    position: 1
    visible: true

    /**
      * content : ColumnLayout.data
      */
    default property alias content : _content.data

    /**
      * model : var
      */
    property alias model : _listBrowser.model

    /**
      * count : int
      */
    property alias count : _listBrowser.count

    /**
      * section : ListView.section
      */
    property alias section : _listBrowser.section

    /**
      * currentIndex : int
      */
    property alias currentIndex: _listBrowser.currentIndex

    /**
     * 
     */
    property alias listView : _listBrowser

       /**
      * delegate : Component
      */
    property Component delegate : Maui.ListDelegate
    {
        id: itemDelegate
        iconSize: Maui.Style.iconSizes.small
        label: model.label
        count: model.count > 0 ? model.count : ""
        iconName: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
        iconVisible: true
        template.leftMargin: Maui.Style.space.medium

        onClicked:
        {
            control.currentIndex = index
            control.itemClicked(index)
        }

        onRightClicked:
        {
            control.currentIndex = index
            control.itemRightClicked(index)
        }

        onPressAndHold:
        {
            control.currentIndex = index
            control.itemRightClicked(index)
        }
    }

    /**
      * itemClicked :
      */
    signal itemClicked(int index)

    /**
      * itemRightClicked :
      */
    signal itemRightClicked(int index)


    ColumnLayout
    {
        id: _content
        anchors.fill: parent
        spacing: 0

        Maui.ListBrowser
        {
            id: _listBrowser
            Layout.fillHeight: true
            Layout.fillWidth: true

            verticalScrollBarPolicy: ScrollBar.AlwaysOff

            delegate: control.delegate

            onKeyPress:
            {
                if(event.key == Qt.Key_Return)
                {
                    control.itemClicked(control.currentIndex)
                }
            }
        }       
    }
}

