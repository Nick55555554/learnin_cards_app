import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import MyModule

Item {
    id: authPage
    width: parent.width
    height: parent.height


    Rectangle {
        id: header
        width: parent.width
        height: 70
        color: "white"
        anchors.top: parent.top

        Text {
            text: "Memorizzali"
            anchors.left: parent.left
            anchors.leftMargin: 23
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 20
            font.bold: true
            color: "#3E7ECA"
        }
    }


    // Диалоговое окно для сообщений
    MessageDialog {
        id: messageDialog
        title: "Сообщение"
        buttons: MessageDialog.Ok
    }

    // Основное содержимое
    Item {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // Центральная панель авторизации
        Rectangle {
            width: 400
            height: 400
            anchors.centerIn: parent
            color: "white"
            radius: 8

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 20

                Text {
                    text: "Авторизация"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#3E7ECA"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                }

                TextField {
                    id: loginField
                    placeholderText: "Логин"
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    padding: 12
                    background: Rectangle {
                        radius: 6
                        border.color: "#cccccc"
                        border.width: 1
                    }
                }

                TextField {
                    id: passwordField
                    placeholderText: "Пароль"
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    padding: 12
                    echoMode: TextInput.Password
                    background: Rectangle {
                        radius: 6
                        border.color: "#cccccc"
                        border.width: 1
                    }
                }

                Button {
                    id: loginButton
                    text: "Войти"
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    height: 45

                    background: Rectangle {
                        color: loginButton.hovered ? "#2d6cb4" : "#3E7ECA"
                        radius: 6
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: loginButton.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                    }

                    hoverEnabled: true
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    onClicked: {
                        if(loginField.text.length === 0 || passwordField.text.length === 0) {
                            messageDialog.text = "Пожалуйста, заполните все поля";
                            messageDialog.open();
                            return;
                        }

                        var userData = databaseManager.authenticate(loginField.text, passwordField.text);
                        if(userData.success) {
                            globalUser.id = userData.id;
                            globalUser.name = userData.name;
                            stackView.replace(homePageComponent)
                        } else {
                            messageDialog.text = "Ошибка авторизации: " + userData.error;
                            messageDialog.open();
                        }
                    }
                }
                Text {
                    text: "Нет аккаунта? Зарегистрируйтесь"
                    color: "#3E7ECA"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            stackView.push(Qt.resolvedUrl("Register.qml"));
                        }
                    }
                }
            }
        }
    }
}
