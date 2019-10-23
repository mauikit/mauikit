import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.1

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Row
{
id: control

default property list<Action> actions
property bool autoExclusive: true

property int expand : Qt.Horizontal

property Action currentAction

onClicked: _actionsMenu.popup()
icon.name: "love"
text: "text"


ToolButton
{
    action: control.currentAction
}

Loader
{
    id: _loader
    sourceComponent: control.expand ===  Qt.Horizontal ? _rowComponent : (control.expand === Qt.Vertical ?  _menuComponet : null)
}

Row
{
    id: _actionsRow
    Repeater
    {
        model: control.actions

        ToolButton
        {
            action: modelData
            autoExclusive: control.autoExclusive
            onClicked: control.currentAction = action
        }
    }
}


Menu
{
    id: _actionsMenu

    Repeater
    {
        model: control.actions

        MenuItem
        {
            action: modelData
            autoExclusive: control.autoExclusive
            onTriggered: control.currentAction = action
        }
    }
}
}
