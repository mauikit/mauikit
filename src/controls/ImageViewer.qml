
import QtQuick 2.14
import QtQuick 2.14
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.7 as Kirigami

/**
 * ImageViewer
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Flickable
{
    id: flick

    /**
      * image : Image
      */
    property alias image: _imageLoader.item

    /**
      * fillMode : Image.fillMode
      */
    property int fillMode: Image.PreserveAspectFit

    /**
      * asynchronous : bool
      */
    property bool asynchronous : true

    /**
      * cache : bool
      */
    property bool cache: false

    /**
      * imageWidth : int
      */
    property int imageWidth: width

    /**
      * imageHeight : int
      */
    property int imageHeight: height

    /**
      * animated : bool
      */
    property bool animated: false

    /**
      * source : url
      */
    property url source

    /**
      * rightClicked
      */
    signal rightClicked()

    /**
      * pressAndHold
      */
    signal pressAndHold()

    contentWidth: flick.width
    contentHeight: flick.height

    interactive: contentWidth > width || contentHeight > height
    z: 1000

    ScrollBar.vertical: ScrollBar {}
    ScrollBar.horizontal: ScrollBar {}

    PinchArea
    {
        width: Math.max(flick.contentWidth, flick.width)
        height: Math.max(flick.contentHeight, flick.height)

        property real initialWidth
        property real initialHeight

        onPinchStarted:
        {
            initialWidth = flick.contentWidth
            initialHeight = flick.contentHeight
        }

        onPinchUpdated:
        {
            // adjust content pos due to drag
            flick.contentX += pinch.previousCenter.x - pinch.center.x
            flick.contentY += pinch.previousCenter.y - pinch.center.y

            // resize content
            flick.resizeContent(Math.max(flick.width*0.7, initialWidth * pinch.scale), Math.max(flick.height*0.7, initialHeight * pinch.scale), pinch.center)
        }

        onPinchFinished:
        {
            // Move its content within bounds.
            if (flick.contentWidth < flick.width || flick.contentHeight < flick.height)
            {
                zoomAnim.x = 0;
                zoomAnim.y = 0;
                zoomAnim.width = flick.width;
                zoomAnim.height = flick.height;
                zoomAnim.running = true;
            } else {
                flick.returnToBounds();
            }
        }

        ParallelAnimation
        {
            id: zoomAnim
            property real x: 0
            property real y: 0
            property real width: flick.width
            property real height: flick.height

            NumberAnimation
            {
                target: flick
                property: "contentWidth"
                from: flick.contentWidth
                to: zoomAnim.width
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

            NumberAnimation
            {
                target: flick
                property: "contentHeight"
                from: flick.contentHeight
                to: zoomAnim.height
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

            NumberAnimation
            {
                target: flick
                property: "contentY"
                from: flick.contentY
                to: zoomAnim.y
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

            NumberAnimation
            {
                target: flick
                property: "contentX"
                from: flick.contentX
                to: zoomAnim.x
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        Loader
        {
            id: _imageLoader
            width: flick.contentWidth
            height: flick.contentHeight

            sourceComponent: flick.animated ? _animatedImageComponent : _stillImageComponent

            MouseArea
            {
                anchors.fill: parent

                acceptedButtons:  Qt.RightButton | Qt.LeftButton
                onClicked:  if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                rightClicked()

                onPressAndHold: flick.pressAndHold()

                onDoubleClicked:
                {
                    if (flick.interactive) {
                        zoomAnim.x = 0;
                        zoomAnim.y = 0;
                        zoomAnim.width = flick.width;
                        zoomAnim.height = flick.height;
                        zoomAnim.running = true;
                    } else {
                        zoomAnim.x = mouse.x * 2;
                        zoomAnim.y = mouse.y *2;
                        zoomAnim.width = flick.width * 3;
                        zoomAnim.height = flick.height * 3;
                        zoomAnim.running = true;
                    }
                }

                onWheel:
                {
                    if (wheel.modifiers & Qt.ControlModifier)
                    {
                        if (wheel.angleDelta.y != 0) {
                            var factor = 1 + wheel.angleDelta.y / 600;
                            zoomAnim.running = false;

                            zoomAnim.width = Math.min(Math.max(flick.width, zoomAnim.width * factor), flick.width * 4);
                            zoomAnim.height = Math.min(Math.max(flick.height, zoomAnim.height * factor), flick.height * 4);

                            //actual factors, may be less than factor
                            var xFactor = zoomAnim.width / flick.contentWidth;
                            var yFactor = zoomAnim.height / flick.contentHeight;

                            zoomAnim.x = flick.contentX * xFactor + (((wheel.x - flick.contentX) * xFactor) - (wheel.x - flick.contentX))
                            zoomAnim.y = flick.contentY * yFactor + (((wheel.y - flick.contentY) * yFactor) - (wheel.y - flick.contentY))
                            zoomAnim.running = true;

                        } else if (wheel.pixelDelta.y != 0) {
                            flick.resizeContent(Math.min(Math.max(flick.width, flick.contentWidth + wheel.pixelDelta.y), flick.width * 4),
                                                Math.min(Math.max(flick.height, flick.contentHeight + wheel.pixelDelta.y), flick.height * 4),
                                                wheel);
                        }
                    }
                }
            }
        }

        Component
        {
            id: _animatedImageComponent
            AnimatedImage
            {
                fillMode: flick.fillMode
                autoTransform: true
                asynchronous: flick.asynchronous
                source: flick.source
                playing: true
// 				onStatusChanged: playing = (status == AnimatedImage.Ready)
                cache: flick.cache
            }
        }

        Component
        {
            id: _stillImageComponent
            Item {
                Image
                {
                    id: img
                    anchors.centerIn: parent
//                    width: Math.min(parent.width, img.implicitWidth)
//                    height: Math.min(parent.height, img.implicitHeight)
                    fillMode: flick.fillMode
                    autoTransform: true
                    asynchronous: flick.asynchronous
                    source: flick.source
                    cache: flick.cache

                    sourceSize.width : Math.min(flick.imageWidth, img.implicitWidth)
                    sourceSize.height: Math.min(flick.imageHeight, img.implicitHeight)

               BusyIndicator
                    {
                        anchors.centerIn: parent
                        running: parent.status === Image.Loading
                    }
                }
            }

        }
    }

    /**
      *
      */
    function fit()
    {
        image.width = image.sourceSize.width
    }

    /**
      *
      */
    function fill()
    {
        image.width = parent.width
    }

    /**
      *
      */
    function rotateLeft()
    {
        image.rotation = image.rotation - 90
    }

    /**
      *
      */
    function rotateRight()
    {
        image.rotation = image.rotation + 90
    }
}
