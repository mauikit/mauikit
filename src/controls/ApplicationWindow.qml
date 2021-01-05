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

/**
 * A window that provides some basic features needed for all apps
 *
 * It's usually used as a root QML component for the application.
 * By default it makes usage of the Maui Page control, so it packs a header and footer bar.
 * The header can be moved to the bottom for better reachability in hand held devices.
 * The Application window has some components already built in like an AboutDialog, a main application menu,
 * and an optional property to add a global sidebar.

 * The application can have client side decorations CSD by setting the attached property Maui.App.enabledCSD  to true,
 * or globally by editing the configuration file located at /.config/Maui/mauiproject.conf.

 * For more details you can refer to the Maui Page documentation for fine tweaking the application window main content.
 * @code
 * ApplicationWindow {
 *     id: root
 *     //The rectangle will automatically bescrollable
 *     AppViews {
 *         anchors.fill: parent
 *     }
 * }
 * @endcode
 */
Window
{
    id: root
    visible: true
    width: Screen.desktopAvailableWidth * (Kirigami.Settings.isMobile ? 1 : 0.4)
    height: Screen.desktopAvailableHeight * (Kirigami.Settings.isMobile ? 1 : 0.4)
    color: "transparent"
    flags: Maui.App.enableCSD ? Qt.FramelessWindowHint : Qt.Window

    /***************************************************/
    /********************* COLORS *********************/
    /*************************************************/
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    /**
      * content: Item.data
      * Any item to be placed inside the ApplicationWindow Page.
      */
    default property alias content : _content.data

    /**
      * sideBar : AbstractSideBar
      * A global sidebar that is reponsive and can be collapsable.
      *
      */
    property Maui.AbstractSideBar sideBar

    /***************************************************/
    /******************** ALIASES *********************/
    /*************************************************/

    /**
      * page : Page
      * The page used as the main content of the application window.
      * Via this property more fine tuning can be done to the behavior and look of the application window.
      */
    readonly property alias page : _page

    /**
      * flickable : Flickable
      * The apps page flickable. This is exposed to setting any flickable so the main header can
      * react to floating header or footer properties, or to different header or footer bars positioning.
      */
    property alias flickable : _page.flickable

    /**
      * headBar : ToolBar
      * The main header bar. This is controlled by a ToolBar and a list of amny number of components can be added to it.
      * For better understaning of its properties check the ToolBar documentation.
      */
    property alias headBar : _page.headBar

    /**
      * footBar : ToolBar
      * The main footer bar. This is controlled by a ToolBar and a list of amny number of components can be added to it.
      * For better understaning of its properties check the ToolBar documentation.
      */
    property alias footBar : _page.footBar

    /**
      * footer : Item
      * The Item containing the page footBar.
      * This property allows to change the default ToolBar footer to any other item.
      */
    property alias footer : _page.footer

    /**
      * header : Item
      * The Item containing the page headBar.
      * This property allows to change the default ToolBar header to any other item.
      */
    property alias header :_page.header

    /**
      * floatingHeader : bool
      * If the main header should float above the page contents.
      */
    property alias floatingHeader: _page.floatingHeader

    /**
      * floatingFooter : bool
      * If the main footer should float above the page contents.
      */
    property alias floatingFooter: _page.floatingFooter

    /**
      * autoHideHeader : bool
      * If the main header should auto hide after the autoHideHeaderDelay timeouts of the content loses focus.
      */
    property alias autoHideHeader: _page.autoHideHeader

    /**
      * autoHideFooter : bool
      * If the main footer should auto hide after the autoHideHeaderDelay timeouts of the content loses focus.
      */
    property alias autoHideFooter: _page.autoHideFooter

    /**
      * autoHideHeaderDelay : int
      * Time in milliseconds to wait before the header autohides if it is enabled.
      */
    property alias autoHideHeaderDelay: _page.autoHideHeaderDelay

    /**
      * autoHideFooterDelay : int
      * Time in milliseconds to wait before the footer autohides if it is enabled.
      */
    property alias autoHideFooterDelay: _page.autoHideFooterDelay

    /**
      * autoHideHeaderMargins : int
      * Threshold out of where the header autohides if enabled.
      */
    property alias autoHideHeaderMargins: _page.autoHideHeaderMargins

    /**
      * autoHideFooterMargins : int
      * Threshold out of where the footer autohides if enabled.
      */
    property alias autoHideFooterMargins: _page.autoHideFooterMargins

    /**
      * altHeader : bool
      * If the main header should be moved to the bottom of the page contents under the footer.
      * This property can be dynamically changed on mobile devices for better reachability.
      */
    property alias altHeader: _page.altHeader

    /**
      * margins : int
      * The app page content margins.
      */
    property alias margins : _page.margins

    /**
      * leftMargin : int
      * The app page content margins.
      */
    property alias leftMargin : _page.leftMargin

    /**
      * rightMargin : int
      * The app page content margins.
      */
    property alias rightMargin: _page.rightMargin

    /**
      * topMargin : int
      * The app page content margins.
      */
    property alias topMargin: _page.topMargin

    /**
      * bottomMargin : int
      * The app page content margins.
      */
    property alias bottomMargin: _page.bottomMargin

    /**
      * footerPositioning : ListView.footerPositioning
      * The page footer bar positioning. It can be sticked or can be scrolled with the page content if a flickable is provided.
      */
    property alias footerPositioning : _page.footerPositioning

    /**
      * headerPositioning : ListView.headerPositioning
      * The page header bar positioning. It can be sticked or can be scrolled with the page content if a flickable is provided.
      */
    property alias headerPositioning : _page.headerPositioning

    /**
      * dialog : Dialog
      * The internal dialogs used in the ApplicationWindow are loaded dynamically, so the current loaded dialog can be accessed
      * via this property.
      */
    property alias dialog: dialogLoader.item

    /**
      * menuButton : ToolButton
      * The main application hamburguer menu. This property can be used to customize the button look and feel.
      */
    property alias menuButton : menuBtn

    /**
      * mainMenu : list<Action>
      * A list of actions to be added to the application main menu.
      * The actions are listed under the application accounts, if used, and above the default actions menu entries: About and Quit.
      */
    property list<Action> mainMenu

    /**
      * accounts : AccountsDialog
      * The accounts dialog, with access to the current accounts listed.
      * This is only avaliable if the app makes usage of online accounts.
      */
    property alias accounts: _accountsDialogLoader.item

    /**
      * currentAccount : var
      * The current account selected.
      * Only avaliable if the app makes usage of online accounts.
      */
    property var currentAccount: Maui.App.handleAccounts ? Maui.App.accounts.currentAccount : ({})

    /**
      * notifyDialog : Dialog
      * The inline notification dialog.
      * To trigger an inline notification use the function notify()
      * This only gives access to the dialog interface properties.
      */
    property alias notifyDialog: _notify

    /**
      * aboutDialog : AboutDialog
      * The about dialog with information about the application.
      * Can be used to append more sections to the dialog or modify existing ones.
      */
    property alias aboutDialog: aboutDialog

    /**
      * background : Component
      * The application main page background.
      */
    property alias background : _page.background

    /**
      * isWide : bool
      * If the application window size is wide enough.
      * This property can be changed to any random condition.
      * Keep in mind this property is widely used in other MauiKit components to determined if items shoudl be hidden or collapsed, etc.
      */
    property bool isWide : root.width >= Kirigami.Units.gridUnit * 30

    /***************************************************/
    /**************** READONLY PROPS ******************/
    /*************************************************/
    /**
      * isPortrait : bool
      * If the screen where the application is drawn is in portrait mode or not,
      * other wise it is in landscape mode.
      */
    readonly property bool isPortrait: Screen.primaryOrientation === Qt.PortraitOrientation || Screen.primaryOrientation === Qt.InvertedPortraitOrientation

    /***************************************************/
    /******************** SIGNALS *********************/
    /*************************************************/
    /**
      * menuButtonClicked : signal
      * Triggered when the main menu button has been clicked.
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
                width: 250

                Loader
                {
                    id: _accountsMenuLoader
                    visible: active
                    width: parent.width - (Maui.Style.space.medium*2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: Maui.App.handleAccounts
                    sourceComponent: _accountsComponent
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

                MenuSeparator{visible: root.mainMenu.length}

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
            sourceComponent: Maui.WindowControls
            {
                order: Maui.App.rightWindowControls
            }
        }

        Item
        {
            id: _content
            anchors.fill: parent
            Kirigami.Theme.inherit: false

            transform: Translate
            {
                x: root.sideBar && root.sideBar.collapsible && root.sideBar.collapsed ? root.sideBar.position * (root.sideBar.width) : 0
            }

            anchors.leftMargin: root.sideBar ? ((root.sideBar.collapsible && root.sideBar.collapsed) ? 0 : (root.sideBar.width ) * root.sideBar.position) : 0
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
                    Layout.preferredHeight: implicitHeight
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
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

    Connections
    {
        target: Maui.Platform
        ignoreUnknownSignals: true
        function onShareFilesRequest(urls)
        {
            dialogLoader.source = "labs/ShareDialog.qml"
            dialog.urls = urls
            dialog.open()
        }
    }

    /**
      * Send an inline notification.
      * icon = icon to be used
      * title = the title
      * body = message of the notification
      * callback = function to be triggered if the notification dialog is accepted
      * timeout = time in milliseconds before the notification dialog is dismissed
      * buttonText = text in the accepted button
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
      * Switch from full screen to normal size.
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
      * Reference to the application main page
      */
    function window()
    {
        return _page;
    }
}
