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
import QtQuick.Window 2.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import QtQuick.Controls.Material 2.1

import "private"


Kirigami.AbstractApplicationWindow
{
    id: root
    visible: true
    width: Screen.width * (Kirigami.Settings.isMobile ? 1 : 0.4)
    height: Screen.height * (Kirigami.Settings.isMobile ? 1 : 0.4)
	contentItem.anchors.leftMargin: root.sideBar && !root.globalDrawer ? ((root.sideBar.collapsible && root.sideBar.collapsed) ? root.sideBar.collapsedSize : (root.sideBar.modal ? 0 : root.sideBar.width * root.sideBar.position)) :
                                                                         (!root.sideBar && root.globalDrawer && (root.globalDrawer.modal === false) ? root.globalDrawer.width * root.globalDrawer.position : 0)

   property Maui.AbstractSideBar sideBar

    /***************************************************/
    /******************** ALIASES *********************/
    /*************************************************/
    property alias headBar : _headBar
    property alias footBar: _footBar
    property alias dialog: dialogLoader.item

    property alias leftIcon : menuBtn
    property alias rightIcon : searchBtn

    property alias mainMenu : mainMenu.contentData
    property alias about : aboutDialog
    property alias accounts: _accountsDialogLoader.item
    property var currentAccount: Maui.App.accounts.currentAccount
    property alias notifyDialog: _notify

    property alias searchButton : searchBtn
    property alias menuButton : menuBtn

    wideScreen: isWide

    /***************************************************/
    /*********************** UI ***********************/
    /*************************************************/

    property bool isWide : root.width >= Kirigami.Units.gridUnit * 30
    property string colorSchemeName : Qt.application.name

    /***************************************************/
    /********************* COLORS *********************/
    /*************************************************/
    property color headBarBGColor: Kirigami.Theme.backgroundColor
    property color headBarFGColor: Kirigami.Theme.textColor


    /***************************************************/
    /**************** READONLY PROPS ******************/
    /*************************************************/

    readonly property bool isMobile : Kirigami.Settings.isMobile
    readonly property bool isAndroid: Qt.platform.os == "android"

    readonly property real screenWidth : Screen.width
    readonly property real screenHeight : Screen.height

    /***************************************************/
    /******************** SIGNALS *********************/
    /*************************************************/
    signal menuButtonClicked();
    signal searchButtonClicked();

    onClosing:
    {
        if(!isMobile)
        {
            const height = root.height
            const width = root.width
            const x = root.x
            const y = root.y
            Maui.FM.saveSettings("GEOMETRY", Qt.rect(x, y, width, height), "WINDOW")
        }
    }

    property bool isPortrait: Screen.primaryOrientation === Qt.PortraitOrientation || Screen.primaryOrientation === Qt.InvertedPortraitOrientation
    onIsPortraitChanged:
    {
        if(isPortrait)
        {
            console.log("PORTARIT MODE CHANGED")
            width: Screen.width
            height: Screen.height
        }
    }

    //     onHeadBarBGColorChanged:
    //     {
    //         if(!isMobile && colorSchemeName.length > 0)
    //             Maui.KDE.setColorScheme(colorSchemeName, headBarBGColor, headBarFGColor)
    //         else if(isAndroid && headBar.position === ToolBar.Header)
    //             Maui.Android.statusbarColor(headBarBGColor, false)
    // 			else if(isAndroid && headBar.position === ToolBar.Footer)
    // 				Maui.Android.statusbarColor(Kirigami.Theme.viewBackgroundColor, true)
    //
    //     }
    //
    //     onHeadBarFGColorChanged:
    //     {
    // 		if(!isAndroid && !isMobile && colorSchemeName.length > 0 && headBar.position === ToolBar.Header)
    //             Maui.KDE.setColorScheme(colorSchemeName, headBarBGColor, headBarFGColor)
    // 			else if(isAndroid && headBar.position === ToolBar.Header)
    //             Maui.Android.statusbarColor(headBarBGColor, false)
    // 			else if(isAndroid && headBar.position === ToolBar.Footer)
    // 				Maui.Android.statusbarColor(Kirigami.Theme.viewBackgroundColor, true)
    //     }
    /*
     *    background: Rectangle
     *    {
     *        color: bgColor
}
*/
    
    Component
    {
        id: _accountsComponent
        
        Column
        {
			visible: Maui.App.handleAccounts
			
            spacing: Maui.Style.space.medium
            
            Kirigami.Icon
            {
				visible: _accountsListing.count > 0
				source: "user-identity"
				height:  Maui.Style.iconSizes.huge
				width: height
				anchors.horizontalCenter: parent.horizontalCenter				
			}
            
             Label
            {
				visible: _accountsListing.count > 0
                text: currentAccount.user
                width: parent.width
                horizontalAlignment: Qt.AlignHCenter
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                font.bold: true
                font.weight: Font.Bold
            }
            
            Kirigami.Separator
            {
				visible: _accountsListing.count > 0
                width: parent.width
            }
            
            ListBrowser
            {
                id: _accountsListing
                visible: _accountsListing.count > 0
                width: parent.width
                listView.spacing: Maui.Style.space.medium
                height: Math.min(listView.contentHeight, 300)
                Kirigami.Theme.backgroundColor: "transparent"
                model:  Maui.BaseModel
                {
                    list: Maui.App.accounts                    
                }                
                
                delegate: Maui.ListBrowserDelegate
                {
                    iconSource: "amarok_artist"
                    iconSizeHint: Maui.Style.iconSizes.medium
                    label1.text: model.user
                    label2.text: model.server                       
                    width: _accountsListing.width
                    height: Maui.Style.rowHeight * 1.2
                    leftPadding: Maui.Style.space.tiny
                    rightPadding: Maui.Style.space.tiny
                    
                    onClicked: 
                    {
                        _accountsListing.currentIndex = index
                        Maui.App.accounts.currentAccountIndex = 
                        index
                    }
                }
                
                Component.onCompleted:
                {
                    if(_accountsListing.count > 0)
                    {
                        _accountsListing.currentIndex = 0
                        Maui.App.accounts.currentAccountIndex = 
                        _accountsListing.currentIndex
                    }
                }
            }
            
            Kirigami.Separator
            {
				visible: _accountsListing.count > 0
                width: parent.width
            }
            
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Manage accounts")
                icon.name: "list-add-user"
                onClicked:
                {
                    if(root.accounts)
                        accounts.open()
                        
                   mainMenu.close()
                }
            }
            
            Kirigami.Separator
            {
                width: parent.width
            }          
            
        }
    }

    property Maui.ToolBar mheadBar : Maui.ToolBar
    {
        id: _headBar
        visible: count > 1
        position: ToolBar.Header
        width: root.width
        height: implicitHeight
        // 		Kirigami.Theme.backgroundColor: headBarBGColor
        // 		Kirigami.Theme.textColor: headBarFGColor
        // 		Kirigami.Theme.inherit: true

        leftContent: [ ToolButton
            {
                id: menuBtn
                icon.name: "application-menu"
                icon.color: headBarFGColor
                icon.width: Maui.Style.iconSizes.medium
                icon.height: Maui.Style.iconSizes.medium
                checked: mainMenu.visible
                onClicked:
                {
                    menuButtonClicked()
                    mainMenu.visible ? mainMenu.close() : mainMenu.popup(parent, parent.x , parent.height+ Maui.Style.space.medium)
                }

                Menu
                {
                    id: mainMenu
                    modal: true
                    z: 999
                    width: Maui.Style.unit * 250
                    
                    Loader
                    {
						id: _accountsMenuLoader
						width: parent.width * 0.9
						anchors.horizontalCenter: parent.horizontalCenter
						active: Maui.App.handleAccounts
						sourceComponent: Maui.App.handleAccounts ?
						_accountsComponent : null
					}
					
                    MenuItem
                    {
                        text: qsTr("About")
                        icon.name: "documentinfo"
                        onTriggered: aboutDialog.open()
                    }
                }
            }
        ]

        rightContent: ToolButton
        {
            id: searchBtn
            icon.name: "edit-find"
            icon.color: headBarFGColor
            onClicked: searchButtonClicked()
            icon.width: Maui.Style.iconSizes.medium
            icon.height: Maui.Style.iconSizes.medium
        }
    }

    property Maui.ToolBar mfootBar : Maui.ToolBar
    {
        id: _footBar
        visible: count
        position: ToolBar.Footer
        width: root.width
        height: implicitHeight
    }

    header: headBar.count && headBar.position === ToolBar.Header ? headBar : null

    footer: Column
    {
        id: _footer
        visible : children
        children:
        {
            if(headBar.position === ToolBar.Footer && headBar.count && footBar.count)
                return [footBar , headBar]
            else if(headBar.position === ToolBar.Footer && headBar.count)
                return [headBar]
            else if(footBar.count)
                return [footBar]
            else
                return []
        }
    }

    Maui.AboutDialog
    {
        id: aboutDialog
    }

    Loader
    {
        id: _accountsDialogLoader
        source: Maui.App.handleAccounts ? "private/AccountsHelper.qml" : ""
    }

    Maui.Dialog
    {
        id: _notify
        property var cb : ({})
		
		property alias iconName : _notifyTemplate.iconSource
		property alias title : _notifyTemplate.label1
		property alias body: _notifyTemplate.label2
		
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
		
		page.padding: Maui.Style.space.medium
		
		footBar.background: null

		maxHeight: Math.max(Maui.Style.iconSizes.large + Maui.Style.space.huge, (_notifyTemplate.implicitHeight)) + Maui.Style.space.big + footBar.height
        maxWidth: Kirigami.Settings.isMobile ? parent.width * 0.9 : Maui.Style.unit * 500
        widthHint: 0.8

        Timer
        {
            id: _notifyTimer
            onTriggered:
            {
				if(_mouseArea.containsPress || _mouseArea.containsMouse)
					return;
				
				_notify.close()
            }
        }

        onClosed: _notifyTimer.stop()
        
		Maui.ListItemTemplate
		{
			id: _notifyTemplate		
			anchors.fill: parent
			iconSizeHint: Maui.Style.iconSizes.huge
			label1.font.bold: true
			label1.font.weight: Font.Bold
			label1.font.pointSize: Maui.Style.fontSizes.big
			iconSource: "dialog-warning"
		}
        
        MouseArea
        {
			id: _mouseArea
			height: parent.height
			width: parent.width
			anchors.centerIn: parent
			hoverEnabled: true
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
        if(isAndroid && headBar.position === ToolBar.Footer)
            Maui.Android.statusbarColor(Kirigami.Theme.backgroundColor, true)

        if(!isMobile)
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
		target: Maui.App
		onSendNotification: notify(icon, title, body, callback, timeout, buttonText)
	}

    function notify(icon, title, body, callback, timeout, buttonText)
    {
		_notify.iconName = icon || "emblem-warning"
		_notify.title.text = title
        _notify.body.text = body
        _notifyTimer.interval = timeout ? timeout : 2500
        _notify.acceptButton.text = buttonText || qsTr ("Accept")
        _notify.show(callback)
    }
}
