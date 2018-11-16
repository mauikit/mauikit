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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{
	id: control

	property bool customServer: false
    acceptText: qsTr("Sign In")
    rejectText: qsTr("Cancel")
	rejectButton.visible: false
	
	property alias serverField: serverField
	property alias userField: userField
	property alias passwordField: passwordField
	
    maxHeight: unit * 300
    maxWidth: maxHeight	
	
	footBar.leftContent: Maui.ToolButton
	{
		iconName: "filename-space-amarok"
// 		text: qsTr("Custom server")
		checkable: true
		checked: customServer
		onClicked: customServer = !customServer
	}
	
    onRejected:	close()

    Item
    {
        anchors.fill: parent

        ColumnLayout
        {
            anchors.centerIn: parent
            width: parent.width
            
            Image
            {
				visible: !customServer
				Layout.alignment: Qt.AlignCenter | Qt.ALignTop
				Layout.preferredWidth: width
				Layout.preferredHeight: height
				Layout.margins: space.big
				
				width: iconSizes.huge
				height: width
				sourceSize.width: width
				sourceSize.height: height
				
				source: "qrc:/assets/opendesktop.png"
			}
            
            Maui.TextField
            {
                id: serverField
                visible: customServer
                Layout.fillWidth: true
                placeholderText: qsTr("Server address...")
                text: "https://cloud.opendesktop.cc/remote.php/webdav/"
            }

            Maui.TextField
            {
                id: userField
                Layout.fillWidth: true
                placeholderText: qsTr("User name...")
                inputMethodHints: Qt.ImhNoAutoUppercase
            }

            Maui.TextField
            {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: qsTr("User password...")
                echoMode: TextInput.PasswordEchoOnEdit
                inputMethodHints: Qt.ImhNoAutoUppercase

            }
        }
    }
}
