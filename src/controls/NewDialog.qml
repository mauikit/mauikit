import QtQuick 2.14
import QtQuick.Controls 2.14
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.2 as Maui

/**
 * NewDialog
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.Dialog
{
    id: control
    entryField: true

    /**
      * finished :
      */
    signal finished(string text)

    acceptButton.text: i18n("Accept")
    rejectButton.text: i18n("Cancel")

    onAccepted: done()
    onRejected:
    {
        textEntry.clear()
        control.close()
    }

    page.margins: Maui.Style.space.big
    spacing: Maui.Style.space.medium
    
    function done()
    {
        finished(textEntry.text)
        textEntry.clear()
        close()
    }
}
