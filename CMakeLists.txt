cmake_minimum_required(VERSION 3.16)
project(QmlApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Sql
    Quick
    QuickControls2
    Qml
    Network
)

qt_standard_project_setup()



set(APP_SOURCES
    main.cpp
    databasemanager.cpp
    termin.cpp
    dayModel.cpp
    oneday.cpp
    daymanager.cpp
    folder.cpp
)

# Все QML-файлы в одном списке
set(QML_FILES
    main.qml
    components/OneDay.qml
    components/ListOfTermins.qml
    components/TerminCard.qml
    components/ResultsScreen.qml
    components/NewTermin.qml
    pages/Home.qml
    pages/NewDay.qml
    pages/Auth.qml
    pages/Register.qml
    pages/AllTermins.qml
    components/ListOfAllTermins.qml
    components/CustomButton.qml
    components/OneFolder.qml
    pages/Folder.qml
    pages/Day.qml
    pages/EditDay.qml
)

qt_add_executable(QmlApp ${APP_SOURCES})

qt_add_qml_module(QmlApp
    URI "QmlApp"
    VERSION 1.0
    QML_FILES ${QML_FILES}
    RESOURCES resources.qrc
    SOURCES
        user.h user.cpp
        myday.h myday.cpp
        folder.h folder.cpp
        databasemanager.h databasemanager.cpp
        QML_FILES components/ListOfFolderTermins.qml
)

target_link_libraries(QmlApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Sql
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
    Qt6::Network
)

if(WIN32)
    target_link_libraries(QmlApp PRIVATE
        user32
        gdi32
        shell32
    )
endif()
