import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
Rectangle {
    id: dayCard
    width: 252
    height: 70
    color: "transparent"
    radius: 8

    property string dayName
    property int dayId
    property int folderId
    property bool isHovered: false
    signal dayClicked(int dayId, string dayName, int folderId)
    signal refreshNeeded()
    signal deleteRequested(int dayId)

    Popup {
        id: contextMenu
        x: parent.width - width - 5
        y: 35
        width: 150
        height: 130
        padding: 8
        modal: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#FFFFFF"
            radius: 6
            border.color: "#E0E0E0"

        }

        ColumnLayout {
            spacing: 4
            anchors.fill: parent

            Button {
                Layout.fillWidth: true
                height: 32
                text: "Редактировать"
                flat: true

                background: Rectangle {
                    color: parent.hovered ? "#F0F4F8" : "transparent"
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "#333333"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 8
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log(dayId, dayName, "id, Name")
                        stackView.push(dayEdit,  {id: dayId, name: dayName})
                        refreshNeeded()
                        contextMenu.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }

            Button {
                Layout.fillWidth: true
                height: 32
                text: "Удалить"
                flat: true

                background: Rectangle {
                    color: parent.hovered ? "#FEE2E2" : "transparent"
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "#DC2626"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 8
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        databaseManager.deleteDay(dayId)
                        contextMenu.close()
                    }
                }
            }
        }
    }

    Rectangle {
        id: cardContent
        anchors.fill: parent
        color: isHovered ? "#f0f4f8" : "#ffffff"
        radius: 8
        border.color: "#e0e0e0"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        // Кнопка меню
        Button {
            id: menuButton
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 8
            }
            z: 1
            width: 32
            height: 32
            flat: true
            hoverEnabled: true

            background: Rectangle {
                color: parent.hovered ? "#E0E0E0" : "transparent"
                radius: 16
                Image {
                    source: "qrc:/images/more.svg" // Используйте qrc:/ если ресурс добавлен
                    anchors.centerIn: parent // Центрируем иконку внутри кнопки
                    width: 24
                    height: 24
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: isHovered = true
                onExited: isHovered = false
                onClicked: contextMenu.open()
            }

        }
        Rectangle {
            width: 4
            height: parent.height
            color: "#3E7ECA"
            radius: 2
        }

        // Иконка дня
        Rectangle {
            id: dayIcon
            width: 36
            height: 36
            radius: 18
            color: "#3E7ECA"
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }

            Text {
                text: dayName.charAt(0).toUpperCase()
                color: "white"
                anchors.centerIn: parent
                font {
                    pixelSize: 16
                    bold: true
                }
            }
        }

        // Название дня
        Text {
            text: dayName
            anchors {
                left: dayIcon.right
                leftMargin: 12
                verticalCenter: parent.verticalCenter
                right: menuButton.left
                rightMargin: 8
            }
            font {
                pixelSize: 16
                family: "Segoe UI"
            }
            color: "#333333"
            elide: Text.ElideRight
        }

        // Эффект при наведении
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            anchors.fill: parent
            onEntered: isHovered = true
            onExited: isHovered = false
            onClicked: dayClicked(dayId, dayName, folderId)
        }

        // Анимация клика
        Rectangle {
            id: ripple
            width: 0
            height: 0
            radius: width/2
            color: "#10000000"
            anchors.centerIn: parent
            opacity: 0
        }
    }

    SequentialAnimation {
        id: clickAnimation
        PropertyAction { target: ripple; property: "opacity"; value: 1 }
        ParallelAnimation {
            NumberAnimation {
                target: ripple
                property: "width"
                from: 0
                to: dayCard.width * 2
                duration: 400
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: ripple
                property: "height"
                from: 0
                to: dayCard.width * 2
                duration: 400
                easing.type: Easing.OutQuad
            }
        }
        PropertyAction { target: ripple; property: "opacity"; value: 0 }
        PropertyAction { target: ripple; property: "width"; value: 0 }
        PropertyAction { target: ripple; property: "height"; value: 0 }
    }

    function animateClick() {
        clickAnimation.start();
    }
}
