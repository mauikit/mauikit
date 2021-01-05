import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

/**
 * TabButton
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
TabButton
{
    id: control
    implicitWidth: 150

    /**
      * content : ListItemTemplate.data
      */
    default property alias content : _template.data

    /**
      * template : ListItemTemplate
      */
    property alias template: _template

    /**
      * closeClicked :
      */
    signal closeClicked(int index)

    Kirigami.Separator
    {
        color: Kirigami.Theme.highlightColor
        height: 2
        visible: checked
        anchors
        {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    background: Rectangle
    {
        color: "transparent"

        Maui.Separator
        {
            position: Qt.Vertical
            anchors
            {
                bottom: parent.bottom
                top: parent.top
                right: parent.right
            }
        }
    }

    contentItem:  Maui.ListItemTemplate
    {
        id: _template
        label1.text: control.text
        label1.horizontalAlignment: Qt.AlignHCenter
        label1.color: control.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
        label1.wrapMode: Text.NoWrap
        label1.elide: Text.ElideMiddle
        leftMargin: Maui.Style.space.small
        rightMargin: leftMargin

        MouseArea
        {
            id: _closeButton

            property int position : Maui.App.leftWindowControls.includes("X") ? Qt.AlignLeft : Qt.AlignRight

            hoverEnabled: true
            onClicked: control.closeClicked(index)
            Layout.preferredWidth: height
            Layout.fillHeight: true

            opacity: Kirigami.Settings.isMobile ? 1 : (control.hovered || control.checked ? 1 : 0)

            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            Maui.X
            {
                height: Maui.Style.iconSizes.tiny
                width: height
                anchors.centerIn: parent
                color: parent.containsMouse || parent.containsPress ? Kirigami.Theme.negativeTextColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
            }
        }
    }
}

