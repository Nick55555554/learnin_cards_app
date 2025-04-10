import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width: 400
    height: 400
    id: termin
     property var def: ""
     property var translate: ""
     property var image: ""
    property bool isFlipped: false
    property int dragX: 0
    property int dragY: 0
     property real opacityValue: 1.0
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property point beginDrag



    Rectangle {
        id: frontRect
        width: 300
        height: 300
        color: "lightblue"
        border.color: "blue"
        border.width: 2
        radius: 10
        anchors.centerIn: parent

        Text {
            text: def
            anchors.centerIn: parent
            font.pointSize: 20
        }

        transform: [
            Rotation {
                id: frontRotation
                origin.x: frontRect.width / 2
                origin.y: frontRect.height / 2
                axis: Qt.vector3d(0, 1, 0) // Поворот вокруг оси Y
                angle: isFlipped ? 180 : 0
            },
            Scale {
                id: frontScale
                origin.x: frontRect.width / 2
                origin.y: frontRect.height / 2
                xScale: isFlipped ? 0.8 : 1.0
                yScale: isFlipped ? 0.8 : 1.0
            }
        ]

        opacity: isFlipped ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Behavior on transform { RotationAnimation { duration: 300 } }
    }

    Rectangle {
        id: backRect
        width: 300
        height: 300
        color: "lightgreen"
        border.color: "green"
        border.width: 2
        radius: 10
           anchors.centerIn: parent

        // Текст на обратной стороне
        Text {
            text: translate
            anchors.centerIn: parent
            font.pointSize: 20
        }

        transform: [
            Rotation {
                id: backRotation
                origin.x: backRect.width / 2
                origin.y: backRect.height / 2
                axis: Qt.vector3d(0, 1, 0) // Поворот вокруг оси Y
                angle: isFlipped ? 0 : 180
            },
            Scale {
                id: backScale
                origin.x: backRect.width / 2
                origin.y: backRect.height / 2
                xScale: isFlipped ? 1.0 : 0.8
                yScale: isFlipped ? 1.0 : 0.8
            }
        ]

        opacity: isFlipped ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 1000 } }
        Behavior on transform { RotationAnimation { duration: 1000 } }
    }

    MouseArea { //анимация
        id: dragArea
        anchors.fill: parent
        drag.target: parent

        onPressed: {
            if(dragX == (parent.width - width) / 2 && dragY == (parent.height - height) / 2){
                termin.beginDrag = Qt.point(termin.x,termin.y)
            }

            dragX = mouse.x;
            dragY = mouse.y;

        }
        onClicked: {
            isFlipped = !isFlipped;
        }
        onReleased: {
            if(termin.x  > parent.parent.width / 1.1){

            } else if (termin.x  < parent.parent.width /1.1 - parent.parent.width / 1.1){
            }else{
                termin.x = termin.beginDrag.x
                termin.y = termin.beginDrag.y
            }

        }

        onPositionChanged: {
            termin.x += mouse.x - dragX;
            termin.y += mouse.y - dragY;
            dragX = mouse.x;
            dragY = mouse.y;
        }
    }
}
