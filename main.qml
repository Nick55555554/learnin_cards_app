import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import MyModule 1.0
import "./components"
import "./pages" as Pages

ApplicationWindow   {
    visible: true
    width: 1000
    height: 620
    title: "Memorizzali"
    color: "#f1f1f1"
    Material.theme: Material.Light
    Material.accent: Material.Blue

    property int userId: globalUser.id
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: userId !== -1? homePageComponent : authPage
    }

    Component {
            id: authPage
            Pages.Auth {}
        }
    Component {
        id: allTermins
        Pages.AllTermins {}
    }
    Component {
        id: homePageComponent
        Pages.Home {
        }
    }
    Component {
        id: folderPage
        Pages.Folder {}
    }

    Component {
        id: newDayPage
        Pages.NewDay {}
    }
    Component {
        id: registerPage
        Pages.Register {}
    }

    Component {
      id: dayPage
      Pages.Day {}
    }
    Component {
        id: dayEdit
        Pages.EditDay {}
    }

}
