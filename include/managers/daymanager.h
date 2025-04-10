// DayManager.h
#ifndef DAYMANAGER_H
#define DAYMANAGER_H

#include <QObject>
#include "DatabaseManager.h"
#include "entities/oneday.h"

class DayManager : public QObject
{
    Q_OBJECT
public:
    explicit DayManager(DatabaseManager *dbManager, QObject *parent = nullptr)
        : QObject(parent), m_dbManager(dbManager) {}

    Q_INVOKABLE void loadDay(int id);

signals:
    void dayLoaded(const QString &dayName, int userId, int folderId);
    void loadError(const QString &error);

private:
    DatabaseManager *m_dbManager;
};

#endif
