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

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import "private" as Private

Maui.Page
{
	id: control
	
	//aliases	
	property alias currentPath : _browser.path 	
	onCurrentPathChanged : _filterField.clear()
    
	property alias settings : _browser.settings	
	
	property alias view : _stackView.currentItem
	
	readonly property QtObject currentView : _stackView.currentItem.currentView	
	readonly property Maui.FMList currentFMList : view.currentFMList
	readonly property Maui.BaseModel currentFMModel : view.currentFMModel
	readonly property bool isSearchView : _stackView.currentItem.objectName === "searchView"
	
	// custom props
	property bool selectionMode: false	
	property bool showStatusBar : Maui.FM.loadSettings("StatusBar", "SETTINGS", false) == "true"
	
	property int thumbnailsSize : Maui.Style.iconSizes.large * 1.7
	
	property var indexHistory : []
	
	// need to be set by the implementation as features
	property MauiLab.SelectionBar selectionBar : null		
	property Maui.FilePreviewer previewer : null
	property Maui.TagsDialog tagsDialog : null
	property MauiLab.ShareDialog shareDialog : null
	property Maui.OpenWithDialog openWithDialog : null
	
	//relevant menus to file item and the browserview
	property alias browserMenu: browserMenu
	property alias itemMenu: itemMenu
	
	//access to the loaded the dialog components
	property alias dialog : dialogLoader.item	
	
	//signals
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)
	signal itemRightClicked(int index)
	signal itemLeftEmblemClicked(int index)
	signal itemRightEmblemClicked(int index)
	signal rightClicked()
	signal keyPress(var event)
	signal urlsDropped(var urls)
	
	//color scheme
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	Kirigami.Theme.inherit: false
	
	//catch inherited signals from page
	onGoBackTriggered: control.goBack()
	onGoForwardTriggered: control.goNext()	
	
	title: view.title
	focus: true	
	flickable: control.currentView.flickable
	
	showTitle: false
	headBar.visible: false
	headBar.leftContent: ToolButton
	{
		text: qsTr("Back")
		icon.name: "go-previous"
		onClicked: control.quitSearch()		
		visible: control.isSearchView		
	}
	
	headBar.middleContent: Maui.TextField
	{
		id: _searchField
		Layout.fillWidth: true
		placeholderText: qsTr("Search")
		onAccepted: control.search(text)
	}
	
	footBar.visible: control.showStatusBar ||  String(control.currentPath).startsWith("trash:/")
	
	footBar.leftSretch: false
	footerPositioning: ListView.InlineFooter
	
	footBar.middleContent: Maui.TextField
	{
		id: _filterField
		Layout.fillWidth: true
		enabled: control.currentFMList.count > 0
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
	
	footBar.rightContent: ToolButton
	{
		visible: String(control.currentPath).startsWith("trash:/")
		icon.name: "trash-empty"
		text: qsTr("Empty Trash")
		onClicked: Maui.FM.emptyTrash()
	}	
	
	Loader 
	{ 
		id: dialogLoader 
// 		active: item && item.visible
	}
	
	Component
	{
		id: removeDialogComponent
		
		Maui.Dialog
		{
            id: _removeDialog
			property var urls: []
			
			title:  "Removing %1 files".arg(urls.length)
			message: Maui.Handy.isAndroid ?  qsTr("This action will completely remove your files from your system. This action can not be undone.") : qsTr("You can move the file to the trash or delete it completely from your system. Which one do you prefer?")
			rejectButton.text: qsTr("Delete")
			acceptButton.text: qsTr("Trash")
			acceptButton.visible: Maui.Handy.isLinux
			page.margins: Maui.Style.space.huge
			
			ColumnLayout
			{
                Layout.fillWidth: true                
                
                CheckBox
                {
                    id: _removeDialogFilesCheckBox
                    Layout.fillWidth: true
                    
                    text: qsTr("List files")
                }
                
                Kirigami.ScrollablePage
                {
                    visible: _removeDialogFilesCheckBox.checked
                    
                    Layout.fillWidth: true
                    Layout.maximumHeight: 200
                    padding: 0
                    topPadding: 0
                    leftPadding: 0
                    rightPadding: 0
                                        
                    TextArea
                    {
                        wrapMode: Text.WordWrap
                        text: urls.join("\n\n")
                        readOnly: true
                        background: null
                    }
                }               
            }
			
			onRejected:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.animate()
					control.clearSelection()
				}	
				
				Maui.FM.removeFiles(urls)					
				close()
			}
			
			onAccepted:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.animate()
					control.clearSelection()
				}
				
				Maui.FM.moveToTrash(urls)
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
	
	Private.BrowserMenu { id: browserMenu }
	
	Private.FileMenu
	{
		id: itemMenu
		width: Maui.Style.unit * 200
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
			if(item && control.tagsDialog)
			{
				control.tagsDialog.composerList.urls = [item.path]
				control.tagsDialog.open()
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
		target: control.previewer.tagBar
		enabled: control.previewer && control.tagsDialog
	
		onAddClicked:
		{			
			if(control.tagsDialog)
			{
				control.tagsDialog.composerList.urls = [ control.previewer.currentUrl]
				control.tagsDialog.open()
			}			
		}
	}
	
	Connections
	{
		target: control.tagsDialog
		enabled: control.tagsDialog && control.previewer
		
		onTagsReady:
		{
			control.tagsDialog.composerList.updateToUrls(tags)
			if(control.previewer && control.previewer.visible)
				control.previewer.tagBar.list.refresh()
		}
	}
	
	Connections
	{
		target: control.previewer
		enabled: control.previewer
		onShareButtonClicked: control.shareFiles([url])		
		onOpenButtonClicked: control.openFile(url)		
	}
	
	Connections
	{
		enabled: control.currentView
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
				if(control.previewer)
				{
					control.previewer.show(currentFMModel, index)					
				}
				
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
				{
					control.clearSelection()					
				}				
				else
				{
					control.goBack()					
				}				
			}
			
			// Shortcut for clearing selection and filtering
			if(event.key == Qt.Key_Escape) //TODO not working, the event is not catched or emitted or is being accepted else where?
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
		
		onItemToggled:
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
    
    StackView
    {
		id: _stackView

		anchors.fill: parent
		clip: true
		
		initialItem: DropArea
		{
			id: _dropArea
			property alias currentView : _browser.currentView
			property alias currentFMList : _browser.currentFMList
			property alias currentFMModel: _browser.currentFMModel
			property alias filter: _browser.filter
			property alias title : _browser.title
			
			onDropped:
			{
				if(drop.urls)
				{
					_dropMenu.urls = drop.urls.join(",")
					_dropMenu.popup()
					control.urlsDropped(drop.urls)
				}
			}
			
			opacity:  _dropArea.containsDrag ? 0.5 : 1
			
			Private.BrowserView
			{
				id: _browser
				anchors.fill: parent
			}  		
			
			Menu
			{
				id: _dropMenu
				property string urls
				enabled: Maui.FM.getFileInfo(control.currentPath).isdir == "true" 
				
				MenuItem
				{
					text: qsTr("Copy here")
					onTriggered:
					{
						const urls = _dropMenu.urls.split(",")
						Maui.FM.copy(urls, control.currentPath, false)
					}
				}
				
				MenuItem
				{
					text: qsTr("Move here")
					onTriggered:
					{
						const urls = _dropMenu.urls.split(",")
						Maui.FM.cut(urls, control.currentPath)
					}
				}
				
				MenuItem
				{
					text: qsTr("Link here")
					onTriggered:
					{
						const urls = _dropMenu.urls.split(",")
						for(var i in urls)
							Maui.FM.createSymlink(urls[i], control.currentPath)
					}
				}
			}
		}
		
		Component
		{
			id: _searchBrowserComponent
			
			Private.BrowserView 
			{
				id: _searchBrowser
				objectName: "searchView"	
				settings.viewType: control.settings.viewType === Maui.FMList.MILLERS_VIEW ? Maui.FMList.LIST_VIEW : control.settings.viewType // do not use millersview it does not makes sense since search does not follow a path url structures
			}
		}
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
		if(urls.length <= 0)
		{
			return
		}
		
		if(control.tagsDialog)
		{
			control.tagsDialog.composerList.urls = urls
			control.tagsDialog.open()
		}
    }
    
    function openWith(urls)
    {
        if(urls.length <= 0)
        {
			return
		}

		if(control.openWithDialog)
		{
			openWithDialog.urls = urls
			openWithDialog.open()
		}
	}

    function shareFiles(urls)
    {
		if(urls.length <= 0)
		{
			return
		}
		
		if(control.shareDialog)
		{			
			control.shareDialog.urls = urls
			control.shareDialog.open()
		}
	}
    
    function copy(urls)
	{
		if(urls.length <= 0)
		{
			return
		}
		
		Maui.Handy.copyToClipboard({"urls": urls}, false)
	}
	
	function cut(urls)
	{
		if(urls.length <= 0)
		{
			return
		}
		
		Maui.Handy.copyToClipboard({"urls": urls}, true)
	}
	
	function paste()
    {
        const data = Maui.Handy.getClipboard()
        const urls = data.urls
        
        if(!urls)
        {
            return
        }
        if(data.cut)
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
		if(urls.length <= 0)
		{
			return
		}
		
		dialogLoader.sourceComponent= removeDialogComponent
		dialog.urls = urls
		dialog.open()
	}

    function openItem(index)
    {
        const item = control.currentFMList.get(index)
        const path = item.path

        switch(control.currentFMList.pathType)
        {
            case Maui.FMList.CLOUD_PATH: //TODO deprecrated and needs to be removed or clean up for 1.1
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
		{
			return;
		}

		if(control.isSearchView)
		{
			control.quitSearch()
		}
			
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
   
   // for this to work the implementation needs to have passed a selectionBar   
    function addToSelection(item)
    {
		if(control.selectionBar == null || item.path.startsWith("tags://") || item.path.startsWith("applications://"))
		{
			return
		}
		
		control.selectionBar.append(item.path, item)		
	}
	
	function clearSelection()
	{
		if(control.selectionBar)
		{
			control.selectionBar.clear()
		}
	}
    //given a list inf indexes add them to the selectionBar
    function selectIndexes(indexes)
    {
		if(control.selectionBar == null)
		{
			return
		}
		
        for(var i in indexes)
             addToSelection(control.currentFMList.get(indexes[i]))
    }

    function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
    {
		if(control.selectionBar == null)
		{
			return
		}
		
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
        control.currentView.resizeContent(1.2)
    }
    
    function zoomOut()
    {
        control.currentView.resizeContent(0.8)        
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
    
    function openSearch()
	{
		if(!control.isSearchView)
		{
			_stackView.push(_searchBrowserComponent, StackView.Immediate)			
		}
		_searchField.forceActiveFocus()
	}
	
	function quitSearch()
	{
		_stackView.pop(StackView.Immediate)
		control.headBar.visible = false
	}
    
    function search(query)
	{
		openSearch()
		_stackView.currentItem.title = qsTr("Search: %1").arg(query)
		_stackView.currentItem.currentFMList.search(query, _browser.currentFMList)
	}	
}
