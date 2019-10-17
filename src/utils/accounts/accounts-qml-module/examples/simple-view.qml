/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 2.1.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.OnlineAccounts 0.1

Rectangle {
    width: 400
    height: 300

    AccountServiceModel {
        id: accounts
        serviceType: "microblogging"
        includeDisabled: true
    }

    ListView {
        id: listView
        width: parent.width
        height: parent.height
        anchors.fill: parent
        focus: true
        model: accounts
        spacing: 3
        delegate: Item {
                width: parent.width
                height: 60
                AccountService { 
                    id: accts
                    objectHandle: accountServiceHandle
                    onAuthenticated: { console.log("Access token is " + reply.AccessToken) }
                    onAuthenticationError: { console.log("Authentication failed, code " + error.code) }
                    onEnabledChanged: {
                        console.log ("ENABLED CHANGED");
                    }
                }    
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: accts.enabled ? "lightsteelblue" : "#777"
                    Column {
                        anchors.fill: parent
                        anchors.margins: 5

                        Text {
                            font.bold: true
                            text: providerName
                        }
                        Text {
                            text: displayName
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: accts.authenticate(null)
                    }
                }
        }
    }
}
