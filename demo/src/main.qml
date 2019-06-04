import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami

Maui.ApplicationWindow
{
    id: root

    property int currentPageIndex : 0
//    about.appDescription: "MauiDemo is a gallery app displaying the MauiKit controls in conjuction with Kirigami and QQC2 controls."


    property alias dialog : _dialogLoader.item


    mainMenu: [

        Maui.MenuItem
        {
            text: qsTr("File dialog")
            icon.name: "folder-open"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _fileDialogComponent
                dialog.open()
            }
        }
    ]

    headBar.spacing: space.huge
    headBar.middleContent: [

        Maui.ToolButton
        {
            //            Layout.fillHeight: true
            iconName: "nx-home"
            iconColor: root.headBarFGColor
            spacing: space.medium
            showIndicator: currentPageIndex === 0
            onClicked: currentPageIndex = 0
            text: qsTr("Home")
            display: showIndicator ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        },

        Maui.ToolButton
        {
            //            Layout.fillHeight: true
            iconName: "view-list-icons"
            iconColor: root.headBarFGColor
            spacing: space.medium
            showIndicator: currentPageIndex === 1
            onClicked: currentPageIndex = 1
            text: qsTr("Browser")
            display: showIndicator ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        },

        Maui.ToolButton
        {
            //            Layout.fillHeight: true
            iconName: "view-media-genre"
            iconColor: root.headBarFGColor
            spacing: space.medium
            showIndicator: currentPageIndex === 2
            onClicked: currentPageIndex = 2
            text: qsTr("Editor")
            display: showIndicator ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        },

        Maui.ToolButton
        {
            //            Layout.fillHeight: true
            iconName: "nx-software-center"
            iconColor: root.headBarFGColor
            spacing: space.medium
            showIndicator: currentPageIndex === 3
            onClicked: currentPageIndex = 3
            text: qsTr("Store")
            display: showIndicator ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        }
    ]

    footBar.leftContent: Maui.ToolButton
    {
        iconName: "view-split-left-right"
        onClicked: _drawer.modal = !_drawer.modal
        checked: !_drawer.modal
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

            },

            Kirigami.Action
            {
                iconName: "edit-find"
                text: "Search"

            },

            Kirigami.Action
            {
                iconName: "document-preview-archive"
                text: "Hidden files"

            }
        ]
    }

    globalDrawer: Maui.GlobalDrawer
    {
        id: _drawer
        width: Kirigami.Units.gridUnit * 14
        modal: !root.isWide
        handleVisible: false
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

                     CheckBox
                     {
                         text: "Draw toolbar borders"
                         Layout.fillWidth: true
                            onCheckedChanged:
                            {
                                headBar.drawBorder = checked
                                footBar.drawBorder = checked

                            }
                     }

                 }

            }

            headBar.rightContent: Maui.ToolButton
            {
                iconName: "documentinfo"
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

            headBar.leftContent: Maui.ToolButton
            {
                id: _batteryBtn
                visible: false
                iconName: "battery"
            }
        }


            Maui.FileBrowser
            {
                id: _page2

            }


        Maui.Page
        {
            id: _page3
            margins: 0
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

//        Maui.Store
//        {
//            id: _page4
//        }
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
