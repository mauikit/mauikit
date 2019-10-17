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
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.OnlineAccounts 0.1

MainView {
    width: units.gu(60)
    height: units.gu(80)
    Behavior on x {
        SequentialAnimation{
            PropertyAction { property: "x"; value: main.width }
            PropertyAnimation { duration: 200 }
        }
    }

    AccountServiceModel {
        id: accounts
        serviceType: "microblogging"
        //serviceType: "IM"
        includeDisabled: true
        Component.onCompleted: { set_model()}
    }

    function set_model () {
        listView.model = accounts;
        console.log ("MODEL READY: " + listView.count);
    }
    ListView {
        id: listView
        width: parent.width
        height: parent.height
        anchors.fill: parent
        focus: true
        delegate: Item {
                width: parent.width
                height: childrenRect.height
                AccountService { 
                    id: accts
                    objectHandle: accountServiceHandle
                    onAuthenticated: { console.log("Access token is " + reply.AccessToken) }
                    onAuthenticationError: { console.log("Authentication failed, code " + error.code) }
                    Component.onCompleted: {
                        sw.checked = accts.enabled;
                    }
                    onEnabledChanged: {
                        console.log ("ENABLED CHANGED");
                        sw.checked = accts.enabled;
                    }
                }    
                ListItem.Standard {
                    text: displayName
                    icon: "image://gicon/"+accts.provider.iconName
                    control {
                        Switch {
                            id: sw
                            checked: false
                        }
                    }
                    onClicked: accts.authenticate(null)
                }
        }

        populate: Transition {
            NumberAnimation { properties: "x,y"; duration: 1000 }
        }
    }
}
