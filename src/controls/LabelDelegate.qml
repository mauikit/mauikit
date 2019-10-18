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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "private"

ItemDelegate
{
    id: control
    Kirigami.Theme.backgroundColor: isSection ? "transparent" : (index % 2 === 0 ? Qt.darker(Kirigami.Theme.backgroundColor) : "transparent")				
    
    property bool isCurrentListItem :  ListView.isCurrentItem
    
    implicitHeight: Maui.Style.rowHeight
    
    property bool isSection : false
    
    property alias label: labelTxt.text
    property alias labelTxt : labelTxt
    
    background: Rectangle
    {
        color: control.isCurrentListItem ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
        opacity: control.isCurrentListItem ? 1 : 0.1
    }
    
    Label
    {
        id: labelTxt
        anchors.margins: Maui.Style.contentMargins
        anchors.fill: parent
        
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter
        text: labelTxt.text
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
        color:  control.isCurrentListItem ? control.Kirigami.Theme.highlightedTextColor : control.Kirigami.Theme.textColor
        font.pointSize: Maui.Style.fontSizes.default
        
        font.bold: control.isSection
        font.weight : control.isSection ? Font.Bold : Font.Normal
    }
    
}
