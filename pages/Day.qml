import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import MyModule 1.0
import "../components"

Item {
    id: dayPage
    property int dayId
    property string dayName
    property int folderId
    property var folderModel: ListModel {}

    function loadFolders() {
        var foldersData = databaseManager.getFoldersById(globalUser.id);
        folderModel.clear();
        foldersData.forEach(function(folder) {
            console.log("loaded folder:", folder.name)
            folderModel.append({
                id: folder.id,
                name: folder.name,
            });
        });
    }

    StackView.onStatusChanged: {
        if (StackView.status == StackView.Active) {
            loadFolders()
            console.log(folderId, "текущее idfolder")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.topMargin: 12
            spacing: 20

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
                    onClicked: stackView.pop()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Text {
                text: dayName
                font.pointSize: 22
                Layout.fillWidth: true
            }

            Button {
                text: "Редактировать день"
                flat: true

                rightPadding: 15

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 18
                    color: "#3E7ECA"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.replace(dayEdit, {id: dayId, name: dayName})
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }

            }

            Button {
                text: "Добавить в папку"
                flat: true

                rightPadding: 15

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 18
                    color: "#3E7ECA"
                }

                MouseArea {
                    anchors.fill: parent
                     onClicked: folderPopup.open()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }

            }
        }

        // Content
        ListOfTermins {
            id: listOfTermins
            Layout.fillWidth: true
            Layout.fillHeight: true
            dayId: dayPage.dayId
        }
    }

    Popup {
        id: folderPopup
        width: 300
        height: 400
        x: parent.width - width - 20
        y: 60
        padding: 10

        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#E0E0E0"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Text {
                font.pixelSize: 20
                text: "Выберите папку"
                font.bold: true
                padding: 16
                Layout.fillWidth: true
                color: "#2D3748"
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: folderListView
                    model: folderModel
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Button {
                        width: folderListView.width
                        height: 50
                        flat: true
                        text: model.name

                        contentItem: RowLayout {
                           spacing: 10

                           Text {
                               text: "✓"
                               visible: dayPage.folderId === model.id
                               color: "#3E7ECA"
                               font.bold: true
                                font.pixelSize: 18
                           }

                           Text {
                                font.pixelSize: 18
                               text: model.name
                               color: "#2D3748"
                               Layout.fillWidth: true
                           }
                           MouseArea {
                               anchors.fill: parent
                               hoverEnabled: true
                               cursorShape: Qt.PointingHandCursor
                           }
                       }

                        background: Rectangle {
                            color: parent.hovered ? "#F0F4F8" : "transparent"
                        }

                        onClicked: {
                            databaseManager.updateFolderAndDay(model.id,dayPage.dayId)
                            dayPage.folderId = model.id;
                            folderPopup.close();
                        }
                    }
                }
            }
        }
    }
}
