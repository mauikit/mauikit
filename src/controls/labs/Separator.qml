import QtQuick 2.14
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.8 as Kirigami

/**
 * A visual separator
 *
 * Useful for splitting one set of items from another.
 *
 * @inherit QtQuick.Rectangle
 */

Loader
{
    id: control

    sourceComponent: switch(control.position)
                     {
                     case Qt.Horizontal: return _horizontalSep
                     case Qt.Vertical: return _verticalSep
                     default: return null
                     }

    /**
      *
      */
    property int position : Qt.Horizontal
    
    /**
     * 
     */
    property int radius : 0
    
    /**
      *
      */
    property color color : Kirigami.Theme.backgroundColor

    Component
    {
        id: _horizontalSep
        ColumnLayout
        {
            spacing: 0
            opacity: 0.5

            Kirigami.Separator
            {
                implicitWidth: 1
                implicitHeight: 1
                opacity: 0.8
                color: Qt.lighter(control.color, 2.5)
                Layout.fillWidth: true
                radius: control.radius
            }

            Kirigami.Separator
            {
                implicitWidth: 1
                implicitHeight: 1
                opacity: 0.9
                color: Qt.darker(control.color, 2.5)
                Layout.fillWidth: true
                radius: control.radius
            }
        }
    }

    Component
    {
        id: _verticalSep

        RowLayout
        {
            spacing: 0
            opacity: 0.5

            Kirigami.Separator
            {
                implicitWidth: 1
                implicitHeight: 1
                opacity: 0.8
                color: Qt.lighter(control.color, 2.5)
                Layout.fillHeight: true
                radius: control.radius
            }

            Kirigami.Separator
            {
                implicitWidth: 1
                implicitHeight: 1
                opacity: 0.9
                color: Qt.darker(control.color, 2.5)
                Layout.fillHeight: true
                radius: control.radius
            }
        }
    }
}
