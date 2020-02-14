import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Shapes 1.12

Shape
{
    id: control
    property color color : Kirigami.Theme.backgroundColor
    property int borderWidth: 2
    
    layer.enabled: true
    layer.samples: 4
   
   ShapePath
    {
        capStyle: ShapePath.RoundCap
        strokeWidth: control.borderWidth
        strokeColor: control.color
        fillColor: "transparent"
        strokeStyle: ShapePath.SolidLine
        startX: 0; startY: 0
        PathLine { x: control.width; y: control.height }
       
    }
    
       
   ShapePath
    {
        capStyle: ShapePath.RoundCap
        strokeWidth: control.borderWidth
        strokeColor: control.color
        fillColor: "transparent"
        strokeStyle: ShapePath.SolidLine
        startX: control.width; startY: 0
        PathLine { x: 0; y: control.height }
    }
       
    }
