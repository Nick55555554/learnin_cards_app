#include <QGuiApplication>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "entities/user.h"
#include "entities/oneday.h"
#include "managers/databasemanager.h"
#include "models/daymodel.h"
#include "managers/daymanager.h"
#include "entities/oneday.h"
#include "entities/termin.h"
#include "entities/imagesaver.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");
    qmlRegisterType<OneDay>("MyModule", 1, 0, "OneDay");
    qmlRegisterType<User>("MyModule", 1, 0, "User");
    qmlRegisterType<Termin>("MyModule", 1, 0, "Termin");
    qmlRegisterType<DayModel>("MyModule", 1, 0, "DayModel");
    qmlRegisterType<ImageSaver>("MyModule", 1, 0, "ImageSaver");
    DatabaseManager dbManager;
    if (!dbManager.openDatabase("users.db")) {
        qCritical() << "Failed to open database!";
        return -1;
    }
    User globalUser;
    Termin termin(&dbManager);
    DayManager dayManager(&dbManager);

    DayModel* mainDayModel = new DayModel(&dbManager);
    DayModel* folderDayModel = new DayModel(&dbManager);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("databaseManager", &dbManager);
    engine.rootContext()->setContextProperty("globalUser", &globalUser);
    engine.rootContext()->setContextProperty("termin", &termin);
    engine.rootContext()->setContextProperty("dayManager", &dayManager);
    engine.rootContext()->setContextProperty("dayModel", mainDayModel);
    engine.rootContext()->setContextProperty("folderDayModel", folderDayModel);

    QVariantMap userData;
    if (dbManager.tryAutoLogin(userData)) {
        globalUser.setId(userData["id"].toInt());
        globalUser.setName(userData["name"].toString());
    } else {
        qDebug() << "Auto login failed. User needs to log in manually.";
    }


    const QUrl url(QStringLiteral("qrc:/QmlApp/main.qml"));
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML!";
        return -1;
    }

    return app.exec();
}
