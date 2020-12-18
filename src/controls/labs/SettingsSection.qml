import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui

Maui.AlternateListItem
{
    id: control
    
    /**
     *
     */
    default property alias content : _mainData.data

    /**
         *
         */
    property int index : -1

    /**
         *
         */
    property string title

    /**
         *
         */
    property string description

    /**
         *
         */
    property alias template: _template

    /**
         *
         */
    property alias spacing: _mainData.spacing

    alt: index % 2 === 0

    Layout.fillWidth: true
    implicitHeight: _layout.implicitHeight + Maui.Style.space.big

    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        anchors.margins: Maui.Style.space.medium
        spacing: Maui.Style.space.medium

        Maui.SectionDropDown
        {
            id: _template
            Layout.fillWidth: true
            label1.text: control.title
            label2.text: control.description
            checked: true
        }

        ColumnLayout
        {
            id: _mainData
            visible: _template.checked
            Layout.fillWidth: true
            spacing: Maui.Style.space.big

            Layout.margins: Maui.Style.space.medium
        }
    }
}
