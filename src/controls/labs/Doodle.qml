import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
    id: control
    readonly property color bgColor : "#333"
    Kirigami.Theme.backgroundColor: Qt.rgba(bgColor.r, bgColor.g, bgColor.b, 0.85)
    Kirigami.Theme.textColor:"#fefefe"
    //     deafultButtons: false
    
    maxHeight: img.height + footer.height + Maui.Style.toolBarHeight + Maui.Style.space.medium
    maxWidth: img.width
    
    property Item sourceItem : null
    property alias source : img.source
    
    property int brushSize :20
    property real brushOpacity : 1
    property int brushShape : 1 //0 -Circular, 1 - rectangular.
    property int maxBrushSize: 100
    property color paintColor: "red"
    
    onOpened:
    {
        if(control.visible)
        {
            if(control.sourceItem)
            {
                control.sourceItem.grabToImage(function(result) {
                    img.source = result.url;
                })
            }
        }else
        {
            buffer.clear()
        }
    }
    
    onSourceItemChanged:
    {
        if(control.visible && control.opened)
        {
            if(control.sourceItem)
            {
                control.sourceItem.grabToImage(function(result) { img.source = result.url })
            }
        }
    }
    
    footBar.visible: true
    footBar.rightContent: ToolButton
    {
        icon.name: "document-share"
        onClicked: {}
    }
    
    footBar.middleContent:[ 
    
    Maui.ToolActions
    {
        autoExclusive: true
        expanded: true
        
        Action
        {
            icon.name: "draw-highlight"
            text: qsTr("Highlighter")
            onTriggered: 
            {                    
                control.paintColor = "yellow"
                control.brushOpacity = 0.4
                control.brushShape = 1
                control.brushSize = 30
            }
        }
        
        Action
        {
            icon.name: "draw-brush"
            text: qsTr("Marker")
            onTriggered: 
            {                    
                control.paintColor = "blue"
                control.brushOpacity = 0.9
                control.brushShape = 0
                control.brushSize = 20
            }
        }
        
        Action
        {
            icon.name: "draw-calligraphic"
            text: qsTr("Highlighter")
            onTriggered: 
            {                    
                control.paintColor = "#333"
                control.brushOpacity = 0.95
                control.brushShape = 1
                control.brushSize = 10
            }
        }
    },
    
    
    Maui.ToolActions
    {
        autoExclusive: true
        expanded: true
        
        Action
        {
            icon.name: "draw-rectangle"
        }
        
        Action
        {
            icon.name: "draw-circle"
        }
        
        Action
        {
            icon.name: "draw-circle"
            
        }
    },
    
    ToolButton
    {
        icon.name: "draw-watercolor"
    },
    
    ToolButton
    {
        icon.name: "draw-eraser"
    },
    
    ToolButton
    {
        icon.name: "edit-opacity"
    }
    
    
    ]
    
    
    headBar.visible: false
    ScrollView    
    {
        Layout.fillHeight: true
        Layout.fillWidth: true
        
        contentHeight: img.height
        contentWidth: img.width
        
        Image
        {
            
            id: img
            height: sourceSize.height
            width: sourceSize.width
            fillMode: Image.PreserveAspectFit
            autoTransform: true
            asynchronous: true
            anchors.centerIn: parent       
            
            Canvas 
            {
                id: pickCanvas
                width: 1
                height: 1
                visible: false
            }
            
            
            //     Label
            //     {
            //         color: "yellow"
            //         text: parent.height + "-" + parent.width + " / " + control.height + "-" + control.width + " / " + buffer.width + "-"+ buffer.height
            //     }
            
            
            Canvas
            {
                id: buffer
                
                anchors.fill: parent          
                
                property real lastX
                property real lastY
                property color paintColor: control.paintColor
                smooth: false
                
                function clear()
                {
                    var bufferCtx = buffer.getContext("2d")
                    bufferCtx.clearRect(0, 0, width, height)
                    buffer.requestPaint()
                }
                
                MouseArea 
                {
                    id: mouseArea
                    anchors.fill: parent
                    propagateComposedEvents: false
                    preventStealing: true
                    
                    property int spacing: 32
                    
                    property real deltaDab: Math.max(spacing / 100 * control.brushSize, 1)
                    property var points: []
                    property point lastDrawPoint
                    property point startPos
                    property point finalPos
                    property real brushAngle: 0
                    
                    onPressed:
                    {
                        var point = Qt.point(mouseX, mouseY)
                        points = []
                        
                        startPos = Qt.point(point.x, point.y)
                        finalPos = Qt.point(point.x, point.y)
                        lastDrawPoint = point
                        if (control.brushShape != 1)
                        {//if brush is not square
                            drawDab(point)
                        }
                        points = []
                        points.push(point)
                        
                        //Hide Color Picker later move it to the whole screen.
                        //                 colorPicker.visible = false
                    }
                    
                    
                    onPositionChanged:
                    {
                        
                        drawDab(Qt.point(mouseX, mouseY))
                        
                        // **************** Fancy and intense bezier I don't quite understand yet:
                        var currentPoint = Qt.point(mouseX, mouseY)
                        var startPoint = lastDrawPoint
                        
                        
                        //Rotating the dab if brush is recangular.
                        if (control.brushShape == 1) {
                            spacing = 16
                            
                            if ( (currentPoint.x > startPoint.x))
                            {
                                // dab.brushAngle = find_angle(Qt.point(startPoint.x, startPoint.y-10),
                                // startPoint, currentPoint)
                                // dab.requestPaint()
                                brushAngle = find_angle(Qt.point(startPoint.x, startPoint.y-10),startPoint, currentPoint)
                                
                            } else
                            {
                                // dab.brushAngle = - find_angle(Qt.point(startPoint.x, startPoint.y-10),
                                // startPoint, currentPoint)
                                // dab.requestPaint()
                                brushAngle = - find_angle(Qt.point(startPoint.x, startPoint.y-10),startPoint, currentPoint)
                                
                            }
                        } else 
                        {
                            spacing = 32
                        }
                        
                        // ##
                        var currentSpacing = Math.sqrt(Math.pow(currentPoint.x - startPoint.x, 2) + Math.pow(currentPoint.y - startPoint.y, 2))
                        var numDabs = Math.floor(currentSpacing / deltaDab)
                        
                        if (points.length == 1 || numDabs < 3) {
                            var endPoint = currentPoint
                        } else {
                            var controlPoint = points[points.length - 1]
                            endPoint = Qt.point((controlPoint.x + currentPoint.x) / 2, (controlPoint.y + currentPoint.y) / 2)
                        }
                        
                        var deltaT = 1 / numDabs
                        var betweenPoint = startPoint
                        var t = deltaT
                        var diff
                        while (t > 0 && t <= 1) {
                            var point = bezierCurve(startPoint, controlPoint, endPoint, t)
                            var deltaPoint = Math.sqrt(Math.pow(point.x - betweenPoint.x, 2) + Math.pow(point.y - betweenPoint.y, 2))
                            // check on bezier loop
                            if (diff && Math.abs(deltaPoint - deltaDab) > Math.abs(diff)) { break; }
                            diff = deltaPoint - deltaDab
                            if (Math.abs(diff <= 0.5)) {
                                drawDab(point)
                                diff = undefined
                                betweenPoint = point
                                t += deltaT
                            } else {
                                t -= diff / deltaDab * deltaT
                            }
                        }
                        points.push(currentPoint)
                        lastDrawPoint = betweenPoint
                        
                    }
                    
                    onReleased:
                    {
                        
                        var bufferCtx = buffer.getContext("2d")
                        
                        //saving image
                        // Grab Buffer image
                        var bufferImage = bufferCtx.getImageData(0, 0, width, height)
                        
                        
                        // Auto save painting
                        //                         saveDrawing()
                        
                        // Clear the buffer
                        buffer.requestPaint()
                        
                        
                    }
                    
                    function drawDab(point) 
                    {
                        var ctx = buffer.getContext("2d")
                        
                        //Bezier Dab
                        // ctx.save()
                        // var size = toolbar.maxBrushSize //toolbar.brushSize
                        // var x = point.x - size / 2
                        // var y = point.y - size / 2
                        // if (x < startPos.x) { startPos.x = Math.min(0, x) }
                        // if (y < startPos.y) { startPos.y = Math.min(0, y) }
                        // if (x > finalPos.x) { finalPos.x = Math.max(x, buffer.width) }
                        // if (y > finalPos.y) { finalPos.y = Math.max(y, buffer.height) }
                        // ctx.drawImage(dab, x, y)
                        // ctx.restore()
                        // buffer.requestPaint()
                        
                        //Raster Circle:
                        //ctx.drawImage("brushes/circle.png", x, y, size, size)
                        
                        //Simple dab
                        var size = control.brushSize
                        ctx.fillStyle =  Qt.rgba(control.paintColor.r, control.paintColor.g, control.paintColor.b, control.brushOpacity);
                        var x = point.x - size / 2
                        var y = point.y - size / 2
                        
                        if (control.brushShape == 0) 
                        {
                            ctx.beginPath();
                            x = point.x - size/8
                            y = point.y - size/8
                            ctx.arc(x, y, size/2 ,0,Math.PI*2,true);
                        } else
                        {
                            ctx.save()
                            ctx.translate(x+size/2,y+size/2)
                            ctx.beginPath()
                            ctx.rotate(brushAngle)
                            ctx.roundedRect(-size/4, -size/8, size/2, size/4, 2, 2)
                            ctx.restore()
                        }
                        ctx.fill()
                        buffer.requestPaint()
                        
                    }
                }
                
            }      
            
        }
    }
    
    
    // Bezier Curve
    function bezierCurve(start, control, end, t)
    {
        var x, y
        // linear bezier curve
        if (!control) {
            x = (1 - t) * start.x + t * end.x
            y = (1 - t) * start.y + t * end.y
        }
        // quad bezier curve
        else {
            x = Math.pow((1 - t), 2) * start.x + 2 * t * (1 - t) * control.x + t * t * end.x
            y = Math.pow((1 - t), 2) * start.y + 2 * t * (1 - t) * control.y + t * t * end.y
        }
        return Qt.point(x, y)
    }
    
    // Convert RGB to HEX
    function rgbToHex(r, g, b) 
    {
        if (r > 255 || g > 255 || b > 255)
            throw "Invalid color component";
        return ((r << 16) | (g << 8) | b).toString(16);
    }
    
    function find_angle(A,B,C) {
        var AB = Math.sqrt(Math.pow(B.x-A.x,2)+ Math.pow(B.y-A.y,2));
        var BC = Math.sqrt(Math.pow(B.x-C.x,2)+ Math.pow(B.y-C.y,2));
        var AC = Math.sqrt(Math.pow(C.x-A.x,2)+ Math.pow(C.y-A.y,2));
        return Math.acos((BC*BC+AB*AB-AC*AC)/(2*BC*AB));
    }
    
}
