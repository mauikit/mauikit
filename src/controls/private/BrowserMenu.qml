    import QtQuick 2.9
    import QtQuick.Controls 2.3
    import QtQuick.Layouts 1.3
    import org.kde.mauikit 1.0 as Maui
    import org.kde.kirigami 2.6 as Kirigami
    
    Menu
    { 
        property int pasteFiles : 0
        
        //   popup.z : 999
        
        /* Maui.MenuItem
         *        {
         *            che
         *            ckable: true
         *            checked: saveDirProps
         *            text: qsTr("Per dir props")
         *            onTriggered: saveDirProps = !saveDirProps
    }*/
        property list<QtObject> actions:
        [
        
        Action
        {
            id: _previewAction
            icon.name: "image-preview"
            text: qsTr("Previews")
            checkable: true
            checked: list.preview
            onTriggered:
            {
                list.preview = !list.preview
                close()
            }
        },
        
        Action
        {
            id: _hiddenAction
            
            icon.name: "visibility"
            
            text: qsTr("Hidden files")
            checkable: true
            checked: list.hidden
            onTriggered:
            {
                list.hidden = !list.hidden
                close()
            }
        },
        
        Action
        {
            id: _bookmarkAction
            
            icon.name: "bookmark-new"
            text: qsTr("Bookmark")            
            onTriggered: 
            {
                newBookmark([currentPath])
                close()
            }
        },
        
        
        
        Action
        {
            id: _newFolderAction
            
            icon.name: "folder-add"
            text: qsTr("New folder")
            onTriggered: 
            {
                dialogLoader.sourceComponent= newFolderDialogComponent
                dialog.open()
                close()
            }
        },
        
        Action
        {
            id: _newDocumentAction
            icon.name: "document-new"
            text: qsTr("New file")
            onTriggered: 
            {
                dialogLoader.sourceComponent= newFileDialogComponent
                dialog.open()
                close()
            }
        },
        
        
        Action
        {
            id: _pasteAction
            text: qsTr("Paste ")+"["+pasteFiles+"]"
            enabled: pasteFiles > 0
            onTriggered: paste()
        }
        
        
        /* Maui.MenuItem
         *        {
         *            width: parent.width
         * 
         *            RowLayout
         *            {
         *                anchors.fill: parent
         *                Maui.ToolButton
         *                {
         *                    Layout.fillHeight: true
         *                    Layout.fillWidth: true
         *                    iconName: "list-add"
         *                    onClicked: zoomIn()
    }
    
    Maui.ToolButton
    {
    Layout.fillHeight: true
    Layout.fillWidth: true
    iconName: "list-remove"
    onClicked: zoomOut()
    }
    }
    }*/
        ]
        
        MenuItem
        {
            action: _previewAction
        }
        
        MenuItem
        {
            action: _hiddenAction
        }
        
        MenuItem
        {
            action: _bookmarkAction
        }
        
        MenuItem
        {
            action: _newFolderAction
        }
        
        MenuItem
        {
            action: _newDocumentAction
        }
        
        
        MenuItem
        {
            action: _pasteAction
        }
        
        
        function show()
        {
            if(currentPathType === Maui.FMList.PLACES_PATH || currentPathType === Maui.FMList.TAGS_PATH || currentPathType === Maui.FMList.CLOUD_PATH)
            {
                if(isCopy)
                    pasteFiles = copyItems.length
                    else if(isCut)
                        pasteFiles = cutItems.length
                        
                        popup()
            }
        }
    }
    
