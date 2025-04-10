#ifndef DAYMANAGER_H
#define DAYMANAGER_H
#include <QObject>
#include "DatabaseManager.h"

class DayManager : public QObject
{
    Q_OBJECT
public:
    explicit DayManager(DatabaseManager *dbManager, QObject *parent = nullptr)
        : QObject(parent), databaseManager(dbManager) {} // Сохраняем указатель на DatabaseManager

    Q_INVOKABLE void loadDay(int id);

signals:
    void dayLoaded(const QString &dayName, int userId);
    void loadError(const QString &error);

private:
    DatabaseManager *databaseManager;
};

#endif // DAYMANAGER_H
