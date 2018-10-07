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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.0 as Kirigami
import "private"

Item
{
    anchors.fill: parent
    /* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
    property string emoji : "qrc:/assets/face-sleeping.png"
    property string message
    property string title
    property string body
    property color fgColor : textColor
    property bool isMask : true
    property int emojiSize : iconSizes.large

    signal actionTriggered()

    clip: true
    focus: true

    Image
    {
        id: imageHolder

        anchors.centerIn: parent
        width: emojiSize
        height: emojiSize
        sourceSize.width: width
        sourceSize.height: height
        source: emoji
        asynchronous: true
        horizontalAlignment: Qt.AlignHCenter

        fillMode: Image.PreserveAspectFit
    }

    HueSaturation
    {
        anchors.fill: imageHolder
        source: imageHolder
        saturation: -1
        lightness: 0.3
        visible: isMask
    }

    Label
    {
        id: textHolder
        width: parent.width
        anchors.top: imageHolder.bottom
        opacity: 0.5
        text: message ? qsTr(message) : "<h3>"+title+"</h3><p>"+body+"</p>"
        font.pointSize: fontSizes.default

        padding: 10
        font.bold: true
        textFormat: Text.RichText
        horizontalAlignment: Qt.AlignHCenter
        elide: Text.ElideRight
        color: colorScheme.textColor
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked: actionTriggered()
    }
}


