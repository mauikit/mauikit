import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "private" as Private

/*!
\since org.kde.mauikit 1.0
\inqmlmodule org.kde.mauikit
\brief A tool button that triggers a contextual menu.

This provides a quick way to have a menu attached to a tool button.
All child items will be positioned in a menu.
*/
Private.BasicToolButton
{
    id: control

    /*!
      List of items, such as MenuItems to populate the contextual menu.
      This is the default property, so declaring the menu entries is straight forward.
    */
    default property list<Item> content

    /*!
      \qmlproperty Menu ToolButtonMenu::menu

      Alias to the actual menu component holding the menu entries.
      This can be modified for fine tuning the menu position or look.
    */
    property alias menu : _menu

    checked: _menu.visible
    display: ToolButton.TextBesideIcon
    onClicked:
    {
        if(_menu.visible)
            _menu.close()
        else
            _menu.popup(0, height)
    }

    extraContent: Maui.Triangle
    {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        rotation: -45
        color: control.kicon.color
        Layout.preferredWidth: Maui.Style.iconSizes.tiny-3
        Layout.preferredHeight: Layout.preferredWidth
    }

    Menu
    {
        id: _menu
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentData: control.content
    }
}
