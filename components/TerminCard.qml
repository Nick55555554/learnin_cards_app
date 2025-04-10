import QtQuick
import QtQuick.Layouts

Item {
    id: terminContainer
    width: 500
    height: 350

    property string def
    property string translate
    property string image
    property int memoryLevel
    property bool isFlipped: false
    property real swipeDirection: 0

    signal wordRemembered()
    signal wordForgotten()

    property bool isActive: true
    property bool hasValidImage: image && image.toString().trim() !== ""

    Behavior on opacity {
        NumberAnimation { duration: 2000 }
    }

    function resetCard() {
        x = 0;
        y = 0;
        rotation = 0;
        scale = 1.0;
        isFlipped = false;
        opacity = 0;
        opacity = 1;
    }

    function cleanImagePath(path) {
        if (!path) return "";
        var cleaned = path.toString().trim();
        cleaned = cleaned.replace(/^"+|"+$/g, '');
        cleaned = cleaned.replace(/^file:\/\/\/+/, 'file:///');

        if (!cleaned.startsWith("file://") && !cleaned.startsWith("qrc:/") && cleaned !== "") {
            cleaned = "file:///" + cleaned;
        }
        return cleaned;
    }

    Rectangle {
        id: shadowRect
        anchors.fill: parent
        color: "transparent"
        border.color: "transparent"
        radius: 12

        Rectangle {
            anchors.fill: parent
            anchors.margins: -5
            color: "#80000000"
            radius: parent.radius + 5
            opacity: 0.2
        }
    }

    Rectangle {
        id: frontRect
        anchors.fill: parent
        color: "#f8f9fa"
        border.color: "#3E7ECA"
        border.width: 2
        radius: 12
        antialiasing: true

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#f0f4f8" }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Item { Layout.fillHeight: hasValidImage }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                text: terminContainer.def
                font {
                    pointSize: 20
                    weight: Font.Medium
                }
                color: "#2c3e50"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // Контейнер для изображения с обводкой
            Rectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: hasValidImage ? Math.min(parent.width - 40, 400) : 0
                Layout.preferredHeight: hasValidImage ? 250 : 0
                radius: 10
                clip: true
                visible: hasValidImage

                Image {
                    id: contentImage
                    anchors.fill: parent
                    anchors.margins: 1
                    source: hasValidImage ? cleanImagePath(image) : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.log("Ошибка загрузки изображения:", source);
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: parent.radius
                    border.width: 1
                    border.color: "black"
                }
            }

            Item { Layout.fillHeight: hasValidImage }
        }

        transform: Rotation {
            id: frontRotation
            origin.x: frontRect.width/2
            origin.y: frontRect.height/2
            axis { x: 0; y: 1; z: 0 }
            angle: terminContainer.isFlipped ? 180 : 0
            Behavior on angle { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }
        opacity: terminContainer.isFlipped ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }


    Rectangle {
        id: backRect
        anchors.fill: parent
        color: "#f8f9fa"
        border.color: "#3E7ECA"
        border.width: 2
        radius: 12
        antialiasing: true

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f0f4f8" }
            GradientStop { position: 1.0; color: "#ffffff" }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Item { Layout.fillHeight: true }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                text: terminContainer.translate
                font {
                    pointSize: 20
                    weight: Font.Medium
                }
                color: "#2c3e50"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item { Layout.fillHeight: true }
        }

        transform: Rotation {
            id: backRotation
            origin.x: backRect.width/2
            origin.y: backRect.height/2
            axis { x: 0; y: 1; z: 0 }
            angle: terminContainer.isFlipped ? 0 : 180
            Behavior on angle { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }
        opacity: terminContainer.isFlipped ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    MouseArea {
        anchors.fill: parent
        drag.target: terminContainer
        drag.axis: Drag.XAndYAxis

        property real startX: 0
        property real threshold: parent.width * 0.4

        onPressed: {
            startX = terminContainer.x;
        }

        onClicked: {
            terminContainer.isFlipped = !terminContainer.isFlipped;
        }

        onReleased: {
            var distance = Math.abs(terminContainer.x - startX);
            if (distance > threshold) {
                terminContainer.swipeDirection = Math.sign(terminContainer.x);
                if (terminContainer.swipeDirection > 0) {
                    wordRemembered();
                } else {
                    wordForgotten();
                }
            } else {
                terminContainer.x = 0;
                terminContainer.y = 0;
            }
        }
    }

    Behavior on x {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
    Behavior on y {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
}
