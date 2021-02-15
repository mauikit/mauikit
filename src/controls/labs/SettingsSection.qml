import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui
import QtGraphicalEffects 1.0

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
    implicitHeight: _layout.implicitHeight + (Maui.Style.space.big * 2)

    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big
        spacing: Maui.Style.space.medium

        Maui.SectionDropDown
        {
            id: _template
            Layout.fillWidth: true
            label1.text: control.title
            label2.text: control.description
            checked: true
        }

        Rectangle
        {
            Layout.fillWidth: true
//             Layout.margins: Maui.Style.space.medium

            implicitHeight: _mainData.implicitHeight
            visible: _template.checked
            
            color: "transparent"

            radius: Maui.Style.radiusV
 border.color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))

            ColumnLayout
            {
                id: _mainData
                spacing: Maui.Style.space.tiny
                width: parent.width
                anchors.centerIn: parent
            }

            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: Math.floor(_mainData.width)
                    height: Math.floor(_mainData.height)

                    Rectangle
                    {
                        anchors.fill: parent
                        radius: Maui.Style.radiusV
                    }
                }
            }
        }

    }
}
