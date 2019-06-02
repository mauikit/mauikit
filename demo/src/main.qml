import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami

Maui.ApplicationWindow
{
    id: root
    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        wrapMode: TextInput.WordWrap
    }

    footBar.leftContent: Kirigami.ActionToolBar
    {
        Layout.fillWidth: true

        actions:
            [
            Kirigami.Action
            {
                iconName: "folder-new"
                text: "New folder"

            },

            Kirigami.Action
            {
                iconName: "edit-find"
                text: "Search"

            },

            Kirigami.Action
            {
                iconName: "document-preview-archive"
                text: "Hidden files"

            }

        ]
    }

}
