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
		strokeColor: control.color
		strokeWidth: control.borderWidth
		fillColor: "transparent"
		capStyle:ShapePath.RoundCap
		joinStyle: ShapePath.RoundJoin
		
		startX: 0
		startY: control.height * 0.6
		PathLine { x: control.width * 0.4 ; y: control.height }
		PathLine { x: control.width; y: 0 }
	}  
}
