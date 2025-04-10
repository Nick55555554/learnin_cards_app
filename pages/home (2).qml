import QtQuick 2.15
import QtQuick.Controls 2.15
import MyModule
Rectangle {
    id: mainPage
    anchors.fill: parent

    // Единственный дочерний элемент - контейнер
    Item {
        anchors.fill: parent

        // Левая панель
        Rectangle {
            width: 280
            height: parent.height
            color: "lightgray"
            anchors.left: parent.left

            Rectangle {
                width: 3
                height: parent.height
                anchors.right: parent.right
                color: "orange"
            }

            ListView {
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.leftMargin: 10
                spacing: 10
                model: dayModel

                delegate: OneDay {
                    dayName: model.name
                    dayId: model.id
                    onDayClicked: function(dayId, dayName) {
                        stackView.push(dayPage, { dayId: dayId, dayName: dayName });
                    }
                }
            }
        }

        // Правая панель
        Rectangle {
            width: 300
            height: parent.height
            anchors.right: parent.right
            color: "#f5f5f5"

            // Шапка с профилем
            Rectangle {
                id: profileHeader
                width: parent.width
                height: 60
                color: "transparent"
                anchors.top: parent.top
                anchors.right: parent.right

                // Иконка профиля
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#6200ee"
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "ИИ"
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                // Имя пользователя
                Text {
                    text: "Иван Иванов"
                    anchors.right: parent.right
                    anchors.rightMargin: 70
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                }
            }

            // Заголовок "Папки"
            Text {
                id: foldersTitle
                text: "Папки"
                font.pixelSize: 20
                font.bold: true
                anchors.top: profileHeader.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            // Кнопка "Добавить модуль"
            Button {
                id: addModuleButton
                text: "Добавить модуль"
                anchors.top: foldersTitle.bottom
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 20
                width: parent.width - 40
                height: 40
                background: Rectangle {
                    color: "#6200ee"
                    radius: 5
                }
                contentItem: Text {
                    text: addModuleButton.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Прокручиваемый список
            ScrollView {
                id: scrollView
                anchors.top: addModuleButton.bottom
                anchors.topMargin: 10
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true

                ListView {
                    id: foldersList
                    anchors.fill: parent
                    model: ListModel {
                        ListElement { name: "Работа" }
                        ListElement { name: "Личное" }
                        ListElement { name: "Проекты" }
                        ListElement { name: "Учеба" }
                    }
                    delegate: ItemDelegate {
                        width: foldersList.width
                        height: 50
                        text: name
                        font.pixelSize: 14
                    }
                    spacing: 2
                }
            }
        }

        // Центральная область
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 283
            anchors.right: parent.right
            anchors.rightMargin: 303
            height: parent.height
            color: "white"

            Text {
                anchors.centerIn: parent
                text: "Основная рабочая область"
                font.pixelSize: 18
                color: "gray"
            }
        }
    }
}
