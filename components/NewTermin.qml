import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 6.3
import QtQuick.Layouts 1.15
import MyModule 1.0
Item {
    id: terminItem
    width: parent.width
    height: 230
    property string def: ""
    property string translate: ""
    property string image: ""
    property string tempId: ""
     signal deleteClicked(string tempId)

      ImageSaver { id: imageSaver }

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#f0f0f0"
        radius: 10
        border.color: "#3E7ECA"
        border.width: 2

        RowLayout {
            anchors.fill: parent
            spacing: 10
            anchors.margins: 10

            Column {
                id: column
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                TextField {
                    width: parent.width
                    height: 40
                    placeholderText: "Термин"
                    text: terminItem.def
                    onTextChanged: terminItem.def = text
                    font.pixelSize: 20

                    background: Rectangle {
                        radius: 5
                        border.color: "#3E7ECA"
                        border.width: 1
                    }
                }

                TextField {
                    width: parent.width
                    height: 40
                    placeholderText: "Перевод"
                    text: terminItem.translate
                    onTextChanged: terminItem.translate = text
                    font.pixelSize: 20

                    background: Rectangle {
                        radius: 5
                        border.color: "#3E7ECA"
                        border.width: 1
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 110
                    color: terminItem.image ? "transparent" : "#e0e0e0"
                    radius: 5
                    border.color: "#3E7ECA"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: terminItem.image ? "Изображение загружено" : "Перетащите изображение сюда"
                        color: "#3E7ECA"
                        visible: !imagePreview.visible
                    }

                    Image {
                        id: imagePreview
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.PreserveAspectFit
                        source: terminItem.image || ""
                        visible: terminItem.image
                    }

                    DropArea {
                        anchors.fill: parent
                        onDropped: function(drop) {
                            if (drop.hasUrls && drop.urls.length > 0) {
                                terminItem.image = drop.urls[0].toString()
                                const newPath = imageSaver.saveImage(drop.urls[0])
                                if (newPath) terminItem.image = newPath
                            }

                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: fileDialog.open()
                    }
                }
            }

            // Кнопка удаления справа от контента
            Button {
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                hoverEnabled: true

                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#FEE2E2" : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: "/images/trash.svg"
                        sourceSize: Qt.size(24, 24)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: deleteClicked(terminItem.tempId)
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Выберите изображение"
        nameFilters: ["Image files (*.png *.jpg *.jpeg)"]
        onAccepted: {
            terminItem.image = selectedFile.toString()
            const savedPath = imageSaver.saveImage(selectedFile)
                   if (savedPath) {
                       terminItem.image = savedPath // Теперь используем сохранённую копию
                   }
        }
    }
}
