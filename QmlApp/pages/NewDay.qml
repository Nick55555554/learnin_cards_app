// pages/NewDay.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components" as Components

Rectangle {
    id: newDayPage
    anchors.fill: parent
    color: "#FFFFFF"

    property string moduleName: ""

    ListModel {
        id: terminsModel
        Component.onCompleted: appendTerm()
    }

    function appendTerm() {
        const tempId = Date.now().toString();
        terminsModel.append({
            "tempId": tempId,
            "def": "",
            "translate": "",
            "image": ""
        })
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 30
        }
        spacing: 25
        RowLayout {
            spacing: 25
            Layout.fillWidth: true

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
                        stackView.pop();
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
            Text {
                text: "Новый день"
                font {
                    pixelSize: 28
                    family: "Inter"
                    weight: Font.DemiBold
                }
                color: "#2D3748"
                Layout.fillWidth: true
                leftPadding: 10
            }
        }

        // Module Name Input
        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "Название модуля"
            placeholderTextColor: "#A0AEC0"
            text: newDayPage.moduleName
            onTextChanged: newDayPage.moduleName = text
            font.pixelSize: 18
            color: "#2D3748"

            background: Rectangle {
                radius: 10
                border {
                    color: parent.activeFocus ? "#4299E1" : "#E2E8F0"
                    width: 2
                }
                implicitHeight: 56

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: parent.parent.activeFocus ? "#EBF8FF" : "transparent"
                }
            }

            padding: 15
        }

        ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(
                terminsList.contentHeight + 40,
                newDayPage.height - 350
            )
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            clip: true

            ListView {
                id: terminsList
                model: terminsModel
                spacing: 15
                boundsBehavior: Flickable.StopAtBounds

                delegate: Components.NewTermin {
                    width: scroll.width - 20
                    onDefChanged: terminsModel.get(index).def = def
                    onTranslateChanged: terminsModel.get(index).translate = translate
                    onImageChanged: terminsModel.get(index).image = image
                    tempId: model.tempId
                    onDeleteClicked: {
                      for(let i = 0; i < terminsModel.count; i++) {
                          if(terminsModel.get(i).tempId === tempId) {
                              terminsModel.remove(i);
                              break;
                            }
                        }
                    }
                }
            }
        }

        // Add Term Button
        Button {
            Layout.fillWidth: true
            implicitHeight: 48
            text: "＋ Добавить термин"

            background: Rectangle {
                radius: 10
                color: parent.hovered ? "#2B6CB0" : "#4299E1"
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: Text {
                text: parent.text
                font {
                    pixelSize: 16
                    family: "Inter"
                    weight: Font.Medium
                }
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: appendTerm()
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Create Module Button
        Button {
            Layout.fillWidth: true
            implicitHeight: 52
            text: "Создать модуль"
            enabled: nameField.text.length > 0

            background: Rectangle {
                radius: 10
                color: {
                    if (!parent.enabled) return "#E2E8F0"
                    return parent.hovered ? "#38A169" : "#48BB78"
                }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: Text {
                text: parent.text
                font {
                    pixelSize: 16
                    family: "Inter"
                    weight: Font.SemiBold
                }
                color: parent.enabled ? "white" : "#A0AEC0"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var dayId = databaseManager.addDay(newDayPage.moduleName, globalUser.id)
                    if (dayId === -1) return

                    for (var i = 0; i < terminsModel.count; i++) {
                        var term = terminsModel.get(i)
                        term.dayId = dayId
                        const terminData = {
                            "dayId": dayId,
                            "translate": term.translate,
                            "def": term.def,
                            "memoryLevel": term.memoryLevel,
                            "image": term.image
                        }
                        databaseManager.addTermin(terminData)
                    }
                    stackView.pop()
                }
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
