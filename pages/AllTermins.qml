import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
Rectangle {
    id: pageRoot
    color: "white"
     property var termins: []

    RowLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 12

        Button {
            text: "← Назад"
            flat: true
            onClicked: stackView.pop()

            contentItem: Text {
                text: parent.text
                font.pixelSize: 18
                color: "#3E7ECA"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: stackView.pop()
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        Text {
            text: "Все термины"
            font.pointSize: 22
            Layout.leftMargin: 55
        }
    }

    ListOfAllTermins {
        id: listOfAllTermins
        anchors.centerIn: parent
        userId: globalUser.id

    }
}

