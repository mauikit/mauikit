import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "private"

Maui.Page
{
	id: control
	
	property alias trackChanges: modelList.trackChanges
	property alias saveDirProps: modelList.saveDirProps
	
	property string currentPath: Maui.FM.homePath()
	
	property var copyItems : []
	property var cutItems : []
	
	property var indexHistory : []
	
	property bool isCopy : false
	property bool isCut : false
	
	property bool selectionMode : false
	property bool group : false
	property bool showEmblems: true
	property bool singleSelection: false
	
	property alias selectionBar : selectionBarLoader.item
	
	property alias model : folderModel
	property alias list : modelList
	property alias browser : viewLoader.item
	property var currentFMList : modelList
	
	property alias previewer : previewer
	property alias menu : browserMenu.contentData
	property alias itemMenu: itemMenu
	property alias holder: holder
	property alias dialog : dialogLoader.item
	property alias goUpButton : goUpButton
	
	property int currentPathType : currentFMList.pathType
	property int thumbnailsSize : iconSizes.large
	
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)
	signal itemRightClicked(int index)
	signal itemLeftEmblemClicked(int index)
	signal itemRightEmblemClicked(int index)
	signal rightClicked()
	signal newBookmark(var paths)
	
	focus: true	
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	Kirigami.Theme.inherit: false
// 	Kirigami.Theme.backgroundColor: Kirigami.Theme.viewBackgroundColor
	
	Loader
	{
		id: dialogLoader
	}
	
	Component
	{
		id: removeDialogComponent
		
		Maui.Dialog
		{
			property var items: []
		
			title: qsTr("Remove files?")
			message: qsTr("You can move the file to the Trash or Delete it completely from your system. Which one you preffer?")
			rejectButton.text: qsTr("Delete")
			acceptButton.text: qsTr("Trash")
// 			acceptButton.Kirigami.Theme.backgroundColor: Qt.rgba(Kirigami.Theme.neutralTextColor.r, Kirigami.Theme.neutralTextColor.g, Kirigami.Theme.neutralTextColor.b, 0.2)
// 			acceptButton.Kirigami.Theme.textColor: Kirigami.Theme.neutralTextColor
			onRejected: 
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.clear()
					control.selectionBar.animate(Maui.Style.dangerColor)
				}
				
				control.remove(items)
				close()
			}
			
			onAccepted:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.clear()
					control.selectionBar.animate(Maui.Style.dangerColor)
				}
				
				control.trash(items)
				close()
			}
		}
	}
	
	Component
	{
		id: newFolderDialogComponent
		
		Maui.NewDialog
		{
			title: qsTr("New folder")
			message: qsTr("Create a new folder with a custom name")
			acceptButton.text: qsTr("Create")
			onFinished: list.createDir(text)
			rejectButton.visible: false
			textEntry.placeholderText: qsTr("Folder name...")
		}
	}
	
	Component
	{
		id: newFileDialogComponent
		
		Maui.NewDialog
		{
			title: qsTr("New file")
			message: qsTr("Create a new file with a custom name and extension")
			acceptButton.text: qsTr("Create")
			onFinished: Maui.FM.createFile(control.currentPath, text)
			rejectButton.visible: false
			textEntry.placeholderText: qsTr("File name...")
		}
	}
	
	Component
	{
		id: renameDialogComponent
		Maui.NewDialog
		{
			title: qsTr("Rename file")
			message: qsTr("Rename a file or folder to a new custom name")
			textEntry.text: itemMenu.item.label
			textEntry.placeholderText: qsTr("New name...")
			onFinished: Maui.FM.rename(itemMenu.item.path, textEntry.text)
			onRejected: close()
			acceptText: qsTr("Rename")
			rejectText: qsTr("Cancel")
		}
	}
	
	Component
	{
		id: shareDialogComponent
		Maui.ShareDialog {}
	}
	
	Component
	{
		id: tagsDialogComponent
		Maui.TagsDialog
		{
			onTagsReady: composerList.updateToUrls(tags)
		}
	}	
	
	BrowserMenu
	{
		id: browserMenu
		// 		width: unit *200	
		z : control.z +1
	}
	
	Maui.FilePreviewer
	{
		id: previewer
		parent: parent
		onShareButtonClicked: control.shareFiles([url])
	}
	
	Maui.BaseModel
	{
		id: folderModel
		list: modelList
	}
	
	Maui.FMList
	{
		id: modelList
		preview: true
		path: currentPath
		foldersFirst: true
		onSortByChanged: if(group) groupBy()
		onContentReadyChanged: console.log("CONTENT READY?", contentReady)
		onWarning:
		{			
			notify("dialog-information", "An error happened", message)
		}
		
		onProgress:
		{
			if(percent === 100)
				_progressBar.value = 0
				else
					_progressBar.value = percent/100
		}
	}	
	
	FileMenu
	{
		id: itemMenu
		width: unit *200
		onBookmarkClicked: control.newBookmark([item.path])
		onCopyClicked:
		{
			if(item)
				control.copy([item])			
		}
		
		onCutClicked:
		{
			if(item)
				control.cut([item])			
		}
		
		onTagsClicked:
		{
			if(item)
			{
				dialogLoader.sourceComponent = tagsDialogComponent
				dialog.composerList.urls = item.path
				dialog.open()
			}
		}
		
		onRenameClicked:
		{			
				dialogLoader.sourceComponent = renameDialogComponent
				dialog.open()
			
		}
		
		//        onSaveToClicked:
		//        {
		//            fmDialog.saveDialog = false
		//            fmDialog.multipleSelection = true
		//            fmDialog.onlyDirs= true
		
		//            var myPath = path
		
		//            var paths = browser.selectionBar.selectedPaths
		//            fmDialog.show(function(paths)
		//            {
		//                inx.copy(myPath, paths)
		//            })
		//        }
		
		onRemoveClicked:
		{
			dialogLoader.sourceComponent= removeDialogComponent
			dialog.items = [item]
			dialog.open()
		}
		
		onShareClicked: control.shareFiles([item.path])
		
	}
	
	Component
	{
		id: listViewBrowser
		
		Maui.ListBrowser
		{
			showPreviewThumbnails: modelList.preview
			keepEmblemOverlay: selectionMode
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "list-add"
			showDetailsInfo: true
			// 			itemSize: thumbnailsSize
			model: folderModel
			section.delegate: Maui.LabelDelegate
			{
				id: delegate
				label: section
				labelTxt.font.pointSize: fontSizes.big
				
				isSection: true
				boldLabel: true
				height: toolBarHeightAlt
			}
		}
	}
	
	Component
	{
		id: gridViewBrowser
		
		Maui.GridBrowser
		{
			itemSize : thumbnailsSize + fontSizes.default
			keepEmblemOverlay: selectionMode
			showPreviewThumbnails: modelList.preview
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "list-add"
			model: folderModel
		}
	}
	
	Component
	{
		id: millerViewBrowser
		
		Kirigami.ColumnView
		{
			id: _millerColumns
			columnWidth: Math.min(Kirigami.Units.gridUnit * 22, control.width)			
// 			fillWidth: true
            columnResizeMode: Kirigami.ColumnView.DynamicColumns
			
			signal itemClicked(int index)
			signal itemDoubleClicked(int index)
			signal itemRightClicked(int index)
			
			signal rightEmblemClicked(int index)
			signal leftEmblemClicked(int index)
			
			signal areaClicked(var mouse)
			signal areaRightClicked() 
			
			Maui.PathList
			{
				id: _millerList
				path: control.currentPath
				onPathChanged: _millerColumns.currentIndex = _repeater.count - 1	
			}
			
			Maui.BaseModel
			{
				id: _millerModel
				list: _millerList
			}
			
			Repeater
			{
				id: _repeater
				model: _millerModel
				
				onItemAdded: 
				{
//                     if(viewLoader.sourceComponent === millerViewBrowser)
//                     _millerColumns.currentIndex = _millerColumns.count-1
					
// 					_millerColumns.contentX= _millerColumns.columnWidth * _millerColumns.count
                }
				
				Item
				{
					Maui.FMList
					{	
						id: _millersFMList
						preview: modelList.preview
						path: model.path
						foldersFirst: modelList.foldersFirst
						onWarning:
						{			
							notify("dialog-information", "An error happened", message)
						}
						
						onProgress:
						{
							if(percent === 100)
								_progressBar.value = 0
								else
									_progressBar.value = percent/100
						}
					}
					
					Maui.ListBrowser
					{
						id: _millerListView
						anchors.fill: parent
						
						showPreviewThumbnails: modelList.preview
						keepEmblemOverlay: selectionMode
						rightEmblem: isMobile ? "document-share" : ""
						leftEmblem: "list-add"
						showDetailsInfo: true
						// 			itemSize: thumbnailsSize
						onItemClicked: 
						{
							control.currentFMList = _millersFMList							
							_millerColumns.itemClicked(index)
						}
						// 						onItemDoubleClicked: 
						// 						{
						// 							modelList.path = _millersFMList.path
						// 							_millerColumns.onItemDoubleClicked(index)
						// 						}
						
						onItemRightClicked: 
						{
                            control.currentFMList = _millersFMList                            
                            _millerColumns.itemRightClicked(index)
                        }
                        
						onRightEmblemClicked:
						{
                            control.currentFMList = _millersFMList
                             _millerColumns.rightEmblemClicked(index)
                        }
                        
						onLeftEmblemClicked: 
						{
                            control.currentFMList = _millersFMList
                            _millerColumns.leftEmblemClicked(index)
                        }
                        
                        onAreaClicked:
                        {
							control.currentFMList = _millersFMList
							_millerColumns.areaClicked(mouse)
						}
						
						onAreaRightClicked:
						{
							control.currentFMList = _millersFMList
							_millerColumns.areaRightClicked()							
						}
						
						model: Maui.BaseModel
						{							
							list: _millersFMList
						}
						
						section.delegate: Maui.LabelDelegate
						{
							id: delegate
							label: section
							labelTxt.font.pointSize: fontSizes.big
							
							isSection: true
							boldLabel: true
							height: toolBarHeightAlt
						}
					}
				}
			}       
		}		
	}
	
	Connections
	{
		target: browser
		
		onItemClicked: 
		{		
			browser.currentIndex = index
			indexHistory.push(index)
			control.itemClicked(index)
		}
		
		onItemDoubleClicked: 
		{
			browser.currentIndex = index	
			indexHistory.push(index)
			control.itemDoubleClicked(index)
		}
		
		onItemRightClicked:
		{
			if(currentFMList.pathType !== Maui.FMList.TRASH_PATH &&
				currentFMList.pathType !== Maui.FMList.REMOTE_PATH
			)
				itemMenu.show(index)
			control.itemRightClicked(index)
		}
		
		onLeftEmblemClicked:
		{
			control.addToSelection(control.currentFMList.get(index), true)
			control.itemLeftEmblemClicked(index)
		}
		
		onRightEmblemClicked:
		{
			isAndroid ? Maui.Android.shareDialog([control.currentFMList.get(index).path]) : shareDialog.show([control.currentFMList.get(index).path])
			control.itemRightEmblemClicked(index)
		}
		
		onAreaClicked:
		{
			if(!isMobile && mouse.button === Qt.RightButton)
				browserMenu.show()
				else return
					
					control.rightClicked()
		}
		
		onAreaRightClicked: browserMenu.show()
	}
		
	Maui.Holder
	{
		id: holder
		anchors.fill : parent
		z: -1
		visible: !control.currentFMList.pathExists || control.currentFMList.pathEmpty || !control.currentFMList.contentReady
		emoji: if(control.currentFMList.pathExists && control.currentFMList.pathEmpty)
		"qrc:/assets/MoonSki.png" 
		else if(!control.currentFMList.pathExists)
			"qrc:/assets/ElectricPlug.png"
			else if(!control.currentFMList.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
				"qrc:/assets/animat-search-color.gif"
				else if(!control.currentFMList.contentReady)
					"qrc:/assets/animat-rocket-color.gif"
					
					isGif: !control.currentFMList.contentReady			
					isMask: false
					title : if(control.currentFMList.pathExists && control.currentFMList.pathEmpty)
					qsTr("Folder is empty!")
					else if(!control.currentFMList.pathExists)
						qsTr("Folder doesn't exists!")
						else if(!control.currentFMList.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
							qsTr("Searching for content!")
							else if(!control.currentFMList.contentReady)
								qsTr("Loading content!")					
								
								
								body: if(control.currentFMList.pathExists && control.currentFMList.pathEmpty)
								qsTr("You can add new files to it")
								else if(!control.currentFMList.pathExists)
									qsTr("Create Folder?")
									else if(!control.currentFMList.contentReady && currentPathType === Maui.FMList.SEARCH_PATH)
										qsTr("This might take a while!")
										else if(!control.currentFMList.contentReady)
											qsTr("Almost ready!")	
											
											
											
											emojiSize: iconSizes.huge
											
											onActionTriggered:
											{
												if(!control.currentFMList.pathExists)
												{
													Maui.FM.createDir(control.currentPath.slice(0, control.currentPath.lastIndexOf("/")), control.currentPath.split("/").pop())
													control.openFolder(control.currentFMList.parentPath)				
												}
											}
	}
	
	Keys.onSpacePressed: previewer.show(control.currentFMList.get(browser.currentIndex).path)
	headBar.visible: currentPathType !== Maui.FMList.APPS_PATH
	headBar.position: isMobile ? ToolBar.Footer : ToolBar.Header
	property list<QtObject> t_actions:
	[
	Action
	{
		id: _previewAction
		icon.name: "image-preview"
		text: qsTr("Previews")
		checkable: true
		checked: list.preview
		onTriggered: list.preview = !list.preview
	},
	
	Action
	{
		id: _hiddenAction		
		icon.name: "visibility"		
		text: qsTr("Hidden files")
		checkable: true
		checked: list.hidden
		onTriggered: list.hidden = !list.hidden	
	},
	
	Action
	{
		id: _bookmarkAction		
		icon.name: "bookmark-new"
		text: qsTr("Bookmark")            
		onTriggered: newBookmark([currentPath])
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
		}
	},	
	
	Action
	{
		id: _pasteAction
		text: qsTr("Paste ")+"["+browserMenu.pasteFiles+"]"
		icon.name: "edit-paste"
		enabled: browserMenu.pasteFiles > 0
		onTriggered: paste()
	}]
	
	
// 	headBar.stickyRightContent: true
	headBar.rightContent:[
	Kirigami.ActionToolBar
	{
        position: ToolBar.Header
        Layout.fillWidth: true
        hiddenActions: t_actions

        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
		
		actions: [	
		Action
		{
			icon.name: "view-list-icons"
			onTriggered: list.viewType = Maui.FMList.ICON_VIEW
			checkable: false
			checked: list.viewType === Maui.FMList.ICON_VIEW
			icon.width: iconSizes.medium
			text: qsTr("Grid view")
// 			autoExclusive: true		
		},
		
		Action
		{
			icon.name: "view-list-details"
			onTriggered: list.viewType = Maui.FMList.LIST_VIEW
			icon.width: iconSizes.medium
			checked: list.viewType === Maui.FMList.LIST_VIEW	
			text: qsTr("List view")			
// 			autoExclusive: true
		},
		
		Action
		{
			icon.name: "view-file-columns"
			onTriggered: list.viewType = Maui.FMList.MILLERS_VIEW
			icon.width: iconSizes.medium
			checked: list.viewType === Maui.FMList.MILLERS_VIEW
			text: qsTr("Column view")			
// 			autoExclusive: true		
		},
		
		Kirigami.Action
		{
			icon.name: "view-sort"
			text: qsTr("Sort")
			
			Kirigami.Action
			{
				text: qsTr("Folders first")
				checked: list.foldersFirst
				onTriggered: list.foldersFirst = !list.foldersFirst
			}
			
			Kirigami.Action
			{
				text: qsTr("Type")
				checked: list.sortBy === Maui.FMList.MIME
				onTriggered: list.sortBy = Maui.FMList.MIME
			}
			
			Kirigami.Action
			{
				text: qsTr("Date")
				checked: list.sortBy === Maui.FMList.DATE
				onTriggered: list.sortBy = Maui.FMList.DATE
			}
			
			Kirigami.Action
			{
				text: qsTr("Modified")
				checked: list.sortBy === Maui.FMList.MODIFIED
				onTriggered: list.sortBy = Maui.FMList.MODIFIED
			}
			
			Kirigami.Action
			{
				text: qsTr("Size")
				checked: list.sortBy === Maui.FMList.SIZE
				onTriggered: list.sortBy = Maui.FMList.SIZE
			}
			
			Kirigami.Action
			{
				text: qsTr("Name")
				checked: list.sortBy === Maui.FMList.LABEL
				onTriggered: list.sortBy = Maui.FMList.LABEL
			}        
			
			Kirigami.Action
			{
				id: groupAction
				text: qsTr("Group")
				checked: group
				onTriggered:
				{
					group = !group
					if(group) 
						groupBy()
						else
							browser.section.property = ""
				}
			}			
		},
		
		Kirigami.Action
		{
			text: qsTr("Select")
			icon.name: "item-select"
			checkable: false
			checked: selectionMode		
			onTriggered: selectionMode = !selectionMode
			
		}
		]       
	}
	]
	
	headBar.leftContent: [
	ToolButton
	{
		icon.name: "go-previous"
		onClicked: control.goBack()
	},
	
	ToolButton
	{
		id: goUpButton
		visible: true
		icon.name: "go-up"
		onClicked: control.goUp()
	},
	
	ToolButton
	{
		icon.name: "go-next"
		onClicked: control.goNext()
	}	
	]
	
	footBar.visible: false
	
	
	Component
	{
		id: selectionBarComponent
		
		Maui.SelectionBar
		{
			anchors.fill: parent
			onIconClicked: _selectionBarmenu.popup()
			onExitClicked: clearSelection()
			
			Menu
			{
				id: _selectionBarmenu
				MenuItem
				{
					text: qsTr("Copy...")
					onTriggered:
					{
						if(control.selectionBar)				
							control.selectionBar.animate("#6fff80")
							control.copy(selectedItems)		
							console.log(selectedItems)
							_selectionBarmenu.close()
					}
				}
				
				MenuItem
				{
					text: qsTr("Cut...")
					onTriggered:
					{
						if(control.selectionBar)
							control.selectionBar.animate("#fff44f")
							control.cut(selectedItems)
							
							_selectionBarmenu.close()
					}
				}
				
				MenuItem
				{
					text: qsTr("Share")
					onTriggered:
					{						
						control.shareFiles(selectedPaths)
						_selectionBarmenu.close()
					}
				}
				
				MenuSeparator{}
				
				MenuItem
				{
					text: qsTr("Remove...")
					Kirigami.Theme.textColor: dangerColor
					
					onTriggered:
					{
						dialogLoader.sourceComponent= removeDialogComponent
						dialog.items = selectedItems
						dialog.open()
						_selectionBarmenu.close()
					}
				}
			}
		}
	}
	
	ColumnLayout
	{
		anchors.fill: parent
		visible: !holder.visible
		z: holder.z + 1
		spacing: 0
		
		Loader
		{
			id: viewLoader
			z: holder.z + 1
			sourceComponent: switch(list.viewType)
			{
				case Maui.FMList.ICON_VIEW: return gridViewBrowser
				case Maui.FMList.LIST_VIEW: return listViewBrowser
				case Maui.FMList.MILLERS_VIEW: return millerViewBrowser
			}
			
			onLoaded:
			{
				if(sourceComponent !== millerViewBrowser)
					control.currentFMList = modelList

			}
			
			Layout.topMargin: list.viewType == Maui.FMList.ICON_VIEW ? contentMargins * 2 : unit
			Layout.margins: 0
			
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
		
		Loader
		{
			id: selectionBarLoader
			Layout.fillWidth: true
			Layout.preferredHeight: control.selectionBar && control.selectionBar.visible ? control.selectionBar.barHeight: 0
			Layout.leftMargin:  contentMargins * (isMobile ? 3 : 2)
			Layout.rightMargin: contentMargins * (isMobile ? 3 : 2)
			Layout.bottomMargin: control.selectionBar && control.selectionBar.visible ? contentMargins*2 : 0
			z: holder.z +1
		}
		
		ProgressBar
		{
			id: _progressBar
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignBottom
			Layout.preferredHeight: visible ? iconSizes.medium : 0
			visible: value > 0
		}		
	}
	
// 		PinchArea
// 		{
// 	        anchors.fill: parent
// 	        
// 	        property real initialWidth
// 	        property real initialHeight
// 	
// 	        onPinchStarted:
// 	        {
// 	            console.log("pinch started")
// 	        }
// 	
// 	        onPinchUpdated:
// 	        {
// 	            console.log(pinch.scale)
// 	        }
// 	
// 	        onPinchFinished:
// 	        {
// 	            console.log("pinch finished")
// 	        }
// 	    }
	
	onThumbnailsSizeChanged:
	{
		if(trackChanges && saveDirProps)
			Maui.FM.setDirConf(currentPath+"/.directory", "MAUIFM", "IconSize", thumbnailsSize)
			else 
				Maui.FM.saveSettings("IconSize", thumbnailsSize, "SETTINGS")
				
				if(list.viewType == Maui.FMList.ICON_VIEW)
					browser.adaptGrid()
	}
	
	
	function shareFiles(urls)
	{
		if(urls.length <= 0)
			return;
		
		if(isAndroid)              
			Maui.Android.shareDialog(urls[0])        
			else
			{
				dialogLoader.sourceComponent= shareDialogComponent            
				dialog.show(urls)                    
			}
	}
	
	function openItem(index)
	{
		var item = control.currentFMList.get(index)
		var path = item.path
		
		switch(currentPathType)
		{
			case Maui.FMList.APPS_PATH:
				if(item.path.endsWith("/"))
					populate(path)
				else
					Maui.FM.runApplication(path)
				break
			case Maui.FMList.CLOUD_PATH:
				if(item.mime === "inode/directory")
					control.openFolder(path)
				else
					Maui.FM.openCloudItem(item)
				break;
			default:
				if(selectionMode && !Maui.FM.isDir(item.path))
					addToSelection(item, true)
					else
					{
						if(item.mime === "inode/directory")							
							control.openFolder(path)
						else if(Maui.FM.isApp(path))
								control.launchApp(path)
								else
								{
									if (isMobile)
										previewer.show(path)
										else
											control.openFile(path)
								}
					}
		}
	}
	
	
	function launchApp(path)
	{
		Maui.FM.runApplication(path, "")
	}
	
	function openFile(path)
	{
		Maui.FM.openUrl(path)
	}
	
	function openFolder(path)
	{
		populate(Maui.FM.fileDir(path))// make sure the path is a dir
	}
	
	function setPath(path)
	{
		currentPath = path
	}
	
	function populate(path)
	{
		if(!path.length)
			return;
		
		browser.currentIndex = 0
		setPath(path)
		
		if(currentPathType === Maui.FMList.PLACES_PATH)
		{
			if(trackChanges && saveDirProps)
			{
				var conf = Maui.FM.dirConf(path+"/.directory")
				var iconsize = conf["iconsize"] ||  iconSizes.large
				thumbnailsSize = parseInt(iconsize)				
			}else
			{
				thumbnailsSize = parseInt(Maui.FM.loadSettings("IconSize", "SETTINGS", thumbnailsSize))		
			}
		}
		
		if(list.viewType == Maui.FMList.ICON_VIEW)
			browser.adaptGrid()
	}
	
	function goBack()
	{
		populate(modelList.previousPath)
		browser.currentIndex = indexHistory.pop()
		//		browser.positionViewAtIndex(browser.currentIndex, ListView.Center)
	}
	
	function goNext()
	{
		openFolder(modelList.posteriorPath)
	}
	
	function goUp()
	{
		openFolder(modelList.parentPath)
	}
	
	function refresh()
	{
		var pos = browser.contentY
// 		control.currentFMList.refresh()
		
		browser.contentY = pos
	}
	
	function addToSelection(item, append)
	{
		selectionBarLoader.sourceComponent= selectionBarComponent
		selectionBar.singleSelection = control.singleSelection
		selectionBar.append(item)
	}
	
	function clearSelection()
	{
		clean()
		// 		selectionMode = false
	}
	
	function clean()
	{
		copyItems = []
		cutItems = []
		browserMenu.pasteFiles = 0
		
		if(control.selectionBar && control.selectionBar.visible)
			selectionBar.clear()
	}
	
	function copy(items)
	{
		copyItems = items
		isCut = false
		isCopy = true
	}
	
	function cut(items)
	{
		cutItems = items
		isCut = true
		isCopy = false
	}
	
	function paste()
	{
		if(isCopy)
			currentFMList.copyInto(copyItems)
			else if(isCut)
			{
				currentFMList.cutInto(cutItems)
				clearSelection()			
			}
	}
	
	function remove(items)
	{
		for(var i in items)
			Maui.FM.removeFile(items[i].path)
	}
	
	function trash(items)
	{
		for(var i in items)
			Maui.FM.moveToTrash(items[i].path)
	}
	
	function bookmarkFolder(paths)
	{        
		newBookmark(paths)        
	}
	
	function zoomIn()
	{		
		control.thumbnailsSize = control.thumbnailsSize + 8		
	}
	
	function zoomOut()
	{
		var newSize = control.thumbnailsSize - 8
		
		if(newSize >= iconSizes.small)
			control.thumbnailsSize = newSize
	}	
	
	function groupBy()
	{
		var prop = ""
		var criteria = ViewSection.FullString
		
		switch(modelList.sortBy)
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
		
		list.viewType = Maui.FMList.LIST_VIEW 
		
		if(!prop)
		{
			browser.section.property = ""
			return
		}
		
		browser.section.property = prop
		browser.section.criteria = criteria
	}
}
