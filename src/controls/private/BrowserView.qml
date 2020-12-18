import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control
    headBar.visible: false
    title: currentFMList.pathName

    /**
      *
      */
    property url path

    /**
      *
      */
    property bool selectionMode : false

    property int gridItemSize :  Maui.Style.iconSizes.large * 1.7
    property int listItemSize : Maui.Style.rowHeight
    
    /**
      *
      */
    property int currentIndex : -1
    Binding on currentIndex
    {
        when: control.currentView
        value: control.currentView.currentIndex
    }

    onPathChanged:
    {
        if(control.currentView)
        {
            control.currentIndex = 0
            control.currentView.forceActiveFocus()
        }
    }

    //group properties from the browser since the browser views are loaded async and
    //their properties can not be accesed inmediately, so they are stored here and then when completed they are set
    /**
      *
      */
    property alias settings : _settings
    BrowserSettings
    {
        id: _settings
        onGroupChanged:
        {
            if(settings.group)
            {
                groupBy()
            }
            else
            {
                currentView.section.property = ""
            }
        }
    }

    /**
      *
      */
    property Maui.FMList currentFMList

    /**
      *
      */
    property Maui.BaseModel currentFMModel

    /**
      *
      */
    property alias currentView : viewLoader.item

    /**
      *
      */
    property string filter

    /**
      *
      */
    function setCurrentFMList()
    {
        if(control.currentView)
        {
            control.currentFMList = currentView.currentFMList
            control.currentFMModel = currentView.currentFMModel
            currentView.forceActiveFocus()
        }
    }

    /**
      *
      */
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
            control.currentView.section.property = ""
            return
        }

        control.settings.viewType = Maui.FMList.LIST_VIEW
        control.currentView.section.property = prop
        control.currentView.section.criteria = criteria
    }

    Menu
    {
        id: _dropMenu
        property string urls
        property url target

        enabled: Maui.FM.getFileInfo(target).isdir == "true" && !urls.includes(target.toString())

        MenuItem
        {
            text: i18n("Copy here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.copy(urls, _dropMenu.target, false)
            }
        }

        MenuItem
        {
            text: i18n("Move here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.cut(urls, _dropMenu.target)
            }
        }

        MenuItem
        {
            text: i18n("Link here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                for(var i in urls)
                    Maui.FM.createSymlink(url[i], _dropMenu.target)
            }
        }

        MenuSeparator {}

        MenuItem
        {
            text: i18n("Cancel")
            onTriggered: _dropMenu.close()
        }
    }

    Loader
    {
        id: viewLoader
        anchors.fill: parent
        focus: true
        sourceComponent: switch(settings.viewType)
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
        onSortByChanged: if(settings.group) groupBy()
        onlyDirs: settings.onlyDirs
        filterType: settings.filterType
        filters: settings.filters
        sortBy: settings.sortBy
        hidden: settings.showHiddenFiles
        foldersFirst: settings.foldersFirst
    }

    Component
    {
        id: listViewBrowser

        Maui.ListBrowser
        {
            id: _listViewBrowser
            objectName: "FM ListBrowser"
            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            selectionMode: control.selectionMode
            property bool checkable: control.selectionMode
            enableLassoSelection: true
            currentIndex: control.currentIndex

            signal itemClicked(int index)
            signal itemDoubleClicked(int index)
            signal itemRightClicked(int index)
            signal itemToggled(int index, bool state)

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
                width: parent ? parent.width : 0
                height: Maui.Style.toolBarHeightAlt

                label: _listViewBrowser.section.property == "date" || _listViewBrowser.section.property === "modified" ?  Qt.formatDateTime(new Date(section), "d MMM yyyy") : section
                labelTxt.font.pointSize: Maui.Style.fontSizes.big

                isSection: true
            }

            delegate: Maui.ListBrowserDelegate
            {
                id: delegate
                readonly property string path : model.path

                width: ListView.view.width
                height: control.listItemSize
                
                iconSource: model.icon

                label1.text: model.label ? model.label : ""
                label3.text : model.mime ? (model.mime === "inode/directory" ? (model.count ? model.count + i18n(" items") : "") : Maui.FM.formatSize(model.size)) : ""
                label4.text: model.modified ? Maui.FM.formatDate(model.modified, "MM/dd/yyyy") : ""

                iconSizeHint : Maui.Style.iconSizes.medium
                imageSizeHint : height * 0.8

                tooltipText: model.path

                checkable: _listViewBrowser.checkable
                imageSource: settings.showThumbnails ? model.thumbnail : ""
                checked: selectionBar ? selectionBar.contains(model.path) : false
                opacity: model.hidden == "true" ? 0.5 : 1
                draggable: true

                Drag.keys: ["text/uri-list"]
                Drag.mimeData: Drag.active ?
                {
                    "text/uri-list": filterSelection(control.path, model.path).join("\n")
                } : {}

                Item
                {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    visible: (model.issymlink == true) || (model.issymlink == "true")

                    Kirigami.Icon
                    {
                        source: "link"
                        height: Maui.Style.iconSizes.small
                        width: Maui.Style.iconSizes.small
                        anchors.centerIn: parent
                        color: label1.color
                    }
                }

                onClicked:
                {
                    control.currentIndex = index

                    if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
                    {
                        _listViewBrowser.itemsSelected([index])
                    }else
                    {
                        _listViewBrowser.itemClicked(index)
                    }
                }

                onDoubleClicked:
                {
                    control.currentIndex = index
                    _listViewBrowser.itemDoubleClicked(index)
                }

                onPressAndHold:
                {
                    if(!Maui.Handy.isTouch)
                        return

                        control.currentIndex = index
                        _listViewBrowser.itemRightClicked(index)
                }

                onRightClicked:
                {
                    control.currentIndex = index
                    _listViewBrowser.itemRightClicked(index)
                }

                onToggled:
                {
                    control.currentIndex = index
                    _listViewBrowser.itemToggled(index, state)
                }

                onContentDropped:
                {
                    _dropMenu.urls = drop.urls.join(",")
                    _dropMenu.target = model.path
                    _dropMenu.popup()
                }

                ListView.onRemove:
                {
                    if(selectionBar && !Maui.FM.fileExists(delegate.path))
                    {
                        selectionBar.removeAtUri(delegate.path)
                    }
                }

                Connections
                {
                    target: selectionBar

                    function onUriRemoved(uri)
                    {
                        if(uri === model.path)
                            delegate.checked = false
                    }

                    function onUriAdded(uri)
                    {
                        if(uri === model.path)
                            delegate.checked = true
                    }

                    function onCleared()
                    {
                        delegate.checked = false
                    }
                }
            }
        }
    }

    Component
    {
        id: gridViewBrowser

        Maui.GridView
        {
            id: _gridViewBrowser
            objectName: "FM GridBrowser"

            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            itemSize : control.gridItemSize
            itemHeight: itemSize * 1.3
            property bool checkable: control.selectionMode
            enableLassoSelection: true
            currentIndex: control.currentIndex
//            selectionMode: control.selectionMode

            signal itemClicked(int index)
            signal itemDoubleClicked(int index)
            signal itemRightClicked(int index)
            signal itemToggled(int index, bool state)

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

                property bool isCurrentItem : GridView.isCurrentItem
                height: _gridViewBrowser.cellHeight
                width: _gridViewBrowser.cellWidth

                GridView.onRemove:
                {
                    if(selectionBar && !Maui.FM.fileExists(delegate.path))
                    {
                        selectionBar.removeAtUri(delegate.path)
                    }
                }

                Maui.GridBrowserDelegate
                {
                    id: delegate
                    readonly property string path : model.path

                    iconSizeHint: height * 0.4
                    imageSource: settings.showThumbnails ? model.thumbnail : ""
                    template.fillMode: Image.PreserveAspectFit
                    iconSource: model.icon
                    label1.text: model.label

                    anchors.fill: parent
                    anchors.margins: Maui.Style.space.big
                    padding: Maui.Style.space.tiny
                    isCurrentItem: parent.isCurrentItem
                    tooltipText: model.path
                    checkable: _gridViewBrowser.checkable
                    checked: (selectionBar ? selectionBar.contains(model.path) : false)
                    draggable: true
                    opacity: model.hidden == "true" ? 0.5 : 1

                    Drag.keys: ["text/uri-list"]
                    Drag.mimeData: Drag.active ?
                    {
                        "text/uri-list":  filterSelection(control.path, model.path).join("\n")
                    } : {}

                    Maui.Badge
                    {
                        iconName: "link"
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Maui.Style.space.big
                        visible: (model.issymlink == true) || (model.issymlink == "true")
                    }

                    template.content: Label
                    {
                        visible: delegate.height > 100
                        opacity: 0.5
                        color: Kirigami.Theme.textColor
                        font.pointSize: Maui.Style.fontSizes.tiny
                        horizontalAlignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: model.mime ? (model.mime === "inode/directory" ? (model.count ? model.count + i18n(" items") : "") : Maui.FM.formatSize(model.size)) : ""
                    }

                    onClicked:
                    {
                        control.currentIndex = index

                        if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
                        {
                            _gridViewBrowser.itemsSelected([index])
                        }else
                        {
                            _gridViewBrowser.itemClicked(index)
                        }
                    }

                    onDoubleClicked:
                    {
                        control.currentIndex = index
                        _gridViewBrowser.itemDoubleClicked(index)
                    }

                    onPressAndHold:
                    {
                        if(!Maui.Handy.isTouch)
                            return

                            control.currentIndex = index
                            _gridViewBrowser.itemRightClicked(index)
                    }

                    onRightClicked:
                    {
                        control.currentIndex = index
                        _gridViewBrowser.itemRightClicked(index)
                    }

                    onToggled:
                    {
                        control.currentIndex = index
                        _gridViewBrowser.itemToggled(index, state)
                    }

                    onContentDropped:
                    {
                        _dropMenu.urls = drop.urls.join(",")
                        _dropMenu.target = model.path
                        _dropMenu.popup()
                    }

                    Connections
                    {
                        target: selectionBar

                        function onUriRemoved(uri)
                        {
                            if(uri === model.path)
                                delegate.checked = false
                        }

                        function onUriAdded(uri)
                        {
                            if(uri === model.path)
                                delegate.checked = true
                        }

                        function onCleared(uri)
                        {
                            delegate.checked = false
                        }
                    }
                }
            }
        }
    }

    Component
    {
        id: millerViewBrowser

        ScrollView
        {
            id: _millerControl
            property Maui.FMList currentFMList
            property Maui.BaseModel currentFMModel
            property int currentIndex

            property Flickable flickable : _millerColumns.currentItem.list

            signal itemClicked(int index)
            signal itemDoubleClicked(int index)
            signal itemRightClicked(int index)
            signal keyPress(var event)
            signal itemToggled(int index, bool state)
            signal itemsSelected(var indexes)

            signal areaClicked(var mouse)
            signal areaRightClicked()

            function forceActiveFocus()
            {
                _millerColumns.currentItem.forceActiveFocus()
            }

            contentWidth: _millerColumns.contentWidth

            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ListView
            {
                id: _millerColumns
                anchors.fill: parent
                anchors.bottomMargin: parent.ScrollBar.horizontal.visible ? parent.ScrollBar.horizontal.height : 0

                boundsBehavior: !Maui.Handy.isTouch? Flickable.StopAtBounds : Flickable.OvershootBounds

                keyNavigationEnabled: true
                interactive: Kirigami.Settings.hasTransientTouchInput
                cacheBuffer: contentWidth
                orientation: ListView.Horizontal
                snapMode: ListView.SnapToItem
                clip: true

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
                    property alias list : _millerListView
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

                    Maui.ListBrowser
                    {
                        id: _millerListView
                        anchors.fill: parent
                        selectionMode: control.selectionMode
                        property bool checkable: control.selectionMode
                        onKeyPress: _millerControl.keyPress(event)
                        currentIndex : -1
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

                            label: section.property == "date" || section.property === "modified" ?  Qt.formatDateTime(new Date(section), "d MMM yyyy") : section
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
                            list: Maui.FMList
                            {
                                id: _millersFMList
                                path: model.path
                                onlyDirs: settings.onlyDirs
                                filterType: settings.filterType
                                filters: settings.filters
                                sortBy: settings.sortBy
                                hidden: settings.showHiddenFiles
                                foldersFirst: settings.foldersFirst
                            }
                            filter: control.filter
                            recursiveFilteringEnabled: true
                            sortCaseSensitivity: Qt.CaseInsensitive
                            filterCaseSensitivity: Qt.CaseInsensitive
                        }

                        delegate: Maui.ListBrowserDelegate
                        {
                            id: delegate
                            readonly property string path : model.path

                            width: ListView.view.width
                            height: implicitHeight

                            iconSource: model.icon

                            label1.text: model.label ? model.label : ""
                            label3.text : model.mime ? (model.mime === "inode/directory" ? (model.count ? model.count + i18n(" items") : "") : Maui.FM.formatSize(model.size)) : ""
                            label4.text: model.modified ? Maui.FM.formatDate(model.modified, "MM/dd/yyyy") : ""

                            tooltipText: model.path

                            iconSizeHint : Maui.Style.iconSizes.medium
                            imageSizeHint : height * 0.8
                            imageSource: settings.showThumbnails ? model.thumbnail : ""

                            checkable: _millerListView.checkable
                            checked: selectionBar ? selectionBar.contains(model.path) : false
                            opacity: model.hidden == "true" ? 0.5 : 1
                            draggable: true

                            Drag.keys: ["text/uri-list"]
                            Drag.mimeData: Drag.active ?
                            {
                                "text/uri-list": filterSelection(control.path, model.path).join("\n")
                            } : {}

                            Item
                            {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                visible: (model.issymlink == true) || (model.issymlink == "true")

                                Kirigami.Icon
                                {
                                    source: "link"
                                    height: Maui.Style.iconSizes.small
                                    width: Maui.Style.iconSizes.small
                                    anchors.centerIn: parent
                                    color: label1.color
                                }
                            }

                            ListView.onRemove:
                            {
                                if(selectionBar && !Maui.FM.fileExists(delegate.path))
                                {
                                    selectionBar.removeAtUri(delegate.path)
                                }
                            }

                            Connections
                            {
                                target: selectionBar

                                function onUriRemoved(uri)
                                {
                                    if(uri === model.path)
                                        delegate.checked = false
                                }

                                function onUriAdded(uri)
                                {
                                    if(uri === model.path)
                                        delegate.checked = true
                                }

                                function onCleared()
                                {
                                     delegate.checked = false
                                }
                            }

                            onClicked:
                            {
                                _millerColumns.currentIndex = _index
                                control.currentIndex = index

                                if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
                                {
                                    _millerControl.itemsSelected([index])
                                }else
                                {
                                    _millerControl.itemClicked(index)
                                }
                            }

                            onDoubleClicked:
                            {
                                _millerColumns.currentIndex = _index
                                control.currentIndex = index
                                _millerControl.itemDoubleClicked(index)
                            }

                            onPressAndHold:
                            {
                                if(!Maui.Handy.isTouch)
                                    return

                                    _millerColumns.currentIndex = _index
                                    control.currentIndex = index
                                    _millerControl.itemRightClicked(index)
                            }

                            onRightClicked:
                            {
                                _millerColumns.currentIndex = _index
                                control.currentIndex = index
                                _millerControl.itemRightClicked(index)
                            }

                            onToggled:
                            {
                                _millerColumns.currentIndex = _index
                                control.currentIndex = index
                                _millerControl.itemToggled(index, state)
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
