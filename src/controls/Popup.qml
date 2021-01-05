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
import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.2 as Maui

import QtGraphicalEffects 1.0

/**
 * Popup
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Popup
{
    id: control

    /**
      * content : Item.data
      */
    default property alias content : _content.data

    /**
      * maxWidth : int
      */
    property int maxWidth : parent.width

    /**
      * maxHeight : int
      */
    property int maxHeight : parent.height

    /**
      * hint : double
      */
    property double hint : 0.9

    /**
      * heightHint : double
      */
    property double heightHint : hint

    /**
      * widthHint : double
      */
    property double widthHint : hint

    /**
      * verticalAlignment : int
      */
    property int verticalAlignment : Qt.AlignVCenter

    parent: ApplicationWindow.overlay

    width: Math.round(Math.max(Math.min(parent.width * widthHint, maxWidth), Math.min(maxWidth, parent.width * widthHint)))
    height: Math.round(Math.max(Math.min(parent.height * heightHint, maxHeight), Math.min(maxHeight, parent.height * heightHint)))

    x: Math.round( parent.width / 2 - width / 2 )
    y: Math.round( positionY() )

    /**
      *
      */
    function positionY()
    {
        if(verticalAlignment === Qt.AlignVCenter)
        {
            return parent.height / 2 - height / 2
        }
        else if(verticalAlignment === Qt.AlignTop)
        {
            return (height + Maui.Style.space.huge)
        }
        else if(verticalAlignment === Qt.AlignBottom)
        {
            return (parent.height) - (height + Maui.Style.space.huge)

        }else
        {
            return parent.height / 2 - height / 2
        }
    }

    modal: control.width !== control.parent.width && control.height !== control.parent.height

    margins: 1
    padding: 1

    //     topPadding: popupBackground.radius
    //     bottomPadding: popupBackground.radius
    topPadding: control.padding
    bottomPadding: control.padding
    leftPadding: control.padding
    rightPadding: control.padding

    rightMargin: control.margins
    leftMargin: control.margins
    topMargin: control.margins
    bottomMargin: control.margins

    enter: Transition
    {
        // grow_fade_in
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    exit: Transition
    {
        // shrink_fade_out
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    contentItem: null

    Item
    {
        id: _content
        anchors.fill: parent
        layer.enabled: true
        layer.effect: OpacityMask
        {
            cached: true
            maskSource: Item
            {
                width: _content.width
                height: _content.height

                Rectangle
                {
                    anchors.fill: parent
                    radius: Maui.Style.radiusV
                }
            }
        }
    }

    Rectangle
    {
        anchors.fill: parent
        color: "transparent"
        radius: Maui.Style.radiusV - 0.5
        border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
        opacity: 0.6
    }

    background: Rectangle
    {
        color: Kirigami.Theme.backgroundColor
        opacity: 0.7
        border.color: Qt.darker(Kirigami.Theme.backgroundColor, 2.2)
        radius: Maui.Style.radiusV
    }
}
