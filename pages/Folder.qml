import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import MyModule 1.0
import "../components"
import "."

Item {
    id: folderPage
    anchors.fill: parent

    property string folderName
    property int folderId

    readonly property color backgroundColor: "#F5F7FB"
    readonly property color cardColor: "#FFFFFF"
    readonly property color primaryColor: "#5E7CE2"
    readonly property color textColor: "#2E384D"


    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }
    function loadDays(){
        folderDayModel.loadDataByFolderId(folderId)
    }

    Connections {
        target: databaseManager
        onDaysChanged:{
            loadDays()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Верхняя навигационная панель
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: cardColor
            layer.enabled: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                spacing: 24

                // Кнопка назад
                Button {
                    text: "← Назад"
                    flat: true

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 18
                        color: "#3E7ECA"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.replace(homePageComponent);
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }



                Text {
                    text: folderName || "Мои дни"
                    font {
                        pixelSize: 22
                    }
                    color: textColor
                }
                Item {
                   Layout.alignment: Qt.AlignRight
                   width: deleteButton.width
                   height: deleteButton.height

                   Rectangle {
                       id: deleteButton
                       width: deleteText.width + 20
                       height: 36
                       color: "transparent"
                       radius: 6

                       Text {
                           id: deleteText
                           text: "Удалить папку"
                           anchors.centerIn: parent
                           color: "red"
                           font.pixelSize: 18
                           rightPadding: 20
                       }

                       MouseArea {
                           anchors.fill: parent
                           hoverEnabled: true
                           cursorShape: Qt.PointingHandCursor
                           onClicked: deleteMenu.open()
                           onEntered: {
                               deleteText.color = "white"
                           }
                           onExited: {
                               deleteButton.color = "transparent"
                               deleteText.color = "red"
                           }
                       }
                   }

                   // Контекстное меню удаления
                   Popup {
                       id: deleteMenu
                       x: -width + deleteButton.width - 50
                       y: deleteButton.height + 8
                       width: 270
                       height: 150
                       padding: 16
                       closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                       background: Rectangle {
                           color: cardColor
                           radius: 8
                           border.color: "#E0E0E0"
                       }

                       Column {
                           spacing: 16
                           width: parent.width

                           Text {
                               text: "Вы уверены, что хотите удалить папку?"
                               width: parent.width
                               wrapMode: Text.WordWrap
                               color: textColor
                               font.pixelSize: 14
                           }

                           Row {
                               spacing: 8
                               anchors.right: parent.right

                               Button {
                                   text: "Отмена"
                                   flat: true
                                   MouseArea {
                                       anchors.fill: parent
                                        onClicked: deleteMenu.close()
                                       hoverEnabled: true
                                       cursorShape: Qt.PointingHandCursor
                                   }
                               }

                               Button {
                                   text: "Удалить"
                                   MouseArea {
                                       anchors.fill: parent
                                       onClicked: {
                                           databaseManager.deleteFolder(folderId)
                                           // folderModel.loadData()
                                           // dayModel.loadAllDays()
                                           deleteMenu.close()
                                           stackView.pop()
                                       }
                                       hoverEnabled: true
                                       cursorShape: Qt.PointingHandCursor
                                   }

                               }
                           }
                       }
                   }
               }
           }
       }


        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 24
            anchors.margins: 24

            // Панель с днями
            Rectangle {
                id: daysPanel
                Layout.preferredWidth: 400
                Layout.fillHeight: true
                color: cardColor
                radius: 12
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Заголовок списка дней
                    Text {
                        text: "Список дней"
                        font {
                            pixelSize: 18

                        }
                        color: textColor
                        leftPadding: 24
                        topPadding: 24
                        bottomPadding: 16
                    }

                    // Список дней
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                        ListView {
                            id: daysList
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8
                            model: folderDayModel

                            Connections {
                                target: folderDayModel
                            }
                            Component.onCompleted: {
                                loadDays()
                            }

                            delegate: OneDay {
                                width: daysList.width - 24
                                dayName: model.dayName
                                dayId: model.dayId
                                onDayClicked: stackView.push(dayPage, {
                                    dayId: dayId,
                                    dayName: dayName,
                                    folderId: folderId
                                })
                                onRefreshNeeded: {
                                    folderDayModel.loadDataByFolderId(folderId)
                                }
                            }


                            Label {
                                visible: daysList.count === 0
                                anchors.centerIn: parent
                                text: "Нет доступных дней"
                                font.italic: true
                                color: "#999"
                            }
                        }
                    }


                }
            }

            // Правая панель (контент)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cardColor
                radius: 12

                Label {
                    anchors.centerIn: parent
                    text: "Выберите день для просмотра"
                    color: "#999"
                }
            }
        }
    }

}
