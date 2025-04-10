#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "databaseManager.h"
#include "DayModel.h"
#include "DayManager.h"
#include "oneDay.h"
#include "termin.h"
#include "User.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    // Инициализация базы данных
    DatabaseManager dbManager;
    if (!dbManager.openDatabase("users.db")) {
        qCritical() << "Failed to open database!";
        return -1;
    }

    // Регистрация QML-типов
    qmlRegisterType<OneDay>("MyModule", 1, 0, "OneDay");
    qmlRegisterType<User>("MyModule", 1, 0, "User");
    qmlRegisterType<Termin>("MyModule", 1, 0, "Termin");
    qmlRegisterType<DayModel>("MyModule", 1, 0, "DayModel");

    // Создание моделей
    DayModel* mainDayModel = new DayModel(&dbManager);
    DayModel* folderDayModel = new DayModel(&dbManager);

    // Инициализация менеджеров
    Termin termin(&dbManager);
    DayManager dayManager(&dbManager);
    User globalUser;

    // Настройка контекста QML
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("databaseManager", &dbManager);
    engine.rootContext()->setContextProperty("globalUser", &globalUser);
    engine.rootContext()->setContextProperty("termin", &termin);
    engine.rootContext()->setContextProperty("dayManager", &dayManager);

    // Регистрация моделей
    engine.rootContext()->setContextProperty("dayModel", mainDayModel);
    engine.rootContext()->setContextProperty("folderDayModel", folderDayModel);

    // Загрузка главного QML-файла
    const QUrl url(QStringLiteral("qrc:/QmlApp/main.qml"));
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML!";
        return -1;
    }

    return app.exec();
}
