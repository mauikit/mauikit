import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

Kirigami.ActionToolBar
{
    id: control
    default property list<MauiLab.ToolButtonAction> mauiActions
    actions:  mauiActions
}    
