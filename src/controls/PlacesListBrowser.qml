import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

Maui.ListBrowser
{
    id: control

    property alias list : placesList
    property alias itemMenu : _menu

    property int iconSize : Maui.Style.iconSizes.small

    signal placeClicked (string path)
    focus: true
    model: placesModel
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
            text: qsTr("Edit")
        }

        MenuItem
        {
            text: qsTr("Hide")
        }

        MenuItem
        {
            text: qsTr("Remove")
            Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
            onTriggered: list.removePlace(control.currentIndex)
        }
    }

    Maui.BaseModel
    {
        id: placesModel
        list: placesList
    }

    Maui.PlacesList
    {
        id: placesList
        groups: [
            Maui.FMList.PLACES_PATH,
            Maui.FMList.APPS_PATH,
            Maui.FMList.BOOKMARKS_PATH,
            Maui.FMList.DRIVES_PATH,
            Maui.FMList.TAGS_PATH]
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
        iconSize: control.iconSize
        labelVisible: true
        iconVisible: true
        label: model.label
        iconName: model.icon
        count: model.count > 0 ? model.count : ""

        leftPadding:  Maui.Style.space.tiny
        rightPadding: Maui.Style.space.tiny
        radius : Maui.Style.radiusV

        Connections
        {
            target: itemDelegate
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

}
