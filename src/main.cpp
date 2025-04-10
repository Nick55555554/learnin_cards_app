#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "entities/user.h"
#include "entities/oneday.h"
#include "managers/databasemanager.h"
#include "models/daymodel.h"
#include "managers/daymanager.h"
#include "entities/oneday.h"
#include "entities/termin.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<OneDay>("MyModule", 1, 0, "OneDay");
    qmlRegisterType<User>("MyModule", 1, 0, "User");
    qmlRegisterType<Termin>("MyModule", 1, 0, "Termin");
    qmlRegisterType<DayModel>("MyModule", 1, 0, "DayModel");

    DatabaseManager dbManager;
    User globalUser;
    Termin termin(&dbManager);
    DayManager dayManager(&dbManager);
    OneDay day;

    DayModel* mainDayModel = new DayModel(&dbManager);
    DayModel* folderDayModel = new DayModel(&dbManager);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("databaseManager", &dbManager);
    engine.rootContext()->setContextProperty("globalUser", &globalUser);
    engine.rootContext()->setContextProperty("termin", &termin);
    engine.rootContext()->setContextProperty("dayManager", &dayManager);
    engine.rootContext()->setContextProperty("dayModel", mainDayModel);
    engine.rootContext()->setContextProperty("folderDayModel", folderDayModel);

    engine.load(QUrl(QStringLiteral("qrc:/QmlApp/main.qml")));

    return app.exec();
}
