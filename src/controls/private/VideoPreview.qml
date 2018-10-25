import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.0 as Maui

ColumnLayout
{
    anchors.fill: parent
    property alias player: player

    Item
    {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.width * 0.5
        Layout.margins: contentMargins

        Maui.ToolButton
        {
            anchors.centerIn: parent
            isMask: false
            flat: true
            size: iconSizes.huge
            iconName: iteminfo.icon
        }

        Video
        {
            id: player
            anchors.centerIn: parent
            anchors.fill: parent
            source: "file://"+currentUrl
            autoLoad: true

        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
        }
    }
    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        Layout.margins: contentMargins

        text: iteminfo.name
        width: parent.width
        height: parent.height
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.big
        font.weight: Font.Bold
        font.bold: true
    }


    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight

        text: qsTr("Title: ")+ player.metaData.title

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Camera: ")+ player.metaData.cameraModel

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Zoom ratio: ")+ player.metaData.digitalZoomRatio

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Author: ")+ player.metaData.author

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Codec: ")+ player.metaData.videoCodec

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Copyright: ")+ player.metaData.copyright

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Duration: ")+ player.metaData.video

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Frame rate: ")+ player.metaData.videoFrameRate

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Year: ")+ player.metaData.year

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Aspect ratio: ")+ player.metaData.pixelAspectRatio
        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Resolution: ")+ player.metaData.resolution

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }
}
