import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.0 as Kirigami
Item
{
    anchors.fill: parent

    property string emoji : "qrc:/assets/face-sleeping.png"
    property string message
    property string title
    property string body
    property color fgColor : textColor
    property bool isMask : true
    property int emojiSize : iconSizes.large

    signal actionTriggered()

    clip: true
    focus: true

    Image
    {
        id: imageHolder

        anchors.centerIn: parent
        width: emojiSize
        height: emojiSize
        source: emoji
        horizontalAlignment: Qt.AlignHCenter

        fillMode: Image.PreserveAspectFit
    }

    HueSaturation
    {
        anchors.fill: imageHolder
        source: imageHolder
        saturation: -1
        lightness: 0.3
        visible: isMask
    }

    Label
    {
        id: textHolder
        width: parent.width
        anchors.top: imageHolder.bottom
        opacity: 0.5
        text: message ? qsTr(message) : "<h3>"+title+"</h3><p>"+body+"</p>"
        font.pointSize: fontSizes.default

        padding: 10
        font.bold: true
        textFormat: Text.RichText
        horizontalAlignment: Qt.AlignHCenter
        elide: Text.ElideRight
        color: textColor
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked: actionTriggered()
    }
}


