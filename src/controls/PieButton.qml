import QtQuick 2.6
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.0 as Kirigami
import "private"

Maui.ToolButton
{
    id: control
    z: 1
    property alias delegate : pathView.delegate
    property alias model : pathView.model
    property alias count: pathView.count
    property alias path : pathView

    property int delegateSize : iconSize
    property int pieHeight: Kirigami.Units.gridUnit * 10
    property int pieWidth: pieHeight

    iconColor: pathView.visible ? highlightColor : textColor
    onClicked: pathView.visible ? close() : open()

    signal itemClicked (var item)
    layer.enabled: true

    Popup
    {
        id: popup

   PathView
    {
        id: pathView
        z: control.z + 1
        visible: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        height: pieHeight
        width: pieWidth
        pathItemCount: 3
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        focus: true
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
        //        offset: 1.5
        snapMode: PathView.SnapOneItem

        onActiveFocusChanged: if(!activeFocus || !focus) pathView.visible = false

        model: ListModel {}
        delegate: PieButtonDelegate
        {
            id: btnDelegate
            height: delegateSize + space.big
            width: height
            size: delegateSize

            Connections
            {
                target:btnDelegate
                onClicked:
                {
                    pathView.currentIndex = index
                    itemClicked(pathView.model.get(index))
                    close()
                }
            }
        }

        path: Path
        {
            startX: 0; startY: pathView.height

            PathArc
            {
                x: pathView.width
                y: pathView.height
                radiusX: pathView.width *.5; radiusY: radiusX
                useLargeArc: false
            }
        }

        //        Rectangle
        //        {
        //            id: overlayBg
        //            parent: ApplicationWindow.overlay
        //            color: altColor
        //            opacity: 0.5
        //            y: headBar.height
        //            height: parent.height - headBar.height - footBar.height
        //            width: parent.width
        //            visible:pathView.visible
        //            z: pathView.z - 1
        //        }
    }
    }


    function open()
    {
        popup.open()
    }

    function close()
    {
        popup.close()
    }
}
