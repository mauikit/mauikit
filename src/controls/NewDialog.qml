import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

Dialog
{
    width: isMobile ? parent.width * 0.7 : Kirigami.Units.devicePixelRatio * 200
    height: width * 0.7
    standardButtons: Dialog.Save | Dialog.Cancel

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: ApplicationWindow.overlay

    modal: true

    margins: 1
    padding: space.tiny*0.5

    signal finished(string text)
    property alias text : entryText.text

    TextField
    {
        id: entryText
        width: parent.width * 0.8
        anchors.centerIn: parent
        placeholderText: title
        onAccepted: done()
    }

    onAccepted: done()
    onRejected: entryText.clear()

    function done()
    {
        finished(entryText.text)
        entryText.clear()
        close()
    }
}
