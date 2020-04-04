import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Rectangle
{
    id: control
    implicitWidth: _label.implicitWidth + Maui.Style.space.big 
    
    readonly property bool hovered: _mouseArea.containsMouse
    property bool checked :  ListView.isCurrentItem
    
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: _mouseArea.containsMouse || _mouseArea.containsPress
    ToolTip.text: model.path

    signal rightClicked()
	signal clicked()
	signal doubleClicked()
	signal pressAndHold()

    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
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

    Label
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
        color: control.checked ?Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
    }
}
