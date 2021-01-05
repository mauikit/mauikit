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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

/**
 * ActionSideBar
 * A global sidebar for the application window that can be collapsed.
 *
 * The ActionSideBar is hanlded by a ListView, by default you would only need to declare
 * a list of Actions and those will be used as the model to populate the ListView.
 *
 * By default the Actions delegate is a ListDelegate, you can use any other component.
 * For reference on how the collapsed sidebar is implemented for the delegate check
 * the default implementation as an exmaple.
 */
Maui.SideBar
{
    id: control
    interactive: !collapsible

    /**
      * actions : list<Action>
      * List of actions to be used to populate the ListView.
      * This is the default property, so declaring the actions is staright forward.
      *
      */
    default property list<Action> actions

    model: control.actions
    delegate: Maui.ListDelegate
    {
        id: itemDelegate
        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
        Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor

        readonly property QtObject action : modelData
        // 					action : modelData
        iconName: action.icon.name
        label: action.text
        leftPadding:  Maui.Style.space.tiny
        rightPadding:  Maui.Style.space.tiny

        Connections
        {
            target: itemDelegate
            onClicked:
            {
                control.currentIndex = index
                target.action.triggered()
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
    }
}

