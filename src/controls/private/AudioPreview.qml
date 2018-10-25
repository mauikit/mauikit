import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.0 as Maui

ColumnLayout
{
    id: layout
    anchors.fill: parent
    property alias player: player

    Item
    {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.width * 0.3
        Layout.margins: contentMargins

        MediaPlayer
        {
            id: player
            source: "file://"+currentUrl
            autoLoad: true
            autoPlay: false
        }

        Maui.ToolButton
        {
            anchors.centerIn: parent
            isMask: false
            flat: true
            size: iconSizes.huge
            iconName: iteminfo.icon
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

        text: qsTr("Artist: ")+ player.metaData.albumArtist

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight

        text: qsTr("Album: ")+ player.metaData.albumTitle

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
        text: qsTr("Codec: ")+ player.metaData.audioCodec

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
        text: qsTr("Duration: ")+ player.metaData.duration

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Number: ")+ player.metaData.trackNumber

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
        text: qsTr("Mood: ")+ player.metaData.mood

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Rating: ")+ player.metaData.userRating

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default

    }
}

