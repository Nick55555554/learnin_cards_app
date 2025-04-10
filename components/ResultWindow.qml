import QtQuick
import QtQuick.Controls

Rectangle {
    id: resultsScreen
    width: 400
    height: 300
    radius: 20
    border.color: "#4CAF50"
    border.width: 3
    color: "#f5f5f5"

    property int rememberedCount: 0
    property int forgottenCount: 0
    signal restartRequested()

    Column {
        anchors.centerIn: parent
        spacing: 30

        Text {
            text: "Результаты"
            font.pixelSize: 28
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#333"
        }

        Row {
            spacing: 40
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                spacing: 10
                horizontalAlignment: Text.AlignHCenter

                Text {
                    text: "Вспомнено"
                    font.pixelSize: 18
                    color: "#4CAF50"
                }

                Text {
                    text: resultsScreen.rememberedCount
                    font.pixelSize: 24
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                spacing: 10
                horizontalAlignment: Text.AlignHCenter

                Text {
                    text: "Забыто"
                    font.pixelSize: 18
                    color: "#F44336"
                }

                Text {
                    text: resultsScreen.forgottenCount
                    font.pixelSize: 24
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Button {
            text: "Начать заново"
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200
            height: 50

            background: Rectangle {
                color: "#4CAF50"
                radius: 10
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
            }

            onClicked: {
                restartRequested();
            }
        }
    }
}
