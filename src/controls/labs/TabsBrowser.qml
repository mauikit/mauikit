import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control
    
    property ObjectModel model : null
    
    header: Maui.TabBar
    {
        width: parent.width
    }
    
    function newTab()
    {
        
    }
    
    function closeTab(index)
    {
        
    }
}
