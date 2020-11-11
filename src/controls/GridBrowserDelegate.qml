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

/**
 * GridBrowserDelegate
 * A GridItemTemplate wrapped into a ItemDelegate to make it clickable and draggable.
 *
 * For more details check the ItemDelegate and GridItemTemplate documentation.
 *
 * This mix adds a drop area, tooltip information and a custom styling.
 *
 *
 */
Maui.ItemDelegate
{
    id: control

    isCurrentItem : GridView.isCurrentItem || checked

    /**
      * tooltipText : string
      */
    property string tooltipText

    /**
      * template : GridItemTemplate
      */
    property alias template : _template

    /**
      * label1 : Label
      */
    property alias label1 : _template.label1

    /**
      * iconItem : Item
      */
    property alias iconItem : _template.iconItem

    /**
      * iconVisible : bool
      */
    property alias iconVisible : _template.iconVisible

    /**
      * iconSizeHint : int
      */
    property alias iconSizeHint : _template.iconSizeHint

    /**
      * imageSizeHint : int
      */
    property alias imageSizeHint : _template.imageSizeHint

    /**
      * imageSource : string
      */
    property alias imageSource : _template.imageSource

    /**
      * iconSource : string
      */
    property alias iconSource : _template.iconSource

    /**
      * showLabel : bool
      */
    property alias showLabel : _template.labelsVisible

    /**
      * checked : bool
      */
    property alias checked : _template.checked

    /**
      * checkable : bool
      */
    property alias checkable: _template.checkable

    /**
      * dropArea : DropArea
      */
    property alias dropArea : _dropArea

    /**
      * contentDropped :
      */
    signal contentDropped(var drop)

    /**
      * toggled :
      */
    signal toggled(bool state)

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered && control.tooltipText
    ToolTip.text: control.tooltipText

    background: Item {}

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        enabled: control.draggable

        onDropped:
        {
            control.contentDropped(drop)
        }
    }

    Maui.GridItemTemplate
    {
        id: _template
        anchors.fill: parent

        hovered: control.hovered || control.containsPress || _dropArea.containsDrag
        checkable : control.checkable
        checked : control.checked
//        label1.elide: Text.ElideMiddle // TODO this is broken ???
        isCurrentItem: control.isCurrentItem
        onToggled: control.toggled(state)
    }
}
