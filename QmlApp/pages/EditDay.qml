import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components" as Components
import MyModule 1.0
Rectangle {
    id: editModulePage
    anchors.fill: parent
    color: "#FFFFFF"

    property int id: -1
    property string name

    function loadModuleData() {
        var terminsData = databaseManager.getTerminsByDayId(id)
        terminsModel.clear()
        for(var i = 0; i < terminsData.length; i++) {
            terminsModel.append({
                "id": terminsData[i].id,
                "def": terminsData[i].def,
                "translate": terminsData[i].translate,
                "image": terminsData[i].image
            })
        }
    }

    ListModel {
        id: terminsModel
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 20
        }
        spacing: 25

        // Header Section
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
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.replace("Home.qml")
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Text {
                text: "Редактирование модуля"
                font {
                    pixelSize: 24
                    family: "Inter"
                    weight: Font.DemiBold
                }
                color: "#2D3748"
                Layout.fillWidth: true
                leftPadding: 10
            }
        }

        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "Название модуля"
            placeholderTextColor: "#A0AEC0"
            text: editModulePage.name
            onTextChanged: editModulePage.name = text
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
                editModulePage.height - 330
            )
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            clip: true

            ListView {
                id: terminsList
                model: terminsModel
                spacing: 15
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    width: scroll.width - 20
                    height: 250
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        border.color: "#E2E8F0"
                        border.width: 2

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20

                            Components.NewTermin {
                                Layout.fillWidth: true
                                def: model.def
                                translate: model.translate
                                image: model.image

                                onDefChanged: terminsModel.setProperty(index, "def", def)
                                onTranslateChanged: terminsModel.setProperty(index, "translate", translate)
                                onImageChanged: terminsModel.setProperty(index, "image", image)
                                onDeleteClicked: {
                                    databaseManager.deleteTermin(model.id)
                                    terminsModel.remove(index)
                                }
                            }

                        }
                    }
                }
            }
        }
        ColumnLayout {
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: 20
                Button {
                        Layout.fillWidth: false
                        implicitWidth: 400
                        implicitHeight: 50
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

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var newId = databaseManager.addTermin({
                                    "dayId": editModulePage.id,
                                    "def": "",
                                    "translate": "",
                                    "image": ""
                                })
                                terminsModel.append({
                                    "id": newId,
                                    "def": "",
                                    "translate": "",
                                    "image": ""
                                })
                            }
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                Button {
                    Layout.fillWidth: false
                    implicitWidth: 400
                    implicitHeight: 52
                    text: "Сохранить изменения"
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
                            weight: Font.SemiBold
                        }
                        color: parent.enabled ? "white" : "#A0AEC0"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (databaseManager.updateDayName(editModulePage.id, editModulePage.name)) {
                            }
                            for(var i = 0; i < terminsModel.count; i++) {
                                var term = terminsModel.get(i)
                                databaseManager.updateTermin({
                                    "id": term.id,
                                    "def": term.def,
                                    "translate": term.translate,
                                    "memoryLevel": 0,
                                    "image": term.image
                                })
                            }

                            stackView.pop()
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

    }

    Component.onCompleted: {
        if(id !== -1) loadModuleData()
    }
}
