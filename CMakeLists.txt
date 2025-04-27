cmake_minimum_required(VERSION 3.17)
project(QmlApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_PREFIX_PATH "C:/Qt/6.8.2/mingw_64")

# Настройки для Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
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

# Исходные файлы
set(APP_SOURCES
    src/main.cpp
    src/managers/databasemanager.cpp
    src/entities/termin.cpp
    src/models/daymodel.cpp
    src/entities/oneday.cpp
    src/managers/daymanager.cpp
    src/entities/folder.cpp
    src/entities/user.cpp
    src/entities/myday.cpp
    src/entities/imagesaver.cpp
)

# QML-файлы (убедитесь в корректности путей!)
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

qt_add_executable(QmlApp WIN32 ${APP_SOURCES})

qt_add_qml_module(QmlApp
    URI "QmlApp"
    VERSION 1.0
    QML_FILES ${QML_FILES}
    RESOURCES resources.qrc
    SOURCES
        include/entities/user.h src/entities/user.cpp
        include/entities/myday.h src/entities/myday.cpp
        include/entities/folder.h src/entities/folder.cpp
        include/managers/databasemanager.h src/managers/databasemanager.cpp
        include/entities/termin.h src/entities/termin.cpp
        include/models/daymodel.h src/models/daymodel.cpp
        include/entities/oneday.h src/entities/oneday.cpp
        include/managers/daymanager.h src/managers/daymanager.cpp
        include/entities/imagesaver.h src/entities/imagesaver.cpp
        SOURCES
)

target_include_directories(QmlApp PRIVATE
    include
    include/entities
    include/managers
    include/models
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
# Установка
install(TARGETS QmlApp DESTINATION bin)
install(FILES "images/favicon.ico" DESTINATION share/icons)

include(CPack)

set(CPACK_GENERATOR "NSIS")
set(CPACK_PACKAGE_NAME "Memorazzi")
set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_PACKAGE_DESCRIPTION "Описание вашего приложения")
set(CPACK_PACKAGE_VENDOR "Грачев Николай")
set(CPACK_PACKAGE_EXECUTABLES "QmlApp" "My Application")
