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
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

/**
 * SwipeBrowserDelegate
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.SwipeItemDelegate
{
    id: control

    /**
      * label1 : Label
      */
    property alias label1 : _template.label1

    /**
      * label2 : Label
      */
    property alias label2 : _template.label2

    /**
      * label3 : Label
      */
    property alias label3 : _template.label3

    /**
      * label4 : Label
      */
    property alias label4 : _template.label4

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
      * imageSource: string
      */
    property alias imageSource : _template.imageSource

    /**
      * iconSource : string
      */
    property alias iconSource : _template.iconSource

    /**
      * template : ListItemTemplate
      */
    property alias template : _template

    Maui.ListItemTemplate
    {
        id: _template
        anchors.fill: parent
    }
}
