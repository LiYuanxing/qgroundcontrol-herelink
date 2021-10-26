/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                      2.3
import QtQuick.Controls             1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0

import QtQuick                      2.9
import QtQuick.Window               2.2
import QtQuick.Controls             2.2

Item {
    id: pip

    property bool isHidden:  false
    property bool isDark:    false

    // As a percentage of the window width
    property real maxSize: 0.75
    property real minSize: 0.10

    property bool inPopup: false
    property bool enablePopup: true

    signal  activated()
    signal  hideIt(bool state)
    signal  newWidth(real newWidth)
    signal  popup()

    property real   _user_out1:           activeVehicle ? activeVehicle.data.user_out1.value : 0
    property real   _user_out2:           activeVehicle ? activeVehicle.data.user_out2.value : 0
    property real   _user_out3:           activeVehicle ? activeVehicle.data.user_out3.value : 0
    property real   _user_out4:           activeVehicle ? activeVehicle.data.user_out4.value : 0
    property real   _user_out5:           activeVehicle ? activeVehicle.data.user_out5.value : 0
    property real   _user_out6:           activeVehicle ? activeVehicle.data.user_out6.value : 0
    property real   _user_out7:           activeVehicle ? activeVehicle.data.user_out7.value : 0
    property real   _user_out8:           activeVehicle ? activeVehicle.data.user_out8.value : 0
    property real   _user_out9:           activeVehicle ? activeVehicle.data.user_out9.value : 0
    property real   _user_out10:           activeVehicle ? activeVehicle.data.user_out10.value : 0
    property real   _user_out11:           activeVehicle ? activeVehicle.data.user_out11.value : 0
    property real   _user_out12:           activeVehicle ? activeVehicle.data.user_out12.value : 0
    property real   _user_out13:           activeVehicle ? activeVehicle.data.user_out13.value : 0
    property real   _user_out14:           activeVehicle ? activeVehicle.data.user_out14.value : 0

    MouseArea {
        id: pipMouseArea
        anchors.fill: parent
        enabled:      !isHidden
        hoverEnabled: true
        onClicked: {
            pip.activated()
        }
    }

    // MouseArea to drag in order to resize the PiP area
    MouseArea {
        id: pipResize
        anchors.top: parent.top
        anchors.right: parent.right
        height: ScreenTools.minTouchPixels
        width: height
        property real initialX: 0
        property real initialWidth: 0

        onClicked: {
            // TODO propagate
        }

        // When we push the mouse button down, we un-anchor the mouse area to prevent a resizing loop
        onPressed: {
            pipResize.anchors.top = undefined // Top doesn't seem to 'detach'
            pipResize.anchors.right = undefined // This one works right, which is what we really need
            pipResize.initialX = mouse.x
            pipResize.initialWidth = pip.width
        }

        // When we let go of the mouse button, we re-anchor the mouse area in the correct position
        onReleased: {
            pipResize.anchors.top = pip.top
            pipResize.anchors.right = pip.right
        }

        // Drag
        onPositionChanged: {
            if (pipResize.pressed) {
                var parentW = pip.parent.width // flightView
                var newW = pipResize.initialWidth + mouse.x - pipResize.initialX
                if (newW < parentW * maxSize && newW > parentW * minSize) {
                    newWidth(newW)
                }
            }
        }
    }

    // Resize icon
    Image {
        source:         "/qmlimages/pipResize.svg"
        fillMode:       Image.PreserveAspectFit
        mipmap: true
        anchors.right:  parent.right
        anchors.top:    parent.top
        visible:        !isHidden && (ScreenTools.isMobile || pipMouseArea.containsMouse) && !inPopup
        height:         ScreenTools.defaultFontPixelHeight * 2.5
        width:          ScreenTools.defaultFontPixelHeight * 2.5
        sourceSize.height:  height
    }

    // Resize pip window if necessary when main window is resized
    property int pipLock: 2

    Connections {
        target: pip.parent
        onWidthChanged: {
            // hackity hack...
            // don't fire this while app is loading/initializing (it happens twice)
            if (pipLock) {
                pipLock--
                return
            }

            var parentW = pip.parent.width

            if (pip.width > parentW * maxSize) {
                newWidth(parentW * maxSize)
            } else if (pip.width < parentW * minSize) {
                newWidth(parentW * minSize)
            }
        }
    }

     //-- PIP Popup Indicator
    Image {
        id:             popupPIP
        source:         "/qmlimages/PiP.svg"
        mipmap:         true
        fillMode:       Image.PreserveAspectFit
        anchors.left:   parent.left
        anchors.top:    parent.top
        visible:        !isHidden && !inPopup && !ScreenTools.isMobile && enablePopup && pipMouseArea.containsMouse
        height:         ScreenTools.defaultFontPixelHeight * 2.5
        width:          ScreenTools.defaultFontPixelHeight * 2.5
        sourceSize.height:  height
        MouseArea {
            anchors.fill: parent
            onClicked: {
                inPopup = true
                pip.popup()
            }
        }
    }

    //-- PIP Corner Indicator
    Image {
        id:             closePIP
        source:         "/qmlimages/pipHide.svg"
        mipmap:         true
        fillMode:       Image.PreserveAspectFit
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        visible:        !isHidden && (ScreenTools.isMobile || pipMouseArea.containsMouse)
        height:         ScreenTools.defaultFontPixelHeight * 2.5
        width:          ScreenTools.defaultFontPixelHeight * 2.5
        sourceSize.height:  height
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pip.hideIt(true)
            }
        }
    }

    //-- Show PIP
    Rectangle {
        id:                     openPIP
        anchors.left :          parent.left
        anchors.bottom:         parent.bottom
        height:                 ScreenTools.defaultFontPixelHeight * 2
        width:                  ScreenTools.defaultFontPixelHeight * 2
        radius:                 ScreenTools.defaultFontPixelHeight / 3
        visible:                isHidden
        color:                  isDark ? Qt.rgba(0,0,0,0.75) : Qt.rgba(0,0,0,0.5)
        Image {
            width:              parent.width  * 0.75
            height:             parent.height * 0.75
            sourceSize.height:  height
            source:             "/res/buttonRight.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.verticalCenter:     parent.verticalCenter
            anchors.horizontalCenter:   parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pip.hideIt(false)
            }
        }
    }

    Button {
        id: on_off
        anchors.left:   parent.left
        anchors.top:    parent.top
        width: popupPIP.width
        height: popupPIP.height
        Text {
            text: (_user_out5 > 1900) ? "ON" : "OFF"
            font.bold: true
            anchors.centerIn: parent
            color: (_user_out5 > 1900) ? "green" : "red"
        }
        onClicked: {
            console.log("on_off");
            if(_user_out5 > 1900)
            {
                activeVehicle.requestAllParameters(5,1000)
            }else if(_user_out5 < 1100)
            {
                activeVehicle.requestAllParameters(5,2000)
            }
            console.log("on_off" + _user_out5);
        }
    }

    Button {
        id: cam_ok
        anchors.right:  pipResize.left
        anchors.top:    parent.top
        width: popupPIP.width
        height: popupPIP.height
        Text {
            text: (_user_out6 > 1900) ? "OK" : "OK"
            font.bold: true
            anchors.centerIn: parent
            color: (_user_out6 > 1900) ? "green" : "red"
        }
        onClicked: {
            console.log("cam_ok" + _user_out6);
            if(_user_out6 > 1900)
            {
                activeVehicle.requestAllParameters(6,1000)
            }else if(_user_out6 < 1100)
            {
                activeVehicle.requestAllParameters(6,2000)
            }
        }
    }

     Slider {
        id: control_led1
        value: 0
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        width: popupPIP.width*5
        height: popupPIP.height

        orientation:Qt.Horizontal
        snapMode:"SnapAlways"

        background: Rectangle {
            id: rect11
            width: control_led1.availableWidth
            height: 10
            radius: 7
            color: "darkgrey"
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: rect21
                width: control_led1.visualPosition * rect11.width
                height: rect11.height
                color: "whitesmoke"
                radius: 7
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        onValueChanged: {
            console.log("value:" + value);
            activeVehicle.requestAllParameters( 11, value * 1000 + 1000)
        }
    }

    Slider {
        id: control_led2
        value: 0
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter

        width: popupPIP.width/2
        height: popupPIP.height*5

        orientation:Qt.Vertical
        snapMode:"SnapAlways"

        background: Rectangle {
            id: rect12
            height: control_led2.availableHeight
            width: 10
            radius: 7
            color: "whitesmoke"
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: rect22
                height: control_led2.visualPosition * rect12.height
                width: rect12.width
                color: "darkgrey"
                radius: 7
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        onValueChanged: {
            console.log("value:" + value);
            activeVehicle.requestAllParameters( 10, value * 1000 + 1000)
        }
    }

    Slider {
        id: control_led3
        value: 0
        anchors.left:           parent.left
        anchors.verticalCenter: parent.verticalCenter

        width: popupPIP.width/2
        height: popupPIP.height*5

        orientation:Qt.Vertical
        snapMode:"SnapAlways"

        background: Rectangle {
            id: rect13
            height: control_led3.availableHeight
            width: 10
            radius: 7
            color: "whitesmoke"
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: rect23
                height: control_led3.visualPosition * rect13.height
                width: rect13.width
                color: "darkgrey"
                radius: 7
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        onValueChanged: {
            console.log("value:" + value);
            activeVehicle.requestAllParameters( 9, value * 1000 + 1000)
        }
    }
}
