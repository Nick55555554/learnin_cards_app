import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import MyModule 1.0
import "./components"
import "./pages" as Pages

Window  {
    visible: true
    width: 1000
    height: 650
    title: "Memorizzali"
    color: "#f1f1f1"
    Material.theme: Material.Light
    Material.accent: Material.Blue


    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: authPage
        onCurrentItemChanged: {
               if (previousItem && previousItem.isFolderPage) {
                   folderDayModel.clear()
               }
           }
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
