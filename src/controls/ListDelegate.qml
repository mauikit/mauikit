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
import org.kde.mauikit 1.2 as Maui

/**
 * ListDelegate
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.ItemDelegate
{
    id: control

    /**
      * labelVisible : bool
      */
    property bool labelVisible : true

    /**
      * iconSize : int
      */
    property alias iconSize : _template.iconSizeHint

    /**
      * iconVisible : int
      */
    property alias iconVisible : _template.iconVisible

    /**
      * label : string
      */
    property alias label: _template.text1

    /**
      * label2 : string
      */
    property alias label2: _template.text2

    /**
      * iconName : string
      */
    property alias iconName: _template.iconSource

    /**
      * count : int
      */
    property alias count : _badge.text

    /**
      * template : ListItemTemplate
      */
    property alias template : _template

    implicitHeight: Math.floor(Math.max(control.iconSize + Maui.Style.space.tiny, Maui.Style.rowHeight))

    isCurrentItem : ListView.isCurrentItem

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: hovered
    ToolTip.text: qsTr(control.label)

    Maui.ListItemTemplate
    {
        id: _template
        anchors.fill: parent
        labelsVisible: control.labelVisible
        hovered: parent.hovered
        isCurrentItem: control.isCurrentItem

        Maui.Badge
        {
            id: _badge
            text: control.count
            visible: control.count.length > 0 && control.labelVisible
        }
    }

    /**
      *
      */
    function clearCount()
    {
        console.log("CLEANING SIDEBAR COUNT")
        control.count = ""
    }
}
