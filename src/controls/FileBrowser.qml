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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.12

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import "private"

Maui.Page
{
	id: control
	
	//aliases
	
	property alias currentPath : _browser.path 	
	property alias settings : _browser.settings
	
	
	property alias view : _browser
	property alias currentView : _browser.currentView
	readonly property Maui.FMList currentFMList : view.currentFMList
	readonly property Maui.BaseModel currentFMModel : view.currentFMModel
	
	// custom props
	property bool selectionMode: false	
	property bool showStatusBar : Maui.FM.loadSettings("StatusBar", "SETTINGS", false) == "true"
	
	property int thumbnailsSize : Maui.Style.iconSizes.large * 1.7
	
	property var indexHistory : []
	
	property bool isCopy : false
	property bool isCut : false
	
	property bool group : false
	
	// need to be set by the implementation
	property MauiLab.SelectionBar selectionBar : null		
	property Maui.FilePreviewer previewer : null

	property alias menu : browserMenu.contentData
	property alias browserMenu: browserMenu
	property alias itemMenu: itemMenu
	property alias dialog : dialogLoader.item	
	
	//signals
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)
	signal itemRightClicked(int index)
	signal itemLeftEmblemClicked(int index)
	signal itemRightEmblemClicked(int index)
	signal rightClicked()
	signal keyPress(var event)
	
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	Kirigami.Theme.inherit: false
	
	onGoBackTriggered: control.goBack()
	onGoForwardTriggered: control.goNext()
	
	focus: true
	
	flickable: control.currentView.flickable
	
	footBar.visible: control.showStatusBar ||  String(control.currentPath).startsWith("trash:/")
	
	footBar.leftSretch: false
	footBar.middleContent: Maui.TextField
	{
		id: _filterField
		Layout.fillWidth: true
		visible: control.currentFMList.count > 0
		placeholderText: String("Filter %1 files").arg(control.currentFMList ? control.currentFMList.count : 0)
		onAccepted: control.view.filter = text
		onCleared: control.view.filter = ""
		inputMethodHints: Qt.ImhNoAutoUppercase
		onTextChanged:
		{
			if(control.currentFMList.count < 50)
				_filterField.accepted()
		}
		Keys.enabled: true
		Keys.onPressed:
		{
			// Shortcut for clearing selection
			if(event.key == Qt.Key_Up)
			{
				// 				_filterField.clear()
				// 				footBar.visible = false
				control.currentView.forceActiveFocus()
			}
		}
	}
	
	footBar.rightContent: [
	
// 	ToolButton
// 	{
// 		icon.name: "zoom-in"
// 		onClicked: zoomIn()
// 	},
// 	
// 	ToolButton
// 	{
// 		icon.name: "zoom-out"
// 		onClicked: zoomOut()
// 	},
// 	
	ToolButton
	{
		visible: String(control.currentPath).startsWith("trash:/")
		icon.name: "trash-empty"
		text: qsTr("Empty Trash")
		onClicked: Maui.FM.emptyTrash()
	}
	]
	
	footerPositioning: ListView.InlineFooter
	Loader { id: dialogLoader }
	
	Component
	{
		id: removeDialogComponent
		
		Maui.Dialog
		{
			property var urls: []
			
			title:  "Removing %1 files".arg(urls.length)
			message: Maui.Handy.isAndroid ?  qsTr("This action will completely remove your files from your system. This action can not be undone.") : qsTr("You can move the file to the trash or delete it completely from your system. Which one do you prefer?")
			rejectButton.text: qsTr("Delete")
			acceptButton.text: qsTr("Trash")
			acceptButton.visible: Maui.Handy.isLinux
			page.padding: Maui.Style.space.huge
			
			onRejected:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.animate()
					control.clearSelection()
				}
				
				for(var i in urls)
					Maui.FM.removeFile(urls[i])
					
					close()
			}
			
			onAccepted:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.animate()
					control.clearSelection()
				}
				
				for(var i in urls)
					Maui.FM.moveToTrash(urls[i])
					close()
			}
		}
	}
	
	Component
	{
		id: newFolderDialogComponent
		
		Maui.NewDialog
		{
			title: qsTr("New Folder")
			message: qsTr("Create a new folder with a custom name")
			acceptButton.text: qsTr("Create")
			onFinished: control.currentFMList.createDir(text)
			rejectButton.visible: false
			textEntry.placeholderText: qsTr("Folder name")
		}
	}
	
	Component
	{
		id: newFileDialogComponent
		
		Maui.NewDialog
		{
			title: qsTr("New File")
			message: qsTr("Create a new file with a custom name and extension")
			acceptButton.text: qsTr("Create")
			onFinished: Maui.FM.createFile(control.currentPath, text)
			rejectButton.visible: false
			textEntry.placeholderText: qsTr("Filename")
		}
	}
	
	Component
	{
		id: renameDialogComponent
		Maui.NewDialog
		{
            property var item : control.currentFMList ? control.currentFMList.get(control.currentView.currentIndex) : ({})
			title: qsTr("Rename File")
			message: qsTr("Rename a file or folder")
			textEntry.text: item.label
			textEntry.placeholderText: qsTr("New name")
			onFinished: Maui.FM.rename(item.path, textEntry.text)
			onRejected: close()
			acceptText: qsTr("Rename")
			rejectText: qsTr("Cancel")
		}
	}
	
	Component
	{
        id: shareDialogComponent
        MauiLab.ShareDialog {}
    }
    
    Component
    {
        id: openWithDialogComponent
        Maui.OpenWithDialog {}
    }
	
	Component
	{
		id: tagsDialogComponent
		Maui.TagsDialog
		{
			taglist.strict: false
			onTagsReady:
			{
				composerList.updateToUrls(tags)
				if(control.previewer && control.previewer.visible)
					control.previewer.tagBar.list.refresh()
			}
		}
	}
	
	BrowserMenu { id: browserMenu }
	
	FileMenu
	{
		id: itemMenu
		width: Maui.Style.unit *200
		onBookmarkClicked: control.bookmarkFolder([item.path])
		onCopyClicked:
		{
			if(item)
				control.copy([item.path])
		}
		
		onCutClicked:
		{
			if(item)
				control.cut([item.path])
		}
		
		onTagsClicked:
		{
			if(item)
			{
				dialogLoader.sourceComponent = tagsDialogComponent
				dialog.composerList.urls = [item.path]
				dialog.open()
			}
		}
		
		onRenameClicked:
		{
			dialogLoader.sourceComponent = renameDialogComponent
			dialog.open()
		}
		
		onRemoveClicked:
		{
			console.log("REMOVE", item.path)
			control.remove([item.path])
		}
		
		onOpenWithClicked: control.openWith([item.path])
		onShareClicked: control.shareFiles([item.path])
	}
	
	Connections
	{
// 		enabled: control.currentView != null
		target: control.currentView
		
		onKeyPress:
		{
			const index = control.currentView.currentIndex
			const item = control.currentFMList.get(index)
			
			// Shortcuts for refreshing
			if((event.key == Qt.Key_F5))
			{
				control.currentFMList.refresh()
			}
			
			// Shortcuts for renaming
			if((event.key == Qt.Key_F2))
			{
				dialogLoader.sourceComponent = renameDialogComponent
				dialog.open()
			}
			
			// Shortcuts for selecting file
			if((event.key == Qt.Key_A) && (event.modifiers & Qt.ControlModifier))
			{
				control.selectAll()
			}
			
			if(event.key == Qt.Key_S)
			{
				if(control.selectionBar && control.selectionBar.contains(item.path))
				{
					control.selectionBar.removeAtUri(item.path)
				}else
				{
					control.addToSelection(item)
				}
			}
			
			if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
			{
				if(control.selectionBar && control.selectionBar.contains(item.path))
				{
					control.selectionBar.removeAtUri(item.path)
				}else
				{
					control.addToSelection(item)
				}
			}
			
			//shortcut for opening files
			if((event.key == Qt.Key_Return) && (event.modifiers & Qt.AltModifier))
			{
				control.previewer.show(currentFMModel, index)
			}else if(event.key == Qt.Key_Return)
			{
				indexHistory.push(index)
				control.openItem(index)				
			}
			
			// Shortcut for pasting an item
			if((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier))
			{
				control.paste(Maui.Handy.getClipboard().urls)
			}
			
			// Shortcut for cutting an item
			if((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier))
			{
				var urls = []
				if(control.selectionBar && control.selectionBar.count > 0)
				{
					urls = control.selectionBar.uris
				}
				else
				{
					urls = [item.path]
				}
				control.cut(urls)
			}
			
			// Shortcut for copying an item
			if((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier))
			{
				var urls = []
				if(control.selectionBar && control.selectionBar.count > 0)
				{
					urls = control.selectionBar.uris
				}
				else
				{
					urls = [item.path]
				}
				control.copy(urls)
			}
			
			// Shortcut for removing an item
			if(event.key == Qt.Key_Delete)
			{
				var urls = []
				if(control.selectionBar && control.selectionBar.count > 0)
				{
					urls = control.selectionBar.uris
				}
				else
				{
					urls = [item.path]
				}
				control.remove(urls)
			}
			
			
			// Shortcut for going back in browsing history
			if(event.key == Qt.Key_Backspace || event.key == Qt.Key_Back)
			{
				if(control.selectionBar && control.selectionBar.count> 0)
					control.clearSelection()
					else
						control.goBack()
			}
			
			// Shortcut for clearing selection and filtering
			if(event.key == Qt.Key_Escape)
			{
				if(control.selectionBar && control.selectionBar.count > 0)
					control.clearSelection()
					
					control.view.filter = ""
			}
			
			//Shortcut for opening filtering
			if((event.key == Qt.Key_F) && (event.modifiers & Qt.ControlModifier))
            {
                control.toggleStatusBar()				
            }
            
            if(event.key == Qt.Key_Space)
            {
				if(control.previewer)
					control.previewer.show(currentFMModel, index)
                
            }
            
            control.keyPress(event)
            //             event.accepted = true
        }
        
		onItemsSelected:
		{
			control.selectIndexes(indexes)
		}
		
		onItemClicked:
		{
			control.currentView.currentIndex = index
			indexHistory.push(index)
			control.itemClicked(index)
			control.currentView.forceActiveFocus()
		}
		
		onItemDoubleClicked:
		{
			control.currentView.currentIndex = index
			indexHistory.push(index)
			control.itemDoubleClicked(index)
			control.currentView.forceActiveFocus()
		}
		
		onItemRightClicked:
		{
			if(control.currentFMList.pathType !== Maui.FMList.TRASH_PATH && control.currentFMList.pathType !== Maui.FMList.REMOTE_PATH)
			{
				itemMenu.show(index)
			}
			control.itemRightClicked(index)
			control.currentView.forceActiveFocus()
		}
		
		onLeftEmblemClicked:
		{
			const item = control.currentFMList.get(index)
			
			if(control.selectionBar && control.selectionBar.contains(item.path))
			{
				control.selectionBar.removeAtUri(item.path)
			}else
			{
				control.addToSelection(item)
			}
			control.itemLeftEmblemClicked(index)
			control.currentView.forceActiveFocus()
		}
		
		onRightEmblemClicked:
		{
			Maui.Handy.isAndroid ? Maui.Android.shareDialog([control.currentFMList.get(index).path]) : shareDialog.show([control.currentFMList.get(index).path])
			control.itemRightEmblemClicked(index)
		}
		
		onAreaClicked:
		{
			if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
				browserMenu.show(control)
				else return
					
					control.rightClicked()
					control.currentView.forceActiveFocus()
		}
		
		onAreaRightClicked: browserMenu.show(control)

        //        onWarning:
        //        {
        //            notify("dialog-information", "An error happened", message)
        //        }

        //        onProgress:
        //        {
        //            if(percent === 100)
        //                _progressBar.value = 0
        //            else
        //                _progressBar.value = percent/100
        //        }
    }

    
//     ObjectModel { id: tabsObjectModel }

    BrowserView
    {
		id: _browser
		anchors.fill: parent
	}
    

    Component.onCompleted:
    {
        control.currentView.forceActiveFocus()
    }

//     onThumbnailsSizeChanged:
//     {
//         if(settings.trackChanges && settings.saveDirProps)
//             Maui.FM.setDirConf(currentPath+"/.directory", "MAUIFM", "IconSize", thumbnailsSize)
//             else
//                 Maui.FM.saveSettings("IconSize", thumbnailsSize, "SETTINGS")
// 
//                 if(view.viewType === Maui.FMList.ICON_VIEW)
//                     control.currentView.adaptGrid()
//     }

   
    
    function tagFiles(urls)
    {
        dialogLoader.sourceComponent = tagsDialogComponent
                dialog.composerList.urls = urls
                dialog.open()
    }
    
    function openWith(urls)
    {
        if(urls.length <= 0)
            return;

        dialogLoader.sourceComponent= openWithDialogComponent
        dialog.urls = urls
        dialog.open()
    }

    function shareFiles(urls)
    {
        if(urls.length <= 0)
            return;

        dialogLoader.sourceComponent= shareDialogComponent
        dialog.urls = urls
        dialog.open()
    }

    function openItem(index)
    {
        const item = control.currentFMList.get(index)
        const path = item.path

        switch(control.currentFMList.pathType)
        {
            case Maui.FMList.CLOUD_PATH:
                if(item.isdir === "true")
                {
                    control.openFolder(path)
                }
                else
                {
                    Maui.FM.openCloudItem(item)
                }
                break;
            default:
                if(control.selectionMode && item.isdir == "false")
                {
					if(control.selectionBar && control.selectionBar.contains(item.path))
                    {
                        control.selectionBar.removeAtPath(item.path)
                    }else
                    {
                        control.addToSelection(item)
                    }
                }
                else
                {
                    if(item.isdir == "true")
                    {
                        control.openFolder(path)
                    }
                    else
                    {
						if (Kirigami.Settings.isMobile && control.previewer)
                        {
                            control.previewer.show(currentFMModel, index)
                        }
                        else
                        {
                            control.openFile(path)
                        }
                    }
                }
        }
    }

    function openFile(path)
    {
        Maui.FM.openUrl(path)
    }

    function openFolder(path)
    {
        if(!String(path).length)
            return;

        control.currentPath = path
    }

    function goBack()
    {
        openFolder(control.currentFMList.previousPath)
        //        control.currentView.currentIndex = indexHistory.pop()
    }

    function goNext()
    {
        openFolder(control.currentFMList.posteriorPath)
    }

    function goUp()
    {
        openFolder(control.currentFMList.parentPath)
    }

    function refresh()
    {
        const pos = control.currentView.contentY
        control.currentView.contentY = pos
    }

    function addToSelection(item)
    {
		if(item.path.startsWith("tags://") || item.path.startsWith("applications://") )
		{
			return
		}
		
		if(control.selectionBar)			
		{
			control.selectionBar.append(item.path, item)			
		} 		
	}
	
	function clearSelection()
	{
		if(control.selectionBar)
		{
			control.selectionBar.clear()
			control.selectionMode = false
		}
	}
	
    function copy(urls)
    {
        Maui.Handy.copyToClipboard({"urls": urls})
        control.isCut = false
        control.isCopy = true
    }

    function cut(urls)
    {
        Maui.Handy.copyToClipboard({"urls": urls})
        control.isCut = true
        control.isCopy = false
    }

    function paste()
    {
        const urls = Maui.Handy.getClipboard().urls

        if(!urls)
            return

            if(control.isCut)
            {
                control.currentFMList.cutInto(urls)
                control.clearSelection()
            }else
            {
                control.currentFMList.copyInto(urls)
            }
    }

    function remove(urls)
    {
        dialogLoader.sourceComponent= removeDialogComponent
        dialog.urls = urls
        dialog.open()
    }
    
    function selectIndexes(indexes)
    {
        for(var i in indexes)
             addToSelection(control.currentFMList.get(indexes[i]))
    }

    function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
    {
        selectIndexes([...Array( Math.min(control.currentFMList.count, 100)).keys()])       
    }

    function bookmarkFolder(paths) //multiple paths
    {
        for(var i in paths)
        {
			Maui.FM.bookmark(paths[i])
		}
    }

    function zoomIn()
    {
        control.control.currentView.resizeContent(1.2)
    }
    
    function zoomOut()
    {
        control.control.currentView.resizeContent(0.8)
        
    }

    function groupBy()
    {
        var prop = ""
        var criteria = ViewSection.FullString

        switch(control.currentFMList.sortBy)
        {
            case Maui.FMList.LABEL:
                prop = "label"
                criteria = ViewSection.FirstCharacter
                break;
            case Maui.FMList.MIME:
                prop = "mime"
                break;
            case Maui.FMList.SIZE:
                prop = "size"
                break;
            case Maui.FMList.DATE:
                prop = "date"
                break;
            case Maui.FMList.MODIFIED:
                prop = "modified"
                break;
        }

        if(!prop)
        {
            control.control.currentView.section.property = ""
            return
        }

        control.settings.viewType = Maui.FMList.LIST_VIEW
        control.control.currentView.section.property = prop
        control.control.currentView.section.criteria = criteria
    }
    
    function toggleStatusBar()
    {
        control.footBar.visible = !control.footBar.visible
        Maui.FM.saveSettings("StatusBar",  control.footBar.visible, "SETTINGS")	
        
        if(control.footBar.visible)
        {
            _filterField.forceActiveFocus()
        }else
        {
            control.currentView.forceActiveFocus()
        }
    }
}
