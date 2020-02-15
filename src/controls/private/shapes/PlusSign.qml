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
		joinStyle: ShapePath.RoundJoin		
		strokeWidth: control.borderWidth
		strokeColor: control.color
		fillColor: "transparent"
		
		startX: control.width * 0.5; startY: 0
		PathLine { x: control.width * 0.5; y: control.height }		
	}
	
	
	ShapePath
	{
		capStyle: ShapePath.RoundCap
		joinStyle: ShapePath.RoundJoin		
		strokeWidth: control.borderWidth
		strokeColor: control.color
		fillColor: "transparent"

		startX: 0; startY: control.height * 0.5
		PathLine { x: control.width; y: control.height * 0.5}
	}
	
}
