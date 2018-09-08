import QtQuick 2.0
import QtQuick.Controls 2.2
import "."

ListView
{
    id: control
    orientation: ListView.Horizontal
    clip: true
    spacing: contentMargins
    signal tagRemoved(int index)
    signal tagClicked(int index)
    boundsBehavior: isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds

    property bool showPlaceHolder:  true
    property bool showDeleteIcon: true

    Label
    {
        height: parent.height
        width: parent.width
        verticalAlignment: Qt.AlignVCenter
        text: qsTr("Add tags...")
        opacity: 0.7
        visible: count === 0 && showPlaceHolder
        color: textColor
        font.pointSize: fontSizes.default
    }

    model: ListModel{}

    delegate: TagDelegate
    {
        id: delegate
        showDeleteIcon: control.showDeleteIcon
        Connections
        {
            target: delegate
            onRemoveTag: tagRemoved(index)
            onClicked: tagClicked(index)
        }
    }

    function populate(tags)
    {
        model.clear()
        for(var i in tags)
            model.append(tags[i])
    }
}
