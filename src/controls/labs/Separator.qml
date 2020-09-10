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

    property int position : Qt.Horizontal

    sourceComponent: switch(control.position)
                     {
                     case Qt.Horizontal: return _horizontalSep
                     case Qt.Vertical: return _verticalSep
                     default: return null
                     }

    property color color : Kirigami.Theme.backgroundColor

    Component
    {
        id: _horizontalSep
        ColumnLayout
        {
            spacing: 0

            Kirigami.Separator
            {
                opacity: 0.3
                color: Qt.lighter(control.color, 2.5)
                Layout.fillWidth: true
            }

            Kirigami.Separator
            {
                opacity: 0.5
                color: Qt.darker(control.color, 2.5)
                Layout.fillWidth: true
            }
        }
    }

    Component
    {
        id: _verticalSep

        RowLayout
        {
            spacing: 0
            Kirigami.Separator
            {
                opacity: 0.3
                color: Qt.lighter(control.color, 2.5)
                Layout.fillHeight: true
            }

            Kirigami.Separator
            {
                opacity: 0.5
                color: Qt.darker(control.color, 2.5)
                Layout.fillHeight: true
            }
        }
    }
}
