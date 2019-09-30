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
	contentItem.anchors.leftMargin: root.sideBar && !root.globalDrawer ? ((root.sideBar.collapsible && root.sideBar.collapsed) ? root.sideBar.collapsedSize : (root.sideBar.modal ? 0 : root.sideBar.width)) :
	(!root.sideBar && root.globalDrawer && (root.globalDrawer.modal === false) ? root.globalDrawer.width * root.globalDrawer.position : 0)

	property bool showAccounts : true
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
			var height = root.height
			var width = root.width
			var x = root.x
			var y = root.y		
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
	
	property Maui.ToolBar mheadBar : Maui.ToolBar
	{ 
		id: _headBar
		visible: count > 1
		position: ToolBar.Header 
		width: root.width		
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
				width: Maui.Style.unit * 200
				
				Item
				{
					height: _accountCombobox.visible ? _accountCombobox.implicitHeight + Maui.Style.space.big: 0
					
					anchors
					{
						left: parent.left
						right: parent.right
						top: parent.top
						margins: Maui.Style.space.medium
					}
					
					ComboBox
					{
						id: _accountCombobox
						anchors.centerIn: parent
						// 						parent: mainMenu
						popup.z: 999
						width: parent.width
						// 						visible: (count > 1) && showAccounts
						textRole: "user"
						flat: true
						model: Maui.BaseModel
						{
							list: Maui.App.accounts
						}
						onActivated: Maui.App.accounts.currentAccountIndex = index;					
						
						Component.onCompleted: 
						{
							if(_accountCombobox.count > 0)
							{
								_accountCombobox.currentIndex = 0
								Maui.App.accounts.currentAccountIndex = _accountCombobox.currentIndex								
							}
						}
					}
				}
				
				MenuItem
				{
					text: qsTr("Accounts")
					visible: root.showAccounts
					icon.name: "list-add-user"
					onTriggered: 
					{
						if(root.accounts)
							accounts.open()
					}
				}
				
				MenuSeparator
				{
					visible: _accountCombobox.visible
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
		}
	}
	
	property Maui.ToolBar mfootBar : Maui.ToolBar 
	{ 
		id: _footBar
		visible: count
		position: ToolBar.Footer
		width: root.width
	}  
	
	header: headBar.count && headBar.position === ToolBar.Header ? headBar : undefined
	
	footer: Column 
	{
		id: _footer
		visible : children > 0
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
		sourceComponent: root.showAccounts ? _accountsDialogComponent : undefined
	}
	
	Component
	{
		id: _accountsDialogComponent
		AccountsHelper {}	
	}	
	
	Maui.Dialog
	{
		id: _notify
		property var cb : ({})
		verticalAlignment: Qt.AlignTop
		defaultButtons: false			
			
			maxHeight: Math.max(Maui.Style.unit * 120, (_notifyLayout.implicitHeight))
			maxWidth: Kirigami.Settings.isMobile ? parent.width * 0.9 : Maui.Style.unit * 500
			
			Timer 
			{
				id: _notifyTimer			
                onTriggered:
                {
                    if(!_mouseArea.pressed)
                        _notify.close()
                }
			}
			
			onClosed: _notifyTimer.stop()
			
			MouseArea
			{
                id: _mouseArea
				anchors.fill: parent
				onClicked: 
				{
					if(_notify.cb)
                    {
                        _notify.cb()
                        _notify.close()
                    }
				}
			}
			
			GridLayout
			{
				anchors.fill: parent				
				columns: 2
				rows: 1
				
				Item
				{
					Layout.fillHeight: true
					Layout.preferredWidth: Maui.Style.iconSizes.huge + Maui.Style.space.big
					Layout.row: 1
					Layout.column: 1
					
                    Kirigami.Icon
					{
						id: _notifyIcon
                        width: Maui.Style.iconSizes.large
                        height: width
						anchors.centerIn: parent
					}				
				}
				
				Item
				{
					Layout.fillHeight: true
					Layout.fillWidth: true	
					Layout.row: 1
					Layout.column: 2
					
					ColumnLayout
					{
						anchors.fill: parent
						id: _notifyLayout
						
						Label
						{
							id: _notifyTitle
							Layout.fillHeight: true
							Layout.fillWidth: true
							font.weight: Font.Bold
							font.bold: true
							font.pointSize:Maui.Style.fontSizes.big
							// 						color: _notify.colorScheme.textColor
							elide: Qt.ElideRight
							wrapMode: Text.Wrap
						}
						
						Label
						{
							id: _notifyBody
							Layout.fillHeight: true
							Layout.fillWidth: true
							font.pointSize:Maui.Style.fontSizes.default	
							// 						color: _notify.colorScheme.textColor
							elide: Qt.ElideRight
							wrapMode: Text.Wrap
						}
					}
				}
			}
			
			function show(callback)
			{
				_notify.cb = callback
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
				var rect = Maui.FM.loadSettings("GEOMETRY", "WINDOW", Qt.rect(root.x, root.y, root.width, root.height))
				root.x = rect.x
				root.y = rect.y
				root.width = rect.width
				root.height = rect.height
				
			}
			
	}
	
	function notify(icon, title, body, callback, timeout)
	{
        _notifyIcon.source = icon
		_notifyTitle.text = title
		_notifyBody.text = body
		_notifyTimer.interval = timeout ? timeout : 2500
		
		_notify.show(callback) 
	}
}
