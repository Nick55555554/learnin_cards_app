import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: registerPage
    width: parent.width
    height: parent.height
    color: "#f5f5f5"

    property bool isProcessing: false

    MessageDialog {
        id: messageDialog
        title: "Сообщение"
        buttons: MessageDialog.Ok
    }

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

    Item {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            width: Math.min(450, parent.width - 40)
            height: Math.min(500, parent.height - 40)
            anchors.centerIn: parent
            color: "white"
            radius: 8

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 15

                Text {
                    text: "Регистрация"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#3E7ECA"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 15
                }

                TextField {
                    id: nameField
                    placeholderText: "Имя"
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

                TextField {
                    id: confirmPasswordField
                    placeholderText: "Повторите пароль"
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
                    id: registerButton
                    text: "Зарегистрироваться"
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    height: 45
                    enabled: !isProcessing

                    background: Rectangle {
                        color: registerButton.enabled ?
                              (registerButton.hovered ? "#2d6cb4" : "#3E7ECA") : "#cccccc"
                        radius: 6
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: registerButton.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                    }

                    onClicked: {
                        if(nameField.text.length === 0) {
                            messageDialog.text = "Введите имя";
                            messageDialog.open();
                            return;
                        }
                        if(loginField.text.length === 0) {
                            messageDialog.text = "Введите логин";
                            messageDialog.open();
                            return;
                        }
                        if(passwordField.text.length === 0) {
                            messageDialog.text = "Введите пароль";
                            messageDialog.open();
                            return;
                        }
                        if(passwordField.text !== confirmPasswordField.text) {
                            messageDialog.text = "Пароли не совпадают";
                            messageDialog.open();
                            return;
                        }

                        isProcessing = true;
                        var success = databaseManager.registerUser(
                            nameField.text,
                            loginField.text,
                            passwordField.text
                        );

                        isProcessing = false;

                        if(success) {
                            messageDialog.text = "Регистрация прошла успешно!";
                            messageDialog.onAccepted.connect(function() {
                                stackView.pop();
                            });
                        } else {
                            messageDialog.text = "Ошибка регистрации. Возможно, логин уже занят.";
                        }
                        messageDialog.open();
                    }
                }

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: isProcessing
                    visible: isProcessing
                }

                Text {
                    text: "Уже есть аккаунт? Войти"
                    color: "#3E7ECA"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: stackView.pop()
                    }
                }
            }
        }
    }
}
