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
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

/**
 * GridBrowser
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.GridView // TODO remove
{
    id: control

    itemSize : Maui.Style.iconSizes.large * 2
    adaptContent: true

    /**
      * checkable :
      */
    property bool checkable : false

    /**
      * itemClicked :
      */
    signal itemClicked(int index)

    /**
      * itemDoubleClicked :
      */
    signal itemDoubleClicked(int index)

    /**
      * itemToggled :
      */
    signal itemToggled(int index, bool state)

    /**
      *
      */
    signal itemRightClicked(int index)
}
