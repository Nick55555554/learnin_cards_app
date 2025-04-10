// pages/NewDay.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: newDayPage
    anchors.fill: parent
    color: "#f5f5f5"

    property string moduleName: ""
    property var termins: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header with back button
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Button {
                text: "← Назад"
                flat: true
                onClicked: stackView.pop()

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 16
                    color: "#6200ee"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                text: "Новый модуль"
                font.pixelSize: 24
                font.bold: true
                Layout.fillWidth: true
            }
        }

        // Module name field
        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "Название модуля"
            text: newDayPage.moduleName
            onTextChanged: newDayPage.moduleName = text
            font.pixelSize: 18
            background: Rectangle {
                radius: 8
                border.color: "#6200ee"
                border.width: 1
                implicitHeight: 50
            }
        }

        // Terms list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 15

                Repeater {
                    model: newDayPage.termins.length > 0 ? newDayPage.termins : 2
                    delegate: NewTermin {
                        id: terminDelegate
                        def: modelData ? modelData.def : ""
                        translate: modelData ? modelData.translate : ""
                        image: modelData ? modelData.image : ""
                    }
                }
            }
        }

        // Add term button
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: "Добавить термин"
            width: 200
            height: 40
            onClicked: {
                newDayPage.termins.push({"def": "", "translate": "", "image": ""})
                newDayPage.termins = newDayPage.termins // Force update
            }

            background: Rectangle {
                color: "#6200ee"
                radius: 8
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Create module button
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: "Создать модуль"
            width: 200
            height: 50
            enabled: nameField.text.length > 0

            background: Rectangle {
                color: parent.enabled ? "#4CAF50" : "#cccccc"
                radius: 8
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                // Collect all terms data
                var termsData = []
                for (var i = 0; i < newDayPage.termins.length; i++) {
                    termsData.push({
                        def: newDayPage.termins[i].def,
                        translate: newDayPage.termins[i].translate,
                        image: newDayPage.termins[i].image
                    })
                }

                // Save to database
                databaseManager.addNewModule(newDayPage.moduleName, termsData)
                stackView.pop()
            }
        }
    }
}
