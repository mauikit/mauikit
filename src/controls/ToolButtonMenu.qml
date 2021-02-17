import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui

import "private" as Private

/**
 * ToolButtonMenu
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
ToolButton
{
    id: control

    /**
      * content : list<Item>
      */
    default property list<Item> content

    /**
      * menu : Menu
      */
    property alias menu : _menu
    
    focusPolicy: Qt.NoFocus
    checked: _menu.visible
    display: ToolButton.IconOnly
    
    onClicked:
    {
        if(_menu.visible)
            _menu.close()
        else
            _menu.popup(0, height)
    }

    Menu
    {
        id: _menu
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentData: control.content
    }
    
    Component.onCompleted: control.background.showMenuArrow = true    
}
