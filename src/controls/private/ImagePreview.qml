import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ColumnLayout
{
    id: layout
    anchors.fill: parent

    Item
    {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: contentMargins
        Layout.maximumHeight: unit * 400
        Layout.preferredHeight: unit * 200
        Layout.minimumHeight: unit * 200

        Image
        {
            anchors.centerIn: parent
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            width: parent.width * 0.9
            height: parent.height * 0.9
            source: "file://"+currentUrl
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize.height: height
            sourceSize.width: width
        }
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        Layout.margins: contentMargins

        text: iteminfo.name

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
        text: qsTr("Type: ")+ iteminfo.mime
        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Date: ")+ iteminfo.date

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Modified: ")+ iteminfo.modified

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Owner: ")+ iteminfo.owner

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Tags: ")+ iteminfo.tags

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }

    Label
    {
        Layout.fillWidth: true
        Layout.preferredHeight: rowHeight
        text: qsTr("Permisions: ")+ iteminfo.permissions

        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        font.pointSize: fontSizes.default
    }
}

