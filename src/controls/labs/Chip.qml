import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

ItemDelegate
{
    id: control

    hoverEnabled: !Kirigami.Settings.isMobile
    implicitHeight: Maui.Style.iconSizes.big
    implicitWidth: _layout.implicitWidth + Maui.Style.space.big

    property alias label : _label1
    property alias iconSource : _icon.source

    property bool showCloseButton : true

    ToolTip.visible: hovered
    ToolTip.text: label.text

    signal close()

    background: Rectangle
    {
        id: _background
        radius: Maui.Style.radiusV
        opacity: 0.5
        color: Qt.darker(Kirigami.Theme.backgroundColor, 1.1)
    }

    RowLayout
    {
        id: _layout
        height: parent.height
        anchors.centerIn: parent

        Kirigami.Icon
        {
            id: _icon
            implicitWidth: Maui.Style.iconSizes.small
            implicitHeight: implicitWidth
            color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(_background.color.r, _background.color.g, _background.color.b, control.hovered ?  0.4 : 0.7))
        }

        Label
        {
            id: _label1
            Layout.fillHeight: true
            verticalAlignment: Qt.AlignVCenter

        }

        MouseArea
        {
            id: _closeIcon
            visible: showCloseButton
            hoverEnabled: true

            Layout.fillHeight: true
            implicitWidth: Maui.Style.iconSizes.medium
            Layout.alignment: Qt.AlignRight
            onClicked: control.close()

            Maui.X
            {
                height: Maui.Style.iconSizes.tiny
                width: height
                anchors.centerIn: parent
                color: parent.containsMouse || parent.containsPress ? Kirigami.Theme.negativeTextColor : Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(_background.color.r, _background.color.g, _background.color.b, control.hovered ?  0.4 : 0.7))
            }
        }
    }
}
