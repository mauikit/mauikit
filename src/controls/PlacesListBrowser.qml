import QtQuick 2.14
import QtQuick.Controls 2.14

import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.6 as Kirigami

/**
 * PlacesListBrowser
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.ListBrowser
{
    id: control

    /**
      * list : PlacesList
      */
    property alias list : placesList

    /**
      * itemMenu : Menu
      */
    property alias itemMenu : _menu

    /**
      * iconSize : int
      */
    property int iconSize : Maui.Style.iconSizes.small

    /**
      * placeClicked :
      */
    signal placeClicked (string path)
    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)
    
    focus: true
    model: Maui.BaseModel
    {
        id: placesModel
        list: Maui.PlacesList
        {
            id: placesList
            groups: [
                Maui.FMList.PLACES_PATH,
                Maui.FMList.APPS_PATH,
                Maui.FMList.BOOKMARKS_PATH,
                Maui.FMList.DRIVES_PATH]
        }
    }

    section.property: "type"
    section.criteria: ViewSection.FullString
    section.delegate: Maui.LabelDelegate
    {
        id: delegate
        label: section
        labelTxt.font.pointSize: Maui.Style.fontSizes.big

        isSection: true
        width: parent.width
        height: Maui.Style.toolBarHeightAlt
    }

    onItemClicked:
    {
        var item = list.get(index)
        var path = item.path

        placesList.clearBadgeCount(index)

        placeClicked(path)
    }

    onItemRightClicked: _menu.popup()

    Menu
    {
        id: _menu
        property int index

        MenuItem
        {
            text: i18n("Edit")
        }

        MenuItem
        {
            text: i18n("Hide")
        }

        MenuItem
        {
            text: i18n("Remove")
            Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
            onTriggered: list.removePlace(control.currentIndex)
        }
    }

    Rectangle
    {
        anchors.fill: parent
        z: -1
        color: Kirigami.Theme.backgroundColor
    }

    delegate: Maui.ListDelegate
    {
        id: itemDelegate
        width: ListView.view.width
        iconSize: control.iconSize
        labelVisible: true
        iconVisible: true
        label: model.label
        iconName: model.icon
        count: model.count > 0 ? model.count : ""

        radius : Maui.Style.radiusV
        onClicked:
        {
            control.currentIndex = index
            itemClicked(index)
        }

        onRightClicked:
        {
            control.currentIndex = index
            itemRightClicked(index)
        }

        onPressAndHold:
        {
            control.currentIndex = index
            itemRightClicked(index)
        }
    }
}
