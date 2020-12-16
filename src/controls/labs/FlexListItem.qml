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

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.2 as Maui


/**
  * A template to position text besides an icon or image with a flex content side, that flexes under constrained spaces.
  *
  */
Control
{
    id: control

    /**
      *
      */
    default property alias content : _content.data

    /**
      *
      */
    property alias template: _template

    /**
      *
      */
    property alias label1 : _template.label1

    /**
      *
      */
    property alias label2 : _template.label2

    /**
      *
      */
    property alias label3 : _template.label3

    /**
      *
      */
    property alias label4 : _template.label4

    /**
      *
      */
    property alias iconSource : _template.iconSource

    /**
      *
      */
    property alias imageSource : _template.imageSource

    /**
      *
      */
    property alias iconSizeHint : _template.iconSizeHint

    /**
      *
      */
    property bool wide : _content.implicitWidth < control.width * 0.5

    property alias rowSpacing : _layout.rowSpacing

    property alias columnSpacing: _layout.columnSpacing

    implicitHeight: _layout.implicitHeight
    Layout.fillWidth: true


    GridLayout
    {
        id: _layout
        anchors.fill: parent
        rowSpacing: 0
        columnSpacing: 0
        rows: 2
        columns: 2

        Maui.ListItemTemplate
        {
            id: _template
            Layout.fillWidth: true
//            Layout.fillHeight: true
            Layout.row: 0
            Layout.column: 0
            Layout.columnSpan: control.wide ? 1 : 2
            Layout.rowSpan: control.wide ? 2 : 1
            iconSizeHint: Maui.Style.iconSizes.medium
            label2.wrapMode: Text.WordWrap
        }

        RowLayout
        {
            id: _content
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.margins: control.wide ? Maui.Style.space.medium : Maui.Style.space.tiny
            Layout.row: control.wide ? 0 : 1
            Layout.column: control.wide ? 1 : 0

            Layout.columnSpan: control.wide ? 2 : 1
            Layout.rowSpan: control.wide ? 2 : 1

            Layout.fillWidth: !control.wide
//            Layout.fillHeight: true
        }
    }
}
