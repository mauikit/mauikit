import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control
    
    property url path
    focus: true
    
    onPathChanged:
    {
        if(control.currentView) 
        {
            control.currentView.currentIndex = 0
            control.currentView.forceActiveFocus()
        }
    }
    
    property Maui.FMList currentFMList
    property Maui.BaseModel currentFMModel
    
    property alias currentView : viewLoader.item
    property int viewType
    property string filter
    
    height: _browserList.height
    width: _browserList.width
    
    function setCurrentFMList()
    {
        if(control.currentView)
        {
            control.currentFMList = currentView.currentFMList
            control.currentFMModel = currentView.currentFMModel
            currentView.forceActiveFocus()
        }
    }
    
    Menu
    {
        id: _dropMenu
        property string urls
        property url target
        
        enabled: Maui.FM.getFileInfo(target).isdir == "true" && !urls.includes(target.toString())
        
        MenuItem
        {
            text: qsTr("Copy here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                for(var i in urls)
                    Maui.FM.copy(urls[i], _dropMenu.target, false)
            }
        }
        
        MenuItem
        {
            text: qsTr("Move here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                for(var i in urls)
                    Maui.FM.cut(urls[i], _dropMenu.target)
            }
        }
        
        MenuItem
        {
            text: qsTr("Link here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                for(var i in urls)
                    Maui.FM.createSymlink(_dropMenu.source[i], urls.target)
            }
        }
	}    
	
	Loader
	{
		id: viewLoader
		anchors.fill: parent
		focus: true
		sourceComponent: switch(control.viewType)
		{
			case Maui.FMList.ICON_VIEW: return gridViewBrowser
			case Maui.FMList.LIST_VIEW: return listViewBrowser
			case Maui.FMList.MILLERS_VIEW: return millerViewBrowser
		}
		
		onLoaded: setCurrentFMList()
	}
	
    
    Maui.FMList
    {
        id: _commonFMList
        path: control.path
        onSortByChanged: if(group) groupBy()
        onlyDirs: settings.onlyDirs
        filterType: settings.filterType
        filters: settings.filters
        sortBy: settings.sortBy
    }
    
    Component
    {
        id: listViewBrowser
        
        Maui.ListBrowser
        {
            id: _listViewBrowser
            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            topMargin: Maui.Style.contentMargins
            showPreviewThumbnails: settings.showThumbnails
            keepEmblemOverlay: settings.selectionMode
            showDetailsInfo: true
            enableLassoSelection: true
            
            BrowserHolder
            {
                id: _holder
                browser: currentFMList
            }
            
            holder.visible: _holder.visible
            holder.emoji: _holder.emoji
            holder.title: _holder.title
            holder.body: _holder.body
            holder.emojiSize: _holder.emojiSize
            
            model: Maui.BaseModel
            {
                id: _browserModel
                list: _commonFMList
                filter: control.filter
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }
            
            section.delegate: Maui.LabelDelegate
            {
                id: delegate
                width: parent.width
                height: Maui.Style.toolBarHeightAlt
                
                label: String(section).toUpperCase()
                labelTxt.font.pointSize: Maui.Style.fontSizes.big
                
                isSection: true
            }
            
            delegate: Maui.ListBrowserDelegate
            {
                id: delegate
                width: parent.width
                height: _listViewBrowser.itemSize + Maui.Style.space.big
                leftPadding: Maui.Style.space.small
                rightPadding: leftPadding
                padding: 0
                showDetailsInfo: _listViewBrowser.showDetailsInfo
                folderSize : _listViewBrowser.itemSize
                showTooltip: true
                showEmblem: _listViewBrowser.showEmblem
                keepEmblemOverlay : _listViewBrowser.keepEmblemOverlay
                showThumbnails: _listViewBrowser.showPreviewThumbnails
                rightEmblem: _listViewBrowser.rightEmblem
                isSelected: selectionBar ? selectionBar.contains(model.path) : false
                leftEmblem: isSelected ? "checkbox" : " "
				opacity: model.hidden == "true" ? 0.5 : 1
                draggable: true
                
                Maui.Badge
                {
                    iconName: "link"
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    visible: (model.issymlink == true) || (model.issymlink == "true")
                }
                
                Connections
                {
                    target: selectionBar
                    
                    onUriRemoved:
                    {
                        if(uri === model.path)
                            delegate.isSelected = false
                    }
                    
                    onUriAdded:
                    {
                        if(uri === model.path)
                            delegate.isSelected = true
                    }
                    
                    onCleared: delegate.isSelected = false
                }
                
                Connections
                {
                    target: delegate
                    onClicked:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemClicked(index)
                    }
                    
                    onDoubleClicked:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemDoubleClicked(index)
                    }
                    
                    onPressAndHold:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemRightClicked(index)
                    }
                    
                    onRightClicked:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemRightClicked(index)
                    }
                    
                    onRightEmblemClicked:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.rightEmblemClicked(index)
                    }
                    
                    onLeftEmblemClicked:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.leftEmblemClicked(index)
                    }
                    
                    onContentDropped:
                    {
                        _dropMenu.urls = drop.urls.join(",")
                        _dropMenu.target = model.path
                        _dropMenu.popup()
                    }
                }
            }
        }
    }
    
    Component
    {
        id: gridViewBrowser
        
        Maui.GridBrowser
        {
            id: _gridViewBrowser
            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            itemSize : thumbnailsSize + Maui.Style.space.small
            cellHeight: itemSize * 1.5
            keepEmblemOverlay: settings.selectionMode
            showPreviewThumbnails: settings.showThumbnails
            enableLassoSelection: true
            
            BrowserHolder
            {
                id: _holder
                browser: currentFMList
            }
            
            holder.visible: _holder.visible
            holder.emoji: _holder.emoji
            holder.title: _holder.title
            holder.body: _holder.body
            holder.emojiSize: _holder.emojiSize
            model: Maui.BaseModel
            {
                id: _browserModel
                list: _commonFMList
                filter: control.filter
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }
            
            delegate: Item
            {
                property alias isSelected: delegate.isSelected
                property bool isCurrentItem : GridView.isCurrentItem
                height: _gridViewBrowser.cellHeight
                width: _gridViewBrowser.cellWidth

                Maui.GridBrowserDelegate
                {
                    id: delegate
                    
                    folderSize: height * 0.5
                    
                    anchors.centerIn: parent
                    height: _gridViewBrowser.cellHeight - 5
                    width: _gridViewBrowser.itemSize - 5
                    padding: Maui.Style.space.tiny
                    isCurrentItem: parent.isCurrentItem
                    showTooltip: true
                    showEmblem: _gridViewBrowser.showEmblem
                    keepEmblemOverlay: _gridViewBrowser.keepEmblemOverlay
                    showThumbnails: _gridViewBrowser.showPreviewThumbnails
                    rightEmblem: _gridViewBrowser.rightEmblem
                    isSelected: (selectionBar ? selectionBar.contains(model.path) : false) 
                    leftEmblem: isSelected ? "checkbox" : " "
                    draggable: true
                    opacity: model.hidden == "true" ? 0.5 : 1
                    
                    Maui.Badge
                    {
                        iconName: "link"
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Maui.Style.space.big
                        visible: (model.issymlink == true) || (model.issymlink == "true")
                    }
                    
                                      
                    Connections
                    {
                        target: selectionBar
                        
                        onUriRemoved:
                        {
                            if(uri === model.path)
                                delegate.isSelected = false
                        }
                        
                        onUriAdded:
                        {
                            if(uri === model.path)
                                delegate.isSelected = true
                        }
                        
                        onCleared: delegate.isSelected = false
                        
                    }
                    
                    Connections
                    {
                        target: delegate
                        onClicked:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemClicked(index)
                        }
                        
                        onDoubleClicked:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemDoubleClicked(index)
                        }
                        
                        onPressAndHold:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemRightClicked(index)
                        }
                        
                        onRightClicked:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemRightClicked(index)
                        }
                        
                        onRightEmblemClicked:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.rightEmblemClicked(index)
                        }
                        
                        onLeftEmblemClicked:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.leftEmblemClicked(index)
                        }
                        
                        onContentDropped:
                        {
                            _dropMenu.urls = drop.urls.join(",")
                            _dropMenu.target = model.path
                            _dropMenu.popup()
                            
                        }
                    }
                }
            }            
        }
    }
    
    Component
    {
        id: millerViewBrowser
        
        Item
        {
            id: _millerControl
            property Maui.FMList currentFMList
            property Maui.BaseModel currentFMModel
            property int currentIndex
            
            signal itemClicked(int index)
            signal itemDoubleClicked(int index)
            signal itemRightClicked(int index)
            signal keyPress(var event)
            signal rightEmblemClicked(int index)
            signal leftEmblemClicked(int index)
            signal itemsSelected(var indexes)
            
            signal areaClicked(var mouse)
            signal areaRightClicked()
            
            
            ListView
            {
                id: _millerColumns
                anchors.fill: parent
                boundsBehavior: !Maui.Handy.isTouch? Flickable.StopAtBounds : Flickable.OvershootBounds
                
                keyNavigationEnabled: true
                interactive: Kirigami.Settings.hasTransientTouchInput
                cacheBuffer: contentWidth
                orientation: ListView.Horizontal
                snapMode: ListView.SnapToItem
                clip: true
                
                ScrollBar.horizontal: ScrollBar
                {
                    id: _scrollBar
                    snapMode: ScrollBar.SnapAlways
                    policy: ScrollBar.AlwaysOn
                    
                    contentItem: Rectangle
                    {
                        implicitWidth: _scrollBar.interactive ? 13 : 4
                        implicitHeight: _scrollBar.interactive ? 13 : 4
                        
                        color: "#333"
                        
                        opacity: _scrollBar.pressed ? 0.7 :
                        _scrollBar.interactive && _scrollBar.hovered ? 0.5 : 0.2
                        radius: 0
                    }
                    
                    background: Rectangle
                    {
                        implicitWidth: _scrollBar.interactive ? 16 : 4
                        implicitHeight: _scrollBar.interactive ? 16 : 4
                        color: "#0e000000"
                        opacity: 0.0
                        visible: _scrollBar.interactive
                        radius: 0
                        
                    }
                }
                
                onCurrentItemChanged:
                {
                    _millerControl.currentFMList = currentItem.currentFMList
                    _millerControl.currentFMModel = currentItem.currentFMModel
                    control.setCurrentFMList()
                    currentItem.forceActiveFocus()
                }
                
                onCountChanged:
                {
                    _millerColumns.currentIndex = _millerColumns.count-1
                    _millerColumns.positionViewAtEnd()
                }
                
                Maui.PathList
                {
                    id: _millerList
                    path: control.path
                    
                    onPathChanged:
                    {
                        _millerColumns.currentIndex = _millerColumns.count-1
                        _millerColumns.positionViewAtEnd()
                    }
                }
                
                model: Maui.BaseModel
                {
                    id: _millerModel
                    list: _millerList
                }
                
                delegate: Item
                {
                    property alias currentFMList : _millersFMList
                    property alias currentFMModel : _millersFMModel
                    property int _index : index
                    width: Math.min(Kirigami.Units.gridUnit * 22, control.width)
                    height: parent.height
                    focus: true
                    
                    function forceActiveFocus()
                    {
                        _millerListView.forceActiveFocus()
                    }
                    
                    Kirigami.Separator
                    {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: 1
                        z: 999
                    }
                    
                    Maui.FMList
                    {
                        id: _millersFMList
                        path: model.path
                        onlyDirs: settings.onlyDirs
                        filterType: settings.filterType
                        filters: settings.filters
                        sortBy: settings.sortBy
                    }
                    
                    Maui.ListBrowser
                    {
                        id: _millerListView
                        anchors.fill: parent
                        topMargin: Maui.Style.contentMargins
                        showPreviewThumbnails: settings.showThumbnails
                        keepEmblemOverlay: settings.selectionMode
                        showDetailsInfo: true
                        onKeyPress: _millerControl.keyPress(event)
                        currentIndex : 0
                        onCurrentIndexChanged: _millerControl.currentIndex = currentIndex
                        enableLassoSelection: true
                        
                        BrowserHolder
                        {
                            id: _holder
                            browser: currentFMList
                        }
                        
                        holder.visible: _holder.visible
                        holder.emoji: _holder.emoji
                        holder.title: _holder.title
                        holder.body: _holder.body
                        holder.emojiSize: _holder.emojiSize
                        
                        section.delegate: Maui.LabelDelegate
                        {
                            id: delegate
                            width: parent.width
                            height: Maui.Style.toolBarHeightAlt
                            
                            label: String(section).toUpperCase()
                            labelTxt.font.pointSize: Maui.Style.fontSizes.big
                            
                            isSection: true
                        }
                        
                        onAreaClicked:
                        {
                            _millerColumns.currentIndex = _index
                            _millerControl.areaClicked(mouse)
                        }
                        
                        onAreaRightClicked:
                        {
                            _millerColumns.currentIndex = _index
                            _millerControl.areaRightClicked()
                        }
                        
                        onItemsSelected:
                         {
                            _millerColumns.currentIndex = _index
                            _millerControl.itemsSelected(indexes)
                        }
                        
                        model: Maui.BaseModel
                        {
                            id: _millersFMModel
                            list: _millersFMList
                            filter: control.filter
                            recursiveFilteringEnabled: true
                            sortCaseSensitivity: Qt.CaseInsensitive
                            filterCaseSensitivity: Qt.CaseInsensitive
                        }
                        
                        delegate: Maui.ListBrowserDelegate
                        {
                            id: delegate
                            width: parent.width
                            height: _millerListView.itemSize + Maui.Style.space.big
                            leftPadding: Maui.Style.space.small
                            rightPadding: leftPadding
                            padding: 0
                            showDetailsInfo: _millerListView.showDetailsInfo
                            folderSize : _millerListView.itemSize
                            showTooltip: true
                            showEmblem: _millerListView.showEmblem
                            keepEmblemOverlay : _millerListView.keepEmblemOverlay
                            showThumbnails: _millerListView.showPreviewThumbnails
                            rightEmblem: _millerListView.rightEmblem
                            isSelected: selectionBar ? selectionBar.contains(model.path) : false
                            leftEmblem: isSelected ? "checkbox" : " "
                            opacity: model.hidden == "true" ? 0.5 : 1
                            draggable: true
                            
                            Maui.Badge
                            {
                                iconName: "link"
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                visible: (model.issymlink == true) || (model.issymlink == "true")
                            }
                            
                            Connections
                            {
                                target: selectionBar
                                
                                onUriRemoved:
                                {
                                    if(uri === model.path)
                                        delegate.isSelected = false
                                }
                                
                                onUriAdded:
                                {
                                    if(uri === model.path)
                                        delegate.isSelected = true
                                }
                                
                                onCleared: delegate.isSelected = false
                            }
                            
                            Connections
                            {
                                target: delegate
                                onClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemClicked(index)
                                }
                                
                                onDoubleClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemDoubleClicked(index)
                                }
                                
                                onPressAndHold:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemRightClicked(index)
                                }
                                
                                onRightClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemRightClicked(index)
                                }
                                
                                onRightEmblemClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.rightEmblemClicked(index)
                                }
                                
                                onLeftEmblemClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.leftEmblemClicked(index)
                                }
                                
                                onContentDropped:
                                {
                                    _dropMenu.urls =  drop.urls.join(",")
                                    _dropMenu.target = model.path
                                    _dropMenu.popup()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
