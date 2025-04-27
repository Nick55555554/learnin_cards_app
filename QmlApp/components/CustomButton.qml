import QtQuick
import QtQuick.Controls

Button {
    property alias backgroundColor: bg.color
    property alias textColor: content.color
    property alias fontSize: content.font.pixelSize

    width: 140
    height: 40
    hoverEnabled: true

    background: Rectangle {
        id: bg
        color: "#3E7ECA"
        radius: 6
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Text {
        id: content
        text: parent.text
        color: "white"
        font {
            pixelSize: 16
            bold: true
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
