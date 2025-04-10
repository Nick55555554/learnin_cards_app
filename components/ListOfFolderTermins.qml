import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import MyModule

Item {
    id: root
    width: 500
    height: 500

    property int folderId
    property ListModel terminsModel: ListModel {}
    property int currentIndex: -1
    property int rememberedCount: 0
    property int forgottenCount: 0
    property bool showResults: false

    SequentialAnimation {
            id: terminDisappearAnimation
            PropertyAnimation {
                target: terminLoader.item
                property: "opacity"
                to: 0
                duration: 100
            }
            ScriptAction {
                script: {
                    nextCard();
                }
            }
            PropertyAnimation {
                target: terminLoader.item
                property: "opacity"
                to: 1
                duration: 100

            }

    }

    onfolderIdChanged: loadTerminsByFolder(folderId)

    function shuffleArray(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
    }

    function loadTermins(folderId) {
        terminsModel.clear();
        var termins = databaseManager.getTerminsByFolderId(folderId);
        shuffleArray(termins);

        if (termins && termins.length > 0) {
            for (var i = 0; i < termins.length; i++) {
                terminsModel.append({
                    id: termins[i].id,
                    def: termins[i].def,
                    translate: termins[i].translate,
                    image: termins[i].image,
                    memoryLevel: termins[i].memoryLevel
                });
            }
            currentIndex = 0;
            rememberedCount = 0;
            forgottenCount = 0;
            showResults = false;
            updateTerminView();
        } else {
            currentIndex = -1;
        }
    }
    function updateTerminView() {
        if (currentIndex >= 0 && currentIndex < terminsModel.count) {
            var terminData = terminsModel.get(currentIndex);

            var onLoadedHandler = function() {
                if (terminLoader.item) {
                    terminLoader.item.def = terminData.def;
                    terminLoader.item.translate = terminData.translate;
                    terminLoader.item.image = terminData.image;
                    terminLoader.item.memoryLevel = terminData.memoryLevel;
                    terminLoader.item.resetCard();
                    terminLoader.loaded.disconnect(onLoadedHandler);
                }
            };

            if (terminLoader.item) {
                terminLoader.item.def = terminData.def;
                terminLoader.item.translate = terminData.translate;
                terminLoader.item.image = terminData.image;
                terminLoader.item.memoryLevel = terminData.memoryLevel;
                terminLoader.item.resetCard();
            } else {
                // Если Loader еще не загружен, подключаем обработчик
                terminLoader.loaded.connect(onLoadedHandler);
            }
        } else if (terminsModel.count > 0 && currentIndex >= terminsModel.count) {
            showResults = true;
        }
    }

    function nextCard() {
        if (terminsModel.count === 0) return;

        if (currentIndex + 1 >= terminsModel.count) {
            showResults = true;
            currentIndex = -1;
        } else {
            currentIndex++;
            updateTerminView();
        }
    }


    Loader {
        id: terminLoader
        anchors.centerIn: parent
        active: currentIndex >= 0 && !showResults
        visible: active
        source: "TerminCard.qml"

        onLoaded: {
            if (item) {
                item.wordRemembered.connect(function() {
                    root.rememberedCount++;
                    var terminData = terminsModel.get(root.currentIndex);
                    terminData.memoryLevel = Math.min(100, terminData.memoryLevel + 20);
                    databaseManager.updateTerminMemoryLevel(terminData.id, terminData.memoryLevel);
                    terminDisappearAnimation.start();
                });

                item.wordForgotten.connect(function() {
                    root.forgottenCount++;
                    var terminData = terminsModel.get(root.currentIndex);
                    terminData.memoryLevel = Math.max(0, terminData.memoryLevel - 40);
                    databaseManager.updateTerminMemoryLevel(terminData.id, terminData.memoryLevel);
                    terminDisappearAnimation.start();
                });

                // Обновляем данные для первой карточки
                if (root.currentIndex >= 0) {
                    var terminData = terminsModel.get(root.currentIndex);
                    item.def = terminData.def;
                    item.translate = terminData.translate;
                    item.image = terminData.image;
                    item.memoryLevel = terminData.memoryLevel;
                    item.resetCard();
                }
            }
        }
    }

    Loader {
        id: resultsLoader
        anchors.fill: parent
        active: showResults
        opacity: 1
        source: "ResultsScreen.qml"
        property int rememberedCount: root.rememberedCount
        property int forgottenCount: root.forgottenCount

        onLoaded: {
            item.rememberedCount = root.rememberedCount;
                    item.forgottenCount = root.forgottenCount;
                    item.restartRequested.connect(function() {
                        root.showResults = false;
                        root.currentIndex = 0;
                        root.rememberedCount = 0;
                        root.forgottenCount = 0;
                        root.updateTerminView();
            });
        }
    }

    Row {
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 30
        visible: terminLoader.active

        Button {
            text: "Не помню"
            width: 150
            height: 50

            background: Rectangle {
                color: "#f44336"
                radius: 10
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 18
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                if (terminLoader.item) {
                    terminLoader.item.wordForgotten();
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (terminLoader.item) {
                        terminLoader.item.wordRemembered();
                    }
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        Button {
            text: "Помню"
            width: 150
            height: 50

            background: Rectangle {
                color: "#4CAF50"
                radius: 10
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 18
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (terminLoader.item) {
                        terminLoader.item.wordRemembered();
                    }
                }
                cursorShape: Qt.PointingHandCursor
            }

        }
    }
}
