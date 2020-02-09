import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Shapes 1.14  

Shape
{
    id: _shape
    property int arrowWidth : 8
    property color color : Kirigami.Theme.backgroundColor
    property color borderColor: Kirigami.Theme.backgroundColor
    property int borderWidth: Maui.Style.unit
    
     layer.enabled: true
        layer.samples: 4
    
    ShapePath
    {
//             joinStyle: ShapePath.RoundJoin
capStyle: ShapePath.RoundCap
        strokeWidth: _shape.borderWidth
        strokeColor: _shape.borderColor
        fillColor: _shape.color
        strokeStyle: ShapePath.SolidLine
        startX: 0; startY: 0
        PathLine { x: _shape.width - _shape.arrowWidth; y: 0 }
        PathLine { x: _shape.width; y: Math.floor(_shape.height / 2) }
        PathLine { x: _shape.width - _shape.arrowWidth; y: _shape.height }
        PathLine { x: 0; y: _shape.height}
        PathLine { x: _shape.arrowWidth; y:Math.floor(_shape.height / 2) }
        PathLine { x: 0; y: 0 }
    }
}
