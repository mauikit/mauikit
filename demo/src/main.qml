import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami
import QtQuick.Templates 2.3 as T

Maui.ApplicationWindow
{
    id: root

//    isWide : root.width >= Kirigami.Units.gridUnit * 10

    property int currentPageIndex : 0
    //    about.appDescription: "MauiDemo is a gallery app displaying the MauiKit controls in conjuction with Kirigami and QQC2 controls."


    property alias dialog : _dialogLoader.item
    floatingBar: false

    mainMenu: [

        Maui.MenuItem
        {
            text: qsTr("File dialog")
            icon.name: "folder-open"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _fileDialogComponent
                dialog.callback = function(paths)
                {
                    console.log("Selected paths >> ", paths)
                }

                dialog.open()
            }
        }
    ]

    headBar.spacing: space.huge
    headBar.middleContent: [

        ToolButton
        {
//            Layout.fillHeight: true
            icon.name: "nx-home"
            Kirigami.Theme.textColor : root.headBarFGColor
            spacing: space.medium
            checked: currentPageIndex === 0
            onClicked: currentPageIndex = 0
            text: qsTr("Home")

        },

        ToolButton
        {
//            Layout.fillHeight: true
            icon.name: "view-list-icons"
			Kirigami.Theme.textColor: root.headBarFGColor
            spacing: space.medium
            checked: currentPageIndex === 1
            onClicked: currentPageIndex = 1
            text: qsTr("Browser")
        },

        ToolButton
        {
//            Layout.fillHeight: true
            icon.name: "view-media-genre"
			Kirigami.Theme.textColor: root.headBarFGColor
            spacing: space.medium
            checked: currentPageIndex === 2
            onClicked: currentPageIndex = 2
            text: qsTr("Editor")
        },

        ToolButton
        {
//            Layout.fillHeight: true
            icon.name: "nx-software-center"
			Kirigami.Theme.textColor: root.headBarFGColor
            spacing: space.medium
            checked: currentPageIndex === 3
            onClicked: currentPageIndex = 3
            text: qsTr("Store")
        }
    ]

    footBar.leftContent: ToolButton
    {
        icon.name: "view-split-left-right"
        onClicked: _drawer.visible = !_drawer.visible
        checked: _drawer.visible
    }

    footBar.rightContent: Kirigami.ActionToolBar
    {
        Layout.fillWidth: true
        actions:
            [
            Kirigami.Action
            {
                iconName: "folder-new"
                text: "New folder"
                icon.width: iconSizes.medium
                icon.height: iconSizes.medium
                expandible: true

                Kirigami.Action
                    {
                        text: "exmaple"
                        icon.name: "love"
                    }

            },

            Kirigami.Action
            {
                id: _findAction
                iconName: "edit-find"
                text: parent == T.ToolButton ? "Search" : undefined
                icon.width: iconSizes.medium
                icon.height: iconSizes.medium


            },

            Kirigami.Action
            {
                iconName: "document-preview-archive"
                text: "Hidden files"
                icon.width: iconSizes.medium
                icon.height: iconSizes.medium

            }
        ]
    }

    globalDrawer: Maui.GlobalDrawer
    {
        id: _drawer
        width: Kirigami.Units.gridUnit * 14
        modal: !root.isWide

        actions: [
        Kirigami.Action
            {
                text: qsTr("Shopping")
                iconName: "cpu"
            },

            Kirigami.Action
                {
                    text: qsTr("Notes")
                iconName: "send-sms"
                },

            Kirigami.Action
                {
                    text: qsTr("Example 3")
                iconName: "love"
                }

        ]
    }

    content: SwipeView
    {
        anchors.fill: parent
        currentIndex: currentPageIndex
        onCurrentIndexChanged: currentPageIndex = currentIndex

        Maui.Page
        {
            id: _page1

            Item
            {
                anchors.fill: parent
                ColumnLayout
                {
                    anchors.centerIn: parent
                    width: Math.max(Math.min(implicitWidth, parent.width), Math.min(400, parent.width))

                    Label
                    {
                        text: "Header bar background color"
                        Layout.fillWidth: true
                    }

                    Maui.TextField
                    {
                        Layout.fillWidth: true
                        placeholderText: root.headBarBGColor
                        onAccepted:
                        {
                            root.headBarBGColor= text
                        }
                    }

                    Label
                    {
                        text: "Header bar foreground color"
                        Layout.fillWidth: true
                    }

                    Maui.TextField
                    {
                        Layout.fillWidth: true
                        placeholderText: root.headBarFGColor
                        onAccepted:
                        {
                            root.headBarFGColor = text
                        }
                    }

                    Label
                    {
                        text: "Header bar background color"
                        Layout.fillWidth: true
                    }

                    Maui.TextField
                    {
                        Layout.fillWidth: true
                        onAccepted:
                        {
                            root.headBarBGColor= text
                        }
                    }

                    //                     CheckBox
                    //                     {
                    //                         text: "Draw toolbar borders"
                    //                         Layout.fillWidth: true
                    //                            onCheckedChanged:
                    //                            {
                    //                                headBar.drawBorder = checked
                    //                                footBar.drawBorder = checked

                    //                            }
                    //                     }

                }

            }

            headBar.rightContent: ToolButton
            {
                icon.name: "documentinfo"
                text: qsTr("Notify")

                onClicked:
                {
                    var callback = function()
                    {
                        _batteryBtn.visible = true
                    }

                    notify("battery", qsTr("Plug your device"),
                           qsTr("Your device battery level is below 20%, please plug your device to a power supply"),
                           callback, 5000)
                }

            }

            headBar.leftContent: ToolButton
            {
                id: _batteryBtn
                visible: false
                icon.name: "battery"
            }
        }


        Maui.FileBrowser
        {
            id: _page2

            onItemClicked: openItem(index)

        }


        Maui.Page
        {
            id: _page3
            margins: 0
            headBar.visible: false
            Maui.Editor
            {
                id: _editor
                anchors
                {
                    fill: parent
                    //                    top: parent.top
                    //                    right: parent.right
                    //                    left: parent.left
                    //                    bottom: _terminal.top
                }
            }

            //                Maui.Terminal
            //                {
            //                    id: _terminal
            ////                    anchors
            ////                    {
            ////                        top: _editor.top
            ////                        right: parent.right
            ////                        left: parent.left
            ////                        bottom: parent.bottom
            ////                    }
            //                }


            footBar.rightContent: Maui.ToolButton
            {
                iconName: "utilities-terminal"
                onClicked:
                {
                    //                    _terminal.visible = _terminal.visible
                }
            }
        }

                Maui.Store
                {
                    id: _page4
                    list.provider: StoreList.KDELOOK

                    list.category: StoreList.WALLPAPERS
                }
    }

    //Components

    ///Dialog loaders

    Loader
    {
        id: _dialogLoader
    }

    Component
    {
        id: _fileDialogComponent

        Maui.FileDialog
        {

        }
    }

}
