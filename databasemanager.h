// databasemanager.h
#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QMutex>
#include <QVariantMap>

class MyDay;
class Termin;
class OneDay;
class Folder;

class DatabaseManager : public QObject {
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    bool openDatabase(const QString &dbName = "users.db");

    Q_INVOKABLE OneDay* getDayById(int dayId);
    Q_INVOKABLE QList<MyDay*> getLastDaysById(int userId);
    Q_INVOKABLE QList<QVariantMap> getFoldersById(int userId);
    Q_INVOKABLE  QVariantList  getTerminsByDayId(int dayId);
    Q_INVOKABLE bool updateTerminMemoryLevel(int terminId, int memoryLevel);
    Q_INVOKABLE QList<OneDay*> getDays(int userId);
    Q_INVOKABLE QList<MyDay*> getDaysByFolderId(int folderId);
    Q_INVOKABLE QVariantList getTerminsByUserId(int dayId);
    Q_INVOKABLE QVariantList getTerminsByFolderId(int fodlerId);

    Q_INVOKABLE int addDay(const QString &name, int User_id );
    Q_INVOKABLE int addTermin(const QVariantMap &terminData);
    Q_INVOKABLE bool addFolder(const QVariantMap &Folder);

    Q_INVOKABLE bool registerUser(const QString &name, const QString &username, const QString &password);
    Q_INVOKABLE QVariantMap authenticate(const QString &username, const QString &password);
    ~DatabaseManager();
    Q_INVOKABLE bool updateFolderAndDay(int folderId, int dayId);
    Q_INVOKABLE bool updateTermin(const QVariantMap &termin);
    Q_INVOKABLE bool deleteTerminsByDayId(int dayId);
    Q_INVOKABLE bool deleteTermin(int terminId);
    Q_INVOKABLE bool updateDayName(int dayId, const QString &dayName);
    Q_INVOKABLE bool deleteFolder(int folderId);
    Q_INVOKABLE bool deleteDay(int dayId);

signals:
    void daysChanged();
    void foldersChanged();

private:
    QMutex mutex;
    bool createTables(QSqlDatabase &db);
    bool checkDatabaseConnection();
    QString m_connectionName;
    bool transaction();
    bool commit();
    void cleanupQueries();
    QSqlQuery createQuery();
    bool initializeDatabaseStructure(QSqlDatabase& db);
};

#endif
