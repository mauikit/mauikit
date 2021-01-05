import QtQuick 2.14
import QtQuick.Controls 2.14
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import TagsList 1.0
import "."

ListView
{
    id: control
    orientation: ListView.Horizontal
    clip: true
    spacing: Maui.Style.contentMargins
    boundsBehavior: Kirigami.Settings.isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds

    /**
      *
      */
    property string placeholderText: i18n("Add tags...")

    /**
      *
      */
    property alias list : _tagsList

    /**
      *
      */
    property bool showPlaceHolder:  true

    /**
      *
      */
    property bool showDeleteIcon: true

    /**
      *
      */
    signal tagRemoved(int index)

    /**
      *
      */
    signal tagClicked(int index)

    model: Maui.BaseModel
    {
        id: _tagsModel
        list: TagsList
        {
            id: _tagsList
        }
    }

    Label
    {
        anchors.fill: parent
        verticalAlignment: Qt.AlignVCenter
        text: qsTr(control.placeholderText)
        opacity: 0.7
        visible: count === 0 && control.showPlaceHolder
        color: Kirigami.Theme.textColor
    }

    delegate: TagDelegate
    {
        showDeleteIcon: control.showDeleteIcon
        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
        anchors.verticalCenter: parent.verticalCenter
        
        ListView.onAdd:
        {
            control.positionViewAtEnd()
        }
        
        onRemoveTag: tagRemoved(index)
        onClicked: tagClicked(index)
    }
    
}
