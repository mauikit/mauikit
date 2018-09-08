import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

ListView
{
    id: control
    property bool detailsView : false
    property int itemSize : iconSizes.big
    property bool showEmblem : true
    property string rightEmblem
    property string leftEmblem

    property bool showPreviewThumbnails: true

    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)

    signal rightEmblemClicked(var item)
    signal leftEmblemClicked(var item)

    signal areaClicked(var mouse)
    signal areaRightClicked()

    //    maximumFlickVelocity: 400

    snapMode: ListView.SnapToItem
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds

    width: parent.width
    height: parent.height

    clip: true
    focus: true

    model: ListModel { id: listModel }
    delegate: Maui.IconDelegate
    {
        id: delegate
        isDetails: true
        width: parent.width
        height: itemSize + space.big

        folderSize : itemSize
        showTooltip: true
        showEmblem: control.showEmblem
        showThumbnails: showPreviewThumbnails
        rightEmblem: control.rightEmblem
        leftEmblem: control.leftEmblem

        Connections
        {
            target: delegate
            onClicked:
            {
                control.currentIndex = index
                control.itemClicked(index)
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                control.itemDoubleClicked(index)
            }

            onPressAndHold:
            {
                control.currentIndex = index
                control.itemRightClicked(index)
            }

            onRightClicked:
            {
                control.currentIndex = index
                control.itemRightClicked(index)
            }

            onRightEmblemClicked:
            {
                control.currentIndex = index
                var item = control.model.get(index)
                control.rightEmblemClicked(item)
            }

            onLeftEmblemClicked:
            {
                control.currentIndex = index
                var item = control.model.get(index)
                control.leftEmblemClicked(item)
            }
        }
    }

    ScrollBar.vertical: ScrollBar{ visible: !isMobile}

    MouseArea
    {
        anchors.fill: parent
        z: -1
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        onClicked: control.areaClicked(mouse)
        onPressAndHold: control.areaRightClicked()
    }
}
