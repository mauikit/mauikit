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

    ListView {
        id: listView
        anchors.fill: parent
        focus: true
        model: ProviderModel {}
        spacing: 3
        delegate: Item {
            width: parent.width
            height: 60
            Account { 
                id: account
                objectHandle: Manager.createAccount(model.providerId)
            }
            AccountService {
                id: globalAccountSettings
                objectHandle: account.accountServiceHandle
                credentials: Credentials {
                    id: creds
                    userName: "my name"
                    secret: "password you'll never guess"
                    caption: account.provider.id
                    acl: ["*"]
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: 10
                color: "lightsteelblue"
                Text {
                    font.bold: true
                    text: model.displayName
                }
                MouseArea {
                    anchors.fill: parent
                    /* Uncomment this to test the account creation.
                     WARNING: this will create a real account on your system,
                     with dummy data!
                     */
                    // onClicked: writeAccount()
                }
            }

            function writeAccount()
            {
                account.updateDisplayName("Delete me");
                account.updateEnabled(false);
                creds.sync();
            }
        }
    }
}
