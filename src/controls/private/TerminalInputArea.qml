/*
 * Copyright (C) 2014 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored-by: Filippo Scognamiglio <flscogna@gmail.com>
 */
import QtQuick 2.4

Item{
    property bool touchAreaPressed: false
    property real swipeDelta: units.gu(1)

    // Mouse signals
    signal mouseMoveDetected(int x, int y, int button, int buttons, int modifiers);
    signal doubleClickDetected(int x, int y, int button, int buttons, int modifiers);
    signal mousePressDetected(int x, int y, int button, int buttons, int modifiers);
    signal mouseReleaseDetected(int x, int y, int button, int buttons, int modifiers);
    signal mouseWheelDetected(int x, int y, int buttons, int modifiers, point angleDelta);

    // Touch signals
    signal touchPressAndHold(int x, int y);
    signal touchClick(int x, int y);
    signal touchPress(int x, int y);
    signal touchRelease(int x, int y);

    signal swipeYDetected(int steps);
    signal swipeXDetected(int steps);
    signal twoFingerSwipeYDetected(int steps);
    signal twoFingerSwipeXDetected(int steps);

    // Semantic signals
    signal alternateAction(int x, int y);

    function avg(p1, p2) {
        return Qt.point((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
    }

    function distance(p1, p2) {
        return Math.sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
    }

    function absFloor(val) {
        return val > 0 ? Math.floor(val) : Math.ceil(val);
    }

    MultiPointTouchArea {
        property bool __moved: false
        property bool __multiTouch: false // Decide whether this is a single or multi touch gesture before handling it. Otherwise, we run into problems while switching between the two modes.
        property point __pressPosition: Qt.point(0, 0);
        property real __prevDragStepsY: 0
        property real __prevDragStepsX: 0

        // This enum represent the status of the dragging.
        // It is used to avoid simultaneously dragging along both axies
        // as it's very error prone.

        readonly property int noDragging: 0
        readonly property int yDragging: 1
        readonly property int xDragging: 2
        property real __dragging: noDragging

        id: singleTouchTouchArea

        anchors.fill: parent
        z: parent.z + 0.01

        // TODO Interval should be the same used by all system applications.
        Timer {
            id: pressAndHoldTimer
            running: false
            onTriggered: {
                if (!parent.__moved)
                    touchPressAndHold(singleTouchTouchArea.__pressPosition.x,
                                      singleTouchTouchArea.__pressPosition.y);
            }
        }

        Timer {
            id: multiTouchTimer
            running: false
            interval: 200
        }

        maximumTouchPoints: 1
        onPressed: {
            touchAreaPressed = true;
            __moved = false;
            __multiTouch = false;
            __prevDragStepsY = 0.0;
            __prevDragStepsX = 0.0;
            __dragging = noDragging;
            __pressPosition = Qt.point(touchPoints[0].x, touchPoints[0].y);
            pressAndHoldTimer.start();
            multiTouchTimer.start(); // Detect if this is going to be a multi touch swipe while the timer is running

            touchPress(touchPoints[0].x, touchPoints[0].y);
        }
        onUpdated: {
            if (__multiTouch || multiTouchTimer.running) // Do not handle multi touch events here and detect multi touch swipes while the timer is running
                return;

            var dragValueY = touchPoints[0].y - __pressPosition.y;
            var dragValueX = touchPoints[0].x - __pressPosition.x;
            var dragStepsY = dragValueY / swipeDelta;
            var dragStepsX = dragValueX / swipeDelta;

            var dragStepsFloorY = absFloor(dragStepsY);
            var dragStepsFloorX = absFloor(dragStepsX);

            if (!__moved && distance(touchPoints[0], __pressPosition) > swipeDelta) {
                __moved = true;
                __dragging = (Math.abs(dragValueY) >= Math.abs(dragValueX)) ? yDragging : xDragging;
            } else if (!__moved) {
                return;
            }

            if (__dragging === yDragging && dragStepsFloorY !== __prevDragStepsY) {
                swipeYDetected(dragStepsFloorY - __prevDragStepsY);
            } else if (__dragging === xDragging && dragStepsFloorX !== __prevDragStepsX) {
                swipeXDetected(dragStepsFloorX - __prevDragStepsX);
            }

            __prevDragStepsY = dragStepsFloorY;
            __prevDragStepsX = dragStepsFloorX;
        }
        onReleased: {
            var timerRunning = pressAndHoldTimer.running;
            pressAndHoldTimer.stop();
            touchAreaPressed = false;

            if (!__moved && timerRunning) {
                touchClick(touchPoints[0].x, touchPoints[0].y);
            }

            touchRelease(touchPoints[0].x, touchPoints[0].y);
        }

        MultiPointTouchArea {
            property point __pressPosition: Qt.point(0, 0);
            property real __prevDragSteps: 0

            id: doubleTouchTouchArea
            anchors.fill: parent
            z: parent.z + 0.001

            maximumTouchPoints: 2
            minimumTouchPoints: 2
            onPressed: {
                if (!multiTouchTimer.running) // Already recognized as single touch swipe
                    return;

                __pressPosition = avg(touchPoints[0], touchPoints[1]);
                __prevDragSteps = 0;

                singleTouchTouchArea.__moved = true;
                singleTouchTouchArea.__multiTouch = true;
            }
            onUpdated: {
                // WORKAROUND: filter bad events that somehow get here during release.
                if (touchPoints.length !== 2)
                    return;

                if (!singleTouchTouchArea.__multiTouch)
                    return;

                var touchPoint = avg(touchPoints[0], touchPoints[1]);
                var dragValue = touchPoint.y - __pressPosition.y;
                var dragSteps = dragValue / swipeDelta;

                var dragStepsFloorY = absFloor(dragSteps);

                if (dragStepsFloorY !== __prevDragSteps) {
                    twoFingerSwipeYDetected(dragStepsFloorY - __prevDragSteps);
                }

                __prevDragSteps = dragStepsFloorY;
            }

            mouseEnabled: false
        }

        mouseEnabled: false
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: !parent.touchAreaPressed
        acceptedButtons: Qt.AllButtons
        cursorShape: Qt.IBeamCursor

        z: parent.z

        onDoubleClicked: {
            doubleClickDetected(mouse.x, mouse.y, mouse.button, mouse.buttons, mouse.modifiers);
        }
        onPositionChanged: {
            mouseMoveDetected(mouse.x, mouse.y, mouse.button, mouse.buttons, mouse.modifiers);
        }
        onPressed: {
            // Do not handle the right click if the terminal needs them.
            if (mouse.button === Qt.RightButton && !terminal.terminalUsesMouse) {
                alternateAction(mouse.x, mouse.y);
            } else {
                mousePressDetected(mouse.x, mouse.y, mouse.button, mouse.buttons, mouse.modifiers);
            }
        }
        onReleased: {
            mouseReleaseDetected(mouse.x, mouse.y, mouse.button, mouse.buttons, mouse.modifiers);
        }
        onWheel: {
            mouseWheelDetected(wheel.x, wheel.y, wheel.buttons, wheel.modifiers, wheel.angleDelta);
        }
    }
}
