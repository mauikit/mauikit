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
import org.kde.mauikit 1.3 as Maui
import QtGraphicalEffects 1.0
import "private"

/**
 * ListBrowserDelegate
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

    implicitHeight: label4.visible || label2.visible ?  Maui.Style.rowHeight + (Maui.Style.space.medium * 1.5) : Maui.Style.rowHeight
    isCurrentItem : ListView.isCurrentItem || checked

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered && control.tooltipText
    ToolTip.text: control.tooltipText

    /**
      * content : ListItemTemplate.data
      */
    default property alias content : _template.content

    /**
      * tooltipText : string
      */
    property string tooltipText

    /**
      * label1 : Label
      */
    property alias label1 : _template.label1

    /**
      * label2 :  Label
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
      * leftLabels : ColumnLayout
      */
    property alias leftLabels: _template.leftLabels

    /**
      * rightLabels : ColumnLayout
      */
    property alias rightLabels: _template.rightLabels

    /**
      * template : ListItemTemplate
      */
    property alias template : _template

    /**
      * contentDropped :
      */
    signal contentDropped(var drop)

    /**
      * toggled :
      */
    signal toggled(bool state)

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        enabled: control.draggable

        Rectangle
        {
            anchors.fill: parent
            radius: Maui.Style.radiusV
            color: control.Kirigami.Theme.highlightColor
            visible: parent.containsDrag
            opacity: 0.3
        }

        onDropped:
        {
            control.contentDropped(drop)
        }
    }

    Maui.ListItemTemplate
    {
        id: _template
        anchors.fill: parent
        isCurrentItem : control.isCurrentItem
        hovered: parent.hovered
        checkable : control.checkable
        checked : control.checked
        onToggled: control.toggled(state)
        leftMargin: iconVisible ? 0 : Maui.Style.space.medium
        
        iconComponent: Maui.IconItem
        {
            radius: Maui.Style.radiusV
           color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))
           
           iconSource: control.iconSource
           imageSource: _template.imageSource
            
            highlighted: _template.isCurrentItem
            hovered: _template.hovered
            
            iconSizeHint: _template.iconSizeHint
            imageSizeHint: _template.imageSizeHint
            
            imageWidth: _template.imageWidth
            imageHeight: _template.imageHeight
            
            fillMode: _template.fillMode
            maskRadius: _template.maskRadius
            imageBorder: _template.imageBorder
        }
    }
}
