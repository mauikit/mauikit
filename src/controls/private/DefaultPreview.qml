import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Item
{
    anchors.fill: parent

    ColumnLayout
    {
        anchors.fill: parent

        Item
        {

            Layout.fillWidth: true
            height: parent.width *0.3
            Layout.margins: contentMargins

            Maui.ToolButton
            {
                anchors.centerIn: parent
                isMask: false
                flat: true
                size: iconSizes.huge
                iconName: iteminfo.icon
            }
        }

        Item
        {
            Layout.fillWidth: true
            height: rowHeight
            width: parent.width* 0.8

            Layout.margins: contentMargins

            Label
            {
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
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: contentMargins

            Column
            {
                spacing: space.small
                width: parent.width
                height: parent.height

                Label
                {
                    text: qsTr("Type: ")+ iteminfo.mime

                    elide: Qt.ElideRight
                    wrapMode: Text.Wrap
                    font.pointSize: fontSizes.default


                }
                Label
                {
                    text: qsTr("Date: ")+ iteminfo.date

                    elide: Qt.ElideRight
                    wrapMode: Text.Wrap
                    font.pointSize: fontSizes.default


                }
                Label
                {
                    text: qsTr("Modified: ")+ iteminfo.modified

                    elide: Qt.ElideRight
                    wrapMode: Text.Wrap
                    font.pointSize: fontSizes.default


                }
                Label
                {
                    text: qsTr("Owner: ")+ iteminfo.owner

                    elide: Qt.ElideRight
                    wrapMode: Text.Wrap
                    font.pointSize: fontSizes.default


                }
                Label
                {
                    text: qsTr("Tags: ")+ iteminfo.tags

                    elide: Qt.ElideRight
                    wrapMode: Text.Wrap
                    font.pointSize: fontSizes.default


                }
                Label
                {
                    text: qsTr("Permisions: ")+ iteminfo.permissions

                    elide: Qt.ElideRight
                    wrapMode: Text.Wrap
                    font.pointSize: fontSizes.default


                }
            }
        }
    }
}
