import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

/*!
  \since org.kde.mauikit.labs 1.0
  \inqmlmodule org.kde.mauikit.labs
*/
Kirigami.Action
{
    id: control
    
    displayComponent: ToolButton
    {
        action: kirigamiAction
    }
}
