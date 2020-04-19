import QtQuick 2.10
import QtQuick.Controls 2.10

Item 
{
    id: control
    Canvas {
        id: myCanvas
        anchors.fill: parent
        property var lastPosById
        property var posById
        
        property var colors: [
        "#00BFFF",
        "#FF69B4",
        "#F0E68C",
        "#ADD8E6",
        "#FFA07A",
        "#9370DB",
        "#98FB98",
        "#DDA0DD",
        "#FF6347",
        "#40E0D0"
        
        ]
        
        onPaint: {
            var ctx = getContext('2d')
            if (lastPosById == undefined) {
                lastPosById = {}
                posById = {}
            }
            
            for (var id in lastPosById) {
                ctx.strokeStyle = colors[id % colors.length]
                ctx.beginPath()
                ctx.moveTo(lastPosById[id].x, lastPosById[id].y)
                ctx.lineTo(posById[id].x, posById[id].y)
                ctx.stroke()
                
                // update lastpos
                lastPosById[id] = posById[id]
            }
        }
        
        MultiPointTouchArea {
            anchors.fill: parent
            
            onPressed: {
                for (var i = 0; i < touchPoints.length; ++i) {
                    var point = touchPoints[i]
                    // update both so we have data
                    myCanvas.lastPosById[point.pointId] = {
                        x: point.x,
                        y: point.y
                    }
                    myCanvas.posById[point.pointId] = {
                        x: point.x,
                        y: point.y
                    }
                }
            }
            onUpdated: {
                for (var i = 0; i < touchPoints.length; ++i) {
                    var point = touchPoints[i]
                    // only update current pos, last update set on paint
                    myCanvas.posById[point.pointId] = {
                        x: point.x,
                        y: point.y
                    }
                }
                myCanvas.requestPaint()
            }
            onReleased: {
                for (var i = 0; i < touchPoints.length; ++i) {
                    var point = touchPoints[i]
                    delete myCanvas.lastPosById[point.pointId]
                    delete myCanvas.posById[point.pointId]
                }
            }
        }
    }
}
