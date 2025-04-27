import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import MyModule 1.0
import "../components"
import "../pages"

Item {
    id: homePage
    anchors.fill: parent
    property var folderModel: ListModel {}
    property var days: []


    function loadDays() {
        dayModel.loadData(globalUser.id);
    }
    function loadFolders() {
        var foldersData = databaseManager.getFoldersById(globalUser.id);

        folderModel.clear();
        foldersData.forEach(function(folder) {
            folderModel.append({
                folderId: folder.id,
                folderName: folder.name,
                folderDays: folder.day_ids
            });
        });
    }


    Connections {
            target: databaseManager

            onDaysChanged: {
                loadDays()
                loadFolders()
            }

            onFoldersChanged: {
                loadFolders()
            }
        }

    StackView.onStatusChanged: {
          if (StackView.status == StackView.Active) {
              loadDays()
              loadFolders()
          }
      }


    Rectangle {
        id: header
        width: parent.width
        height: 70
        color: "white"
        anchors.top: parent.top


        Rectangle {
            width: 100
            height: 50
            radius: 50
            color: "#3E7ECA"
            id: profileIcon
            anchors {
                right: parent.right
                rightMargin: 23
                verticalCenter: parent.verticalCenter
            }
            Behavior on color {
                ColorAnimation { duration: 200 }
            }



            Text {
                id: userNameText
                text: globalUser.name
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                font {
                    pixelSize: 18
                    family: "Arial"
                }

            }

            MouseArea {
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent

                onEntered: {
                    userNameText.color = "#f1f1f1"
                }
                onExited: {
                    userNameText.color = "#333333"
                }

                onClicked: profileMenu.open()
            }
        }
        Popup {
            id: profileMenu
            x: profileIcon.x - width + profileIcon.width
            y: profileIcon.y + profileIcon.height + 10
            width: 200
            height: 80
            padding: 0
            modal: true
            dim: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: "white"
                radius: 8

            }

            Column {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    width: parent.width
                    height: 40
                    color: "transparent"

                    CustomButton {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        height: 36
                        text: "Выйти из аккаунта"
                        fontSize: 14
                        backgroundColor: "transparent"
                        textColor: "#e74c3c"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                profileMenu.close()
                                globalUser.clearUserData()
                                stackView.replace("Auth.qml")
                                databaseManager.clearSession();
                            }
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            color: parent.hovered ? "#ffeeee" : "transparent"
                        }
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#eeeeee"
                }

            }

            enter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 150
                }
                NumberAnimation {
                    property: "y"
                    from: profileIcon.y + profileIcon.height
                    to: profileIcon.y + profileIcon.height + 10
                    duration: 150
                }
            }
        }



        Text {
            text: "Memorizzali"
            anchors {
                left: parent.left
                leftMargin: 23
                verticalCenter: parent.verticalCenter
            }
            font {
                pixelSize: 20
                bold: true
            }
            color: "#3E7ECA"
        }
    }



    Rectangle {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Rectangle {
            id: leftPanel
            width: 300
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            color: "transparent"

            Text {
                id: daysTitle
                text: "Дни"
                font {
                    pixelSize: 23
                    bold: true
                }
                color: "#333333"
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 23
                }
            }

            CustomButton {
                id: addDayButton
                text: "Добавить день"
                width: 120
                height: 50
                anchors {
                    top: daysTitle.bottom
                    left: parent.left
                    right: parent.right
                    margins: 23
                    topMargin: 12
                    leftMargin: 8
                }
                onClicked: stackView.push("NewDay.qml")
            }

            ScrollView {
                anchors {
                    top: addDayButton.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 12
                }
                clip: true

                ListView {
                    id: daysList
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    model: dayModel

                    Component.onCompleted: {
                        loadDays();
                        loadFolders();

                    }
                    Connections {
                        target: dayModel
                    }

                    delegate: OneDay {
                        width: daysList.width - 24
                        dayName: model.dayName
                        dayId: model.dayId
                        folderId: model.folderId
                        onDayClicked: stackView.push(dayPage, {
                            dayId: dayId,
                            dayName: dayName,
                            folderId: folderId
                        })
                        onRefreshNeeded: {
                            loadDays()
                            loadFolders()
                        }
                    }

                }
            }
        }

        Rectangle {
            id: contentArea
             anchors {
                 top: parent.top
                 bottom: parent.bottom
                 left: leftPanel.right
                 right: parent.right
                 margins: 15
             }
             color: "white"
             radius: 8

             Column {
                 id: folderActions
                 spacing: 15
                 anchors {
                     top: parent.top
                     left: parent.left
                     right: parent.right
                     margins: 20
                     topMargin: 25
                 }

                 Row {
                     spacing: 15
                     anchors.horizontalCenter: parent.horizontalCenter

                     CustomButton {
                         id: repeatButton
                         text: "🎲 Случайные термины"
                         width: 220
                         height: 50
                         fontSize: 16
                         backgroundColor: "#4CAF50"
                         onClicked: {
                             var allTermins = databaseManager.getTerminsByUserId(globalUser.id)
                             shuffleArray(allTermins)
                             stackView.push("AllTermins.qml", { termins: allTermins })
                         }
                         function shuffleArray(array) {
                                for (let i = array.length - 1; i > 0; i--) {
                                    const j = Math.floor(Math.random() * (i + 1));
                                    [array[i], array[j]] = [array[j], array[i]];
                                }
                            }
                     }

                     CustomButton {
                         id: addFolderButton
                         text: "📁 Добавить папку"
                         width: 220
                         height: 50
                         fontSize: 16
                         backgroundColor: "#2196F3"
                         onClicked: folderDialog.open()
                     }
                 }

                 Text {
                     text: "Мои папки"
                     font {
                         pixelSize: 20
                         bold: true
                         family: "Arial"
                     }
                     color: "#333"
                     anchors.left: parent.left
                 }
             }

             ScrollView {
                 id: foldersScroll
                 anchors {
                     top: folderActions.bottom
                     bottom: parent.bottom
                     left: parent.left
                     right: parent.right
                     margins: 20
                     topMargin: 15
                 }
                 clip: true

                 ListView {
                     id: folderList
                     orientation: ListView.Horizontal
                     spacing: 20
                     model: folderModel

                     delegate: OneFolder {
                         width: 180
                         height: 120
                         folderName: model.folderName
                         folderId: model.folderId
                         folderDays: model.folderDays
                     }

                    Label {
                        anchors.centerIn: parent
                        text: "Нет созданных папок"
                        visible: folderModel.count === 0
                        font.italic: true
                        color: "gray"
                    }
                }
            }
        }
    }


    Popup {
        id: folderDialog
        width: 400
        height: 220
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        }
        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#E0E0E0"
            layer.enabled: true

        }

        Column {
            spacing: 15
            anchors.fill: parent
            padding: 20

            Text {
                text: "Новая папка"
                font {
                    pixelSize: 20
                    bold: true
                }
                color: "#3E7ECA"
            }

            TextField {
                id: folderNameInput
                width: parent.width - 40
                placeholderText: "Введите название папки"
                font.pixelSize: 16
                padding: 12
                background: Rectangle {
                    color: "#F5F5F5"
                    radius: 6
                    border.color: folderNameInput.activeFocus ? "#3E7ECA" : "#E0E0E0"
                }
            }

                Item {
                     width: parent.width - 48
                     height: 40

                     Row {
                         spacing: 12
                         anchors.right: parent.right

                         CustomButton {
                             text: "Отмена"
                             backgroundColor: "#F5F5F5"
                             textColor: "#666666"
                             onClicked: folderDialog.close()
                         }

                         CustomButton {
                             text: "Создать"
                             backgroundColor: "#2196F3"
                             textColor: "white"
                             onClicked: {
                               const folderData = {
                                   "user_id": globalUser.id,
                                   "name": folderNameInput.text

                               };

                               if (databaseManager.addFolder(folderData)) {
                                    loadFolders();
                                   folderDialog.close();
                                   folderNameInput.text = "";
                               } else {
                                   showError("Ошибка создания папки");
                                }
                            }
                        }
                    }
                }
            }
        }

    function showError(message) {
           errorText.text = message;
           errorText.visible = true;
           errorTimer.start();
       }

       Text {
           id: errorText
           visible: false
           color: "red"
       }

       Timer {
           id: errorTimer
           interval: 3000
           onTriggered: errorText.visible = false
       }

}
