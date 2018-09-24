import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{   
    entryField: true
    
    signal finished(string text)
    
    acceptText: "Yes, go ahead"
    rejectText: "No, cancel"
    onAccepted: done()
    onRejected: textEntry.clear()

    function done()
    {
        finished(textEntry.text)
        textEntry.clear()
        close()
    }
}
