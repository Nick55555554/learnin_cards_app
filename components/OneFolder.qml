import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
Rectangle {
    id: folderCard
    width: 280
    height: 100
    radius: 12
    color: "transparent"

    property string folderName
    property int folderId
    property var folderDays

    signal folderClicked(string folderName)

    function getDaysText(count) {
        if (count === 1) {
            return "1 день";
        } else if (count >= 2 && count <= 4) {
            return count + " дня";
        } else {
            return count + " дней";
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"
        radius: 12
        border.color: hoverHandler.hovered ? "#4A90E2" : "#EAECF0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Название папки
            Text {
                text: folderName
                Layout.fillWidth: true
                font {
                    family: "Inter"
                    pixelSize: 16
                    weight: Font.Medium
                }
                color: "#1D2939"
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }

            // Счетчик дней
            RowLayout {
                spacing: 6

                Rectangle {
                    width: 20
                    height: 20
                    radius: 6
                    color: hoverHandler.hovered ? "#EFF4FF" : "#F8F9FC"

                    Text {
                        anchors.centerIn: parent
                        text: "📁"
                        font.pixelSize: 12
                    }
                }

                Text {
                    text: qsTr("%1").arg(getDaysText(folderDays !== null ? folderDays.count : 0))
                    font {
                        family: "Inter"
                        pixelSize: 14
                        weight: Font.Normal
                    }
                    color: "#667085"
                }
            }
        }

        // Анимация при наведении
        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        // Анимация клика
        SequentialAnimation on scale {
            id: clickAnimation
            PropertyAnimation { to: 0.97; duration: 50 }
            PropertyAnimation { to: 1.0; duration: 50 }
        }
    }

    // Эффект при нажатии
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            clickAnimation.start()
            stackView.push(folderPage, {
                folderId: folderId,
                folderName: folderName,
            })
        }
    }
}

