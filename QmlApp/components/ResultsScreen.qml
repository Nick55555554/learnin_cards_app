import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: resultsScreen
    anchors.fill: parent

    property int rememberedCount
    property int forgottenCount
    signal restartRequested()
    Rectangle {
        anchors.fill: parent


        // Основное содержимое
        Column {
            anchors.centerIn: parent
            spacing: 30
            width: Math.min(parent.width * 0.8, 400)  // Адаптивная ширинаa

            Text {
                text: "Результаты"
                font.pixelSize: 28
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                color: "gray"
            }

            Row {
                spacing: 40
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    spacing: 10

                    Text {
                        text: "Вспомнено"
                        font.pixelSize: 18
                        color: "grey"
                        anchors.horizontalCenter: parent.horizontalCenter
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

                    Text {
                        text: "Забыто"
                        font.pixelSize: 18
                        color: "grey"
                        anchors.horizontalCenter: parent.horizontalCenter
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
                    color: "white"
                    radius: 10
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 18
                    color: "grey"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                hoverEnabled: true
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                onClicked: restartRequested()
            }
        }
    }
}

