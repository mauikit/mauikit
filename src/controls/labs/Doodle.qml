import QtQuick 2.10
import QtQuick.Controls 2.10

Item 
{
    property alias mainCanvas: mainCanvas
    property alias mouseArea: mouseArea
    property variant docRequested: null
    property var docName: Qt.formatDateTime(new Date(), "yyMMddhhmmss");
    
    property var document
    
    property int brushSize:20    
    property real brushOpacity : 1
    property int brushShape : 1 //0 -Circular, 1 - rectangular.
    property alias maxBrushSize: 40
    
    Canvas 
    {
        id: mainCanvas
        smooth: true
        anchors.fill:parent
        
        onPaint:
        {
            var ctx = mainCanvas.getContext('2d');
            
            if (docRequested) 
            {
                print("doc requested")
                ctx.reset();
                ctx.fillStyle = "white";
                ctx.rect(0, 0, width, height);
                ctx.fill();
                ctx.drawImage(docRequested.contents.src, 0, 0);
                docRequested = null;
            }
        }
    }
    
    Canvas
    {
        id: pickCanvas
        width: 1
        height: 1
        visible: false
    }
    
    
    Canvas
    {
        id: buffer
        property real lastX
        property real lastY
        property color paintColor: colorPicker.paintColor
        smooth: false
        anchors.fill:parent
        opacity: control.brushOpacity // Stroke Opacity while drawing
        
        MouseArea
        {
            id: mouseArea
            anchors.fill: parent
            
            property int spacing: 32
            
            property real deltaDab: Math.max(spacing / 100 * control.brushSize, 1)
            property var points: []
            property point lastDrawPoint
            property point startPos
            property point finalPos
            property bool isColor: false
            property real brushAngle: 0
            
            onPressed: 
            {
                var point = Qt.point(mouseX, mouseY)
                points = []
                if (!isColor) 
                {
                    startPos = Qt.point(point.x, point.y)
                    finalPos = Qt.point(point.x, point.y)
                    lastDrawPoint = point
                    if (control.brushShape != 1) {//if brush is not square
                        drawDab(point)
                    }
                    points = []
                    points.push(point)
                } else
                {
                    var pc = pickCanvas.getContext("2d")
                    pc.clearRect(0, 0, 1, 1)
                    //pick color
                    var ctx = mainCanvas.getContext("2d")
                    var image = ctx.getImageData(mouseX, mouseY, mouseX+1, mouseY+1)
                    
                    // fill pick canvas with white color before drawing image on top
                    // so that when I'm picking from empty canvas, it wouldn't be 0,0,0,0
                    pc.rect(0,0,1,1);
                    pc.fillStyle="white";
                    pc.fill();
                    pc.drawImage(image, 0, 0)
                    
                    var p = pc.getImageData(0, 0, 1, 1).data
                    var hex = "#" + ("000000" + rgbToHex(p[0], p[1], p[2])).slice(-6)
                    colorPicker.paintColor = hex
                    
                    dab.requestPaint()
                }
                //Hide Color Picker later move it to the whole screen.
                colorPicker.visible = false
            }
            
            
            onPositionChanged:
            {
                if (!isColor)
                {
                    drawDab(Qt.point(mouseX, mouseY))
                    
                    
                    // **************** Fancy and intense bezier I don't quite understand yet:
                    var currentPoint = Qt.point(mouseX, mouseY)
                    var startPoint = lastDrawPoint
                    
                    
                    //Rotating the dab if brush is recangular.
                    if (control.brushShape == 1) 
                    {
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
                    
                    if (points.length == 1 || numDabs < 3)
                    {
                        var endPoint = currentPoint
                    } else 
                    {
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
            }
            
            onReleased:
            {
                if (!isColor) {
                    var bufferCtx = buffer.getContext("2d")
                    var canvasCtx = mainCanvas.getContext("2d")
                    
                    //saving image
                    // Grab Buffer image
                    var bufferImage = bufferCtx.getImageData(0, 0, width, height)
                    
                    /// Redraw the buffer image
                    canvasCtx.globalAlpha = control.brushOpacity //Stroke opacity.
                    canvasCtx.drawImage(bufferImage, 0, 0)
                    
                    mainCanvas.requestPaint()
                    
                    // Auto save painting
                    saveDrawing()
                    
                    // Clear the buffer
                    bufferCtx.clearRect(0, 0, width, height)
                    buffer.requestPaint()
                } else 
                {
                    isColor = false
                    //                     paintView.toolbar.pickColorButton.border.width = 0
                }
                
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
                ctx.fillStyle = colorPicker.paintColor
                var x = point.x - size / 2
                var y = point.y - size / 2
                
                if (control.brushShape == 0)
                {
                    ctx.beginPath();
                    x = point.x - size/8
                    y = point.y - size/8
                    ctx.arc(x, y, size/2 ,0,Math.PI*2,true);
                } else {
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
    
    
    function newPainting()
    {
        var document
        var date = new Date()
        docName = Qt.formatDateTime(date, "yyMMddhhmmss");
        
        // Fill with color on startup
        // var canvasCtx = paintView.canvasArea.mainCanvas.getContext("2d")
        // canvasCtx.globalAlpha = 1
        // canvasCtx.fillStyle = Qt.lighter(UbuntuColors.coolGrey) //"#F9D4A3" //warm
        // canvasCtx.fillRect(0, 0, mainCanvas.width, mainCanvas.height)
        
        // var bufferCtx = buffer.getContext("2d")
        // bufferCtx.fillStyle = Qt.lighter(UbuntuColors.coolGrey) //"#F9D4A3" //warm
        // bufferCtx.fillRect(0, 0, buffer.width, buffer.height)
        
        // buffer.requestPaint()
        
        mainCanvas.requestPaint()
    }
    
    function saveDrawing() 
    {
        document = {};
        document = drawingTemplate;
        document.docId = docName;
        document.contents = {"src": paintView.canvasArea.mainCanvas.toDataURL("image/png")};
    }
    
    function openDrawing(doc)
    {
        print("opening " + doc.docId)
        var docName = doc.docId;
        docRequested = doc;
        paintView.canvasArea.mainCanvas.requestPaint();
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
    
    // Find Angle
    function find_angle(A,B,C)
    {
        var AB = Math.sqrt(Math.pow(B.x-A.x,2)+ Math.pow(B.y-A.y,2));
        var BC = Math.sqrt(Math.pow(B.x-C.x,2)+ Math.pow(B.y-C.y,2));
        var AC = Math.sqrt(Math.pow(C.x-A.x,2)+ Math.pow(C.y-A.y,2));
        return Math.acos((BC*BC+AB*AB-AC*AC)/(2*BC*AB));
    }
}
