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

Maui.ItemDelegate
{
    id: control

    property string tooltipText  
    
    property alias template : _template
    property alias label1 : _template.label1

    property alias iconItem : _template.iconItem
    property alias iconVisible : _template.iconVisible
    
    property alias iconSizeHint : _template.iconSizeHint
    property alias imageSizeHint : _template.imageSizeHint
    
    property alias imageSource : _template.imageSource
    property alias iconSource : _template.iconSource
    property alias showLabel : _template.labelsVisible
    
    property alias checked : _template.checked
    property alias checkable: _template.checkable

    property alias dropArea : _dropArea

    isCurrentItem : GridView.isCurrentItem || checked

    signal contentDropped(var drop)
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
