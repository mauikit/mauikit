import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control
    property int arrowWidth : 8
    property bool isCurrentListItem : ListView.isCurrentItem
    implicitWidth: _label.implicitWidth + Maui.Style.space.big + arrowWidth

    property color borderColor

    hoverEnabled: true
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered
    ToolTip.text: model.path
    background: Maui.Arrow
    {
        arrowWidth: control.arrowWidth
        color: control.isCurrentListItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : "transparent"

        borderColor:control.isCurrentListItem ?  control.Kirigami.Theme.highlightColor :  control.borderColor
    }

    signal rightClicked()

    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        onClicked:
        {
            if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                control.rightClicked()
            else
                control.clicked()
        }

        onDoubleClicked: control.doubleClicked()
        onPressAndHold : control.pressAndHold()
    }

    contentItem: Label
    {
        id: _label
        text: model.label
        anchors.fill: parent
        rightPadding: Maui.Style.space.medium
        leftPadding: rightPadding
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment:  Qt.AlignVCenter
        elide: Qt.ElideRight
        wrapMode: Text.NoWrap
        font.pointSize: Maui.Style.fontSizes.default
        color: Kirigami.Theme.textColor
    }
}
