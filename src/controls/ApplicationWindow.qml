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

import QtQuick 2.12
import QtQuick.Controls 2.3

import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Window 2.12

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "private" as Private

Window
{
    id: root
    default property alias content : _content.data

    visible: true
    width: Screen.desktopAvailableWidth * (Kirigami.Settings.isMobile ? 1 : 0.4)
    height: Screen.desktopAvailableHeight * (Kirigami.Settings.isMobile ? 1 : 0.4)
    color: "transparent"
    flags: Maui.App.enableCSD ? Qt.FramelessWindowHint : Qt.Window

    /**
      */
    property Maui.AbstractSideBar sideBar

    /***************************************************/
    /******************** ALIASES *********************/
    /*************************************************/

    property alias page : _page
    
    /**
      */
    property alias flickable : _page.flickable

    /**
      */
    property alias headBar : _page.headBar

    /**
      */
    property alias footBar: _page.footBar

    /**
      */
    property alias footer: _page.footer

    /**
      */
    property alias header :_page.header

    /**
      */
    property alias floatingHeader: _page.floatingHeader

    /**
      */
    property alias floatingFooter: _page.floatingFooter

    /**
      */
    property alias autoHideHeader: _page.autoHideHeader

    /**
      */
    property alias autoHideFooter: _page.autoHideFooter

    /**
      */
    property alias autoHideHeaderDelay: _page.autoHideHeaderDelay

    /**
      */
    property alias autoHideFooterDelay: _page.autoHideFooterDelay

    /**
      */
    property alias autoHideHeaderMargins: _page.autoHideHeaderMargins

    /**
      */
    property alias autoHideFooterMargins: _page.autoHideFooterMargins

    /**
      */
    property alias altHeader: _page.altHeader

    /**
      */
    property alias margins : _page.margins

    /**
      */
    property alias leftMargin : _page.leftMargin

    /**
      */
    property alias rightMargin: _page.rightMargin

    /**
      */
    property alias topMargin: _page.topMargin

    /**
      */
    property alias bottomMargin: _page.bottomMargin

    /**
      */
    property alias footerPositioning : _page.footerPositioning

    /**
      */
    property alias headerPositioning : _page.headerPositioning

    /**
      */
    property alias dialog: dialogLoader.item

    /**
      */
    property alias menuButton : menuBtn

    /**
      */
    property list<Action> mainMenu

    /**
      */
    property alias accounts: _accountsDialogLoader.item

    /**
      */
    property var currentAccount: Maui.App.handleAccounts ? Maui.App.accounts.currentAccount : ({})

    /**
      */
    property alias notifyDialog: _notify

    /**
      */
    property alias background : _page.background

    /**
      */
    property bool isWide : root.width >= Kirigami.Units.gridUnit * 30

    /***************************************************/
    /********************* COLORS *********************/
    /*************************************************/
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    /***************************************************/
    /**************** READONLY PROPS ******************/
    /*************************************************/
    /**
      */
    readonly property bool isPortrait: Screen.primaryOrientation === Qt.PortraitOrientation || Screen.primaryOrientation === Qt.InvertedPortraitOrientation

    /***************************************************/
    /******************** SIGNALS *********************/
    /*************************************************/
    /**
      */
    signal menuButtonClicked();

    onClosing:
    {
        if(!Kirigami.Settings.isMobile)
        {
            const height = root.height
            const width = root.width
            const x = root.x
            const y = root.y
            Maui.FM.saveSettings("GEOMETRY", Qt.rect(x, y, width, height), "WINDOW")
        }
    }

     Maui.Page
    {
        id: _page
        anchors.fill: parent
        Kirigami.Theme.colorSet: root.Kirigami.Theme.colorSet
        headerBackground.color: Maui.App.enableCSD ? Qt.darker(Kirigami.Theme.backgroundColor, 1.1) : headBar.Kirigami.Theme.backgroundColor

        headBar.farLeftContent: Loader
        {
            id: _leftControlsLoader
            visible: active
            active: Maui.App.enableCSD && Maui.App.leftWindowControls.length
            Layout.preferredWidth: active ? implicitWidth : 0
            Layout.fillHeight: true
            sourceComponent:  Maui.WindowControls
            {
                order: Maui.App.leftWindowControls
            }
        }

        headBar.leftContent: ToolButton
        {
            id: menuBtn
            icon.name: "application-menu"
            checked: _mainMenu.visible
            onClicked:
            {
                menuButtonClicked()
                _mainMenu.visible ? _mainMenu.close() : _mainMenu.popup(parent, 0 , root.headBar.height )
            }

            Menu
            {
                id: _mainMenu
                modal: true
                z: 999
                width: Maui.Style.unit * 250

                Loader
                {
                    id: _accountsMenuLoader
                    width: parent.width - (Maui.Style.space.medium*2)
                    anchors.horizontalCenter: parent.horizontalCenter

                    active: Maui.App.handleAccounts
                    sourceComponent: Maui.App.handleAccounts ?
                                         _accountsComponent : null
                }

                MenuSeparator {visible: _accountsMenuLoader.active}

                Repeater
                {
                    model: root.mainMenu
                    MenuItem
                    {
                        action: modelData
                    }
                }

                MenuSeparator{}

                MenuItem
                {
                    text: i18n("About")
                    icon.name: "documentinfo"
                    onTriggered: aboutDialog.open()
                }

                MenuItem
                {
                    text: i18n("Quit")
                    onTriggered: root.close()
                }
            }
        }

        headBar.farRightContent: Loader
        {
            id: _rightControlsLoader
            visible: active
            active: Maui.App.enableCSD && Maui.App.rightWindowControls.length
            Layout.preferredWidth: active ? implicitWidth : 0
            Layout.fillHeight: true
            sourceComponent:  Maui.WindowControls
            {
                order:  Maui.App.rightWindowControls
            }
        }

        Item
        {
            id: _content
            anchors.fill: parent
            Kirigami.Theme.inherit: false

            transform: Translate
            {
                x: root.sideBar && root.sideBar.collapsible && root.sideBar.collapsed ? root.sideBar.position * (root.sideBar.width - root.sideBar.collapsedSize) : 0
            }

            anchors.leftMargin: root.sideBar ? ((root.sideBar.collapsible && root.sideBar.collapsed) ? root.sideBar.collapsedSize : (root.sideBar.width ) * root.sideBar.position) : 0
        }

        background: Rectangle
        {
            id: _pageBackground
            color: Kirigami.Theme.backgroundColor
            radius: root.visibility === Window.Maximized || !Maui.App.enableCSD ? 0 :Maui.Style.radiusV
        }

        layer.enabled: Maui.App.enableCSD
        layer.effect: OpacityMask
        {
            maskSource: Item
            {
                width: _page.width
                height: _page.height

                Rectangle
                {
                    anchors.fill: parent
                    radius: _pageBackground.radius
                }
            }
        }
    }

    Rectangle
    {
        visible: Maui.App.enableCSD
        z: ApplicationWindow.overlay.z + 9999
        anchors.fill: parent
        radius: _pageBackground.radius - 0.5
        color: "transparent"
        border.color: Qt.darker(Kirigami.Theme.backgroundColor, 2.7)
        opacity: 0.8

        Rectangle
        {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            radius: parent.radius - 0.5
            border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
            opacity: 0.8
        }
    }

    MouseArea
    {
        visible: Maui.App.enableCSD
        height: 16
        width: height
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        cursorShape: Qt.SizeBDiagCursor
        propagateComposedEvents: true
        preventStealing: false

        onPressed: mouse.accepted = false

        DragHandler
        {
            grabPermissions: TapHandler.TakeOverForbidden
            target: null
            onActiveChanged: if (active)
                             {
                                 root.startSystemResize(Qt.LeftEdge | Qt.BottomEdge);
                             }
        }
    }

    MouseArea
    {
        visible: Maui.App.enableCSD
        height: 16
        width: height
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        cursorShape: Qt.SizeFDiagCursor
        propagateComposedEvents: true
        preventStealing: false

        onPressed: mouse.accepted = false

        DragHandler
        {
            grabPermissions: TapHandler.TakeOverForbidden
            target: null
            onActiveChanged: if (active)
                             {
                                 root.startSystemResize(Qt.RightEdge | Qt.BottomEdge);
                             }
        }
    }

    Overlay.overlay.modal: Rectangle
    {
        color: Qt.rgba( root.Kirigami.Theme.backgroundColor.r,  root.Kirigami.Theme.backgroundColor.g,  root.Kirigami.Theme.backgroundColor.b, 0.7)

        Behavior on opacity { NumberAnimation { duration: 150 } }

        radius: _pageBackground.radius
    }

    Overlay.overlay.modeless: Rectangle
    {
        radius: _pageBackground.radius

        color: Qt.rgba( root.Kirigami.Theme.backgroundColor.r,  root.Kirigami.Theme.backgroundColor.g,  root.Kirigami.Theme.backgroundColor.b, 0.7)
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Component
    {
        id: _accountsComponent

        Item
        {
            height: _accountLayout.implicitHeight + Maui.Style.space.medium

            ColumnLayout
            {
                id: _accountLayout
                anchors.fill: parent
                spacing: Maui.Style.space.medium

                Repeater
                {
                    id: _accountsListing

                    model: Maui.BaseModel
                    {
                        list: Maui.App.accounts
                    }

                    delegate: Maui.ListBrowserDelegate
                    {
                        visible: _accountsListing.count > 0
                        Layout.fillWidth: true
                        Kirigami.Theme.backgroundColor: "transparent"

                        isCurrentItem: Maui.App.accounts.currentAccountIndex === index
                        iconSource: "amarok_artist"
                        iconSizeHint: Maui.Style.iconSizes.medium
                        label1.text: model.user
                        label2.text: model.server
                        width: _accountsListing.width
                        height: Maui.Style.rowHeight * 1.2
                        onClicked: Maui.App.accounts.currentAccountIndex = index
                    }

                    Component.onCompleted:
                    {
                        if(_accountsListing.count > 0)
                            Maui.App.accounts.currentAccountIndex = 0
                    }
                }

                Button
                {
                    Layout.margins: Maui.Style.space.small
                    Layout.preferredHeight: implicitHeight
                    Layout.alignment: Qt.AlignCenter
                    text: i18n("Accounts")
                    icon.name: "list-add-user"
                    onClicked:
                    {
                        if(root.accounts)
                            accounts.open()

                        _mainMenu.close()
                    }
                }
            }
        }
    }

    Private.AboutDialog
    {
        id: aboutDialog
    }

    Loader
    {
        id: _accountsDialogLoader
        active: Maui.App.handleAccounts
        source: "private/AccountsHelper.qml"
    }

    Maui.Dialog
    {
        id: _notify
        property var cb : ({})

        property alias iconName : _notifyTemplate.iconSource
        property alias title : _notifyTemplate.label1
        property alias body: _notifyTemplate.label2

        persistent: false
        verticalAlignment: Qt.AlignTop
        defaultButtons: _notify.cb !== null
        rejectButton.visible: false
        onAccepted:
        {
            if(_notify.cb)
            {
                _notify.cb()
                _notify.close()
            }
        }

        page.margins: Maui.Style.space.big

        footBar.background: null
        widthHint: 0.8

        Timer
        {
            id: _notifyTimer
            onTriggered:
            {
                if(_mouseArea.containsPress || _mouseArea.containsMouse)
                {
                    _notifyTimer.restart();
                    return
                }

                _notify.close()
            }
        }

        onClosed: _notifyTimer.stop()

        stack: MouseArea
        {
            id: _mouseArea
            Layout.fillHeight: true
            Layout.fillWidth: true
            hoverEnabled: true
            Maui.ListItemTemplate
            {
                id: _notifyTemplate
                spacing: Maui.Style.space.big
                anchors.fill: parent

                iconSizeHint: Maui.Style.iconSizes.big
                label1.font.bold: true
                label1.font.weight: Font.Bold
                label1.font.pointSize: Maui.Style.fontSizes.big
                iconSource: "dialog-warning"
            }
        }

        function show(callback)
        {
            _notify.cb = callback || null
            _notifyTimer.start()
            _notify.open()
        }
    }

    Loader
    {
        id: dialogLoader
    }

    Component.onCompleted:
    {
        if(Maui.Handy.isAndroid)
        {
            if(headBar.position === ToolBar.Footer)
            {
                Maui.Android.statusbarColor(Kirigami.Theme.backgroundColor, true)
                Maui.Android.navBarColor(headBar.visible ? headBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, true)

            } else
            {
                Maui.Android.statusbarColor(headBar.Kirigami.Theme.backgroundColor, true)
                Maui.Android.navBarColor(footBar.visible ? footBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, true)
            }
        }

        if(!Kirigami.Settings.isMobile)
        {
            const rect = Maui.FM.loadSettings("GEOMETRY", "WINDOW", Qt.rect(root.x, root.y, root.width, root.height))
            root.x = rect.x
            root.y = rect.y
            root.width = rect.width
            root.height = rect.height
        }
    }

    /**
      */
    function notify(icon, title, body, callback, timeout, buttonText)
    {
        _notify.iconName = icon || "emblem-warning"
        _notify.title.text = title
        _notify.body.text = body
        _notifyTimer.interval = timeout ? timeout : 2500
        _notify.acceptButton.text = buttonText || qsTr ("Accept")
        _notify.show(callback)
    }

    /**
      */
    function toggleMaximized()
    {
        if (root.visibility === Window.Maximized)
        {
            root.showNormal();
        } else
        {
            root.showMaximized();
        }
    }

    /**
      */
    function window()
    {
        return _page;
    }
}
