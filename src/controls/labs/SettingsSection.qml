import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

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

    alt: index % 2

    Layout.fillWidth: true
    implicitHeight: _layout.implicitHeight + (Maui.Style.space.big + _layout.spacing)

    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        anchors.margins: Maui.Style.space.medium
        spacing: Maui.Style.space.medium

        Maui.ListItemTemplate
        {
            id: _template
            Layout.fillWidth: true
            implicitHeight: label1.implicitHeight + label2.implicitHeight + Maui.Style.space.medium
            label1.text: control.title
            label2.text: control.description
            label1.font.pointSize: Maui.Style.fontSizes.big
            label1.font.bold: true
            label1.font.weight: Font.Bold
            label2.wrapMode: Text.WordWrap

            MouseArea
            {
                implicitHeight: Maui.Style.iconSizes.medium
                implicitWidth: implicitHeight

                Maui.Triangle
                {
                    height: Maui.Style.iconSizes.tiny
                    width: height
                    rotation: _mainData.visible ? -45 : -225
                    color:  Kirigami.Theme.textColor
                    opacity: 0.7
                }

                onClicked: _mainData.visible = !_mainData.visible
            }
        }

        ColumnLayout
        {
            id: _mainData
            Layout.fillWidth: true
            spacing: Maui.Style.space.big

            Layout.margins: Maui.Style.space.medium
        }
    }
}
