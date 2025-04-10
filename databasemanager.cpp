#include "databasemanager.h"
#include "termin.h"
#include "Oneday.h"
#include "myday.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QMutexLocker>
#include <QDir>
#include <QFile>
#include <QSqlDriver>
#include <QString>
#include <QStringList>
#include <QVariantMap>
#include <QVariantList>


DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent),
    m_connectionName(QString("DB_%1").arg(quintptr(this)))

{
}

DatabaseManager::~DatabaseManager() {
    QMutexLocker locker(&mutex);

    // Закрыть все запросы
    QSqlDatabase::database(m_connectionName).close();

    // Удалить все Query объекты
    if (QSqlDatabase::contains(m_connectionName)) {
        QSqlDatabase::removeDatabase(m_connectionName);
    }
}

bool DatabaseManager::initializeDatabaseStructure(QSqlDatabase& db) {
    QSqlQuery query(db);
    return query.exec("PRAGMA foreign_keys = ON")
           && createTables(db);
}

void DatabaseManager::cleanupQueries() {
    QMutexLocker locker(&mutex);

    // Закрываем все активные запросы
    auto db = QSqlDatabase::database(m_connectionName);
    if (db.isOpen()) {
        db.driver()->cancelQuery();
    }
}

bool DatabaseManager::transaction() {
    QMutexLocker locker(&mutex);
    auto db = QSqlDatabase::database(m_connectionName);
    return db.transaction();
}

bool DatabaseManager::commit() {
    QMutexLocker locker(&mutex);
    auto db = QSqlDatabase::database(m_connectionName);
    return db.commit();
}

// Общий шаблон для всех методов
QSqlQuery DatabaseManager::createQuery() {
    QMutexLocker locker(&mutex);

    if (!QSqlDatabase::contains(m_connectionName)) {
        qWarning() << "Connection not exists!";
        return QSqlQuery();
    }

    auto db = QSqlDatabase::database(m_connectionName);
    return QSqlQuery(db);
}

bool DatabaseManager::openDatabase(const QString &dbName) {
    QMutexLocker locker(&mutex);

    if (QSqlDatabase::contains(m_connectionName)) {
        auto db = QSqlDatabase::database(m_connectionName, false);
        if (db.isOpen()) return true;

        // Важно: закрыть перед повторным открытием
        db.close();
        QSqlDatabase::removeDatabase(m_connectionName);
    }

    auto db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
    db.setDatabaseName(dbName);

    if (!db.open()) {
        qCritical() << "Open error:" << db.lastError();
        return false;
    }

    return true;
}
bool DatabaseManager::createTables(QSqlDatabase& db) {
    QSqlQuery query(db);
    bool success = true;

    success &= query.exec(
        "CREATE TABLE IF NOT EXISTS Users ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT NOT NULL,"
        "email TEXT UNIQUE NOT NULL)"
        );
    if (!success) qCritical() << "Users table error:" << query.lastError().text();

    // Таблица Days
    success &= query.exec(
        "CREATE TABLE IF NOT EXISTS Days ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT NOT NULL,"
        "user_id INTEGER,"
        "Folder_id INTEGER"
        "FOREIGN KEY(user_id) REFERENCES Users(id))"
        );
    if (!success) qCritical() << "Days table error:" << query.lastError().text();

    // Таблица Termins
    success &= query.exec(
        "CREATE TABLE IF NOT EXISTS Termins ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "description TEXT NOT NULL,"
        "day_id INTEGER,"
        "FOREIGN KEY(day_id) REFERENCES Days(id) ON DELETE CASCADE)"
        );
    if (!success) qCritical() << "Termins table error:" << query.lastError().text();

    success &= query.exec(
        "CREATE TABLE IF NOT EXISTS Folders ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT NOT NULL,"
        "user_id INTEGER,"
        "day_ids TEXT,"
        "FOREIGN KEY(user_id) REFERENCES Users(id))"
        );
    if (!success) qCritical() << "Termins table error:" << query.lastError().text();

    return success;
}

QList<OneDay*> DatabaseManager::getDays(int userId) {
    QList<OneDay*> days;

    if (!openDatabase()) return days;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("SELECT id, name FROM Days WHERE user_Id = ?");
        query.addBindValue(userId);

        if (query.exec()) {
            while (query.next()) {
                OneDay *day = new OneDay(this);
                day->setId(query.value(0).toInt());
                day->setName(query.value(1).toString());
                days.append(day);
            }
        } else {
            qWarning() << "Error in getDays: see it" << query.lastError().text();
        }
    }
    return days;
}
QList<MyDay*> DatabaseManager::getDaysByFolderId(int folderId) {
    QList<MyDay*> days;

    if (!openDatabase()) return days;
    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("SELECT id, DayName FROM Days WHERE Folder_id = ?");
        query.addBindValue(folderId);

        if (query.exec()) {
            while (query.next()) {
                MyDay *day = new MyDay(this);
                day->setId(query.value(0).toInt());
                day->setName(query.value(1).toString());
                days.append(day);
            }
        } else {
            qWarning() << "Error in getLastDaysById:" << query.lastError().text();
        }
    }

    return days;
}


QVariantList DatabaseManager::getTerminsByDayId(int dayId) {
    QVariantList termins;

    if (!openDatabase()) return termins;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("SELECT ID, Def, translate, memoryLevel, image FROM Termins WHERE Day_id = ?");
        query.addBindValue(dayId);
        if (query.exec()) {
            while (query.next()) {
                QVariantMap terminMap;
                terminMap["id"] = query.value(0).toInt();
                terminMap["def"] = query.value(1).toString();
                terminMap["translate"] = query.value(2).toString();
                terminMap["image"] = query.value(4).toString();
                terminMap["memoryLevel"] = query.value(3).toInt();
                termins.append(terminMap);
            }
        } else {
            qWarning() << "Error in getTerminsByDayId:" << query.lastError().text();
        }
    }

    return termins;
}

QVariantList DatabaseManager::getTerminsByUserId(int userId) {
    QVariantList termins;

    if (!openDatabase()) {
        return termins;
    }

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare(
            "SELECT Termins.id, Termins.def, Termins.translate, Termins.memoryLevel, Termins.image "
            "FROM Termins "
            "INNER JOIN Days ON Termins.day_Id = Days.id "
            "WHERE Days.user_id = ?"
            );
        query.addBindValue(userId);

        if (query.exec()) {
            while (query.next()) {
                QVariantMap terminMap;
                terminMap["id"] = query.value(0).toInt();
                terminMap["def"] = query.value(1).toString();
                terminMap["translate"] = query.value(2).toString();
                terminMap["memoryLevel"] = query.value(3).toInt();
                terminMap["image"] = query.value(4).toString();
                termins.append(terminMap);
            }
        } else {
            qWarning() << "Error in getTerminsByUserId:" << query.lastError().text();
        }
    }
    return termins;
}

bool DatabaseManager::updateTerminMemoryLevel(int terminId, int memoryLevel) {

    if (!openDatabase()) return false;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("UPDATE Termins SET memoryLevel = ? WHERE id = ?");
        query.addBindValue(memoryLevel);
        query.addBindValue(terminId);

        return query.exec();
    }
}

int DatabaseManager::addDay(const QString &name, int User_id) {

    if (!openDatabase()) return -1;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("INSERT INTO Days (user_id, dayName) VALUES (?, ?)");
        query.addBindValue(User_id);
        query.addBindValue(name);

        if (query.exec()) {
            return query.lastInsertId().toInt();
        }
        qWarning() << "Error adding day:" << query.lastError().text();
    }
    return -1;
}
int DatabaseManager::addTermin(const QVariantMap &terminData) {
    if (!openDatabase()) return -1; // Возвращаем -1 в случае ошибки открытия базы данных

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("INSERT INTO Termins (Day_id, translate, def, memoryLevel, image) "
                      "VALUES (:dayId, :translate, :def, :memoryLevel, :image)");

        query.bindValue(":dayId", terminData["dayId"].toInt());
        query.bindValue(":translate", terminData["translate"].toString());
        query.bindValue(":def", terminData["def"].toString());
        query.bindValue(":memoryLevel", terminData["memoryLevel"].toInt());
        query.bindValue(":image", terminData["image"].toString());

        if (!query.exec()) {
            qWarning() << "Ошибка добавления термина:" << query.lastError().text();
            return -1; // Возвращаем -1 в случае ошибки выполнения запроса
        }

        // Получаем новое ID
        return query.lastInsertId().toInt();
    }
}


bool DatabaseManager::addFolder(const QVariantMap &folder) {
    if (!openDatabase()) return false;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("INSERT INTO Folders (user_id, name) "
                      "VALUES (:user_id, :name)");

        // Добавлена валидация данных
        if (!folder.contains("user_id") || !folder.contains("name")) {
            qWarning() << "Invalid folder data";
            return false;
        }

        query.bindValue(":user_id", folder["user_id"].toInt());
        query.bindValue(":name", folder["name"].toString());

        if (!query.exec()) {
            qWarning() << "Ошибка добавления термина:" << query.lastError().text();
            return false;
        }
    }
    return true;
}


OneDay* DatabaseManager::getDayById(int dayId) {
    if (!openDatabase()) return nullptr;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("SELECT user_Id, DayName FROM Days WHERE id = ?");
        query.addBindValue(dayId);

        if (query.exec() && query.next()) {
            OneDay *day = new OneDay();
            day->setId(dayId);
            day->setUserId(query.value(0).toInt());
            day->setName(query.value(1).toString());
            return day;
        }
    }
    return nullptr;
}

QList<MyDay*> DatabaseManager::getLastDaysById(int userId) {
    QList<MyDay*> days;

    if (!openDatabase()) return days;
    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("SELECT id, DayName, Folder_id FROM Days WHERE User_id = ? ORDER BY id DESC LIMIT 5");
        query.addBindValue(userId);

        if (query.exec()) {
            while (query.next()) {
                MyDay *day = new MyDay(this);
                day->setId(query.value(0).toInt());
                day->setName(query.value(1).toString());
                day->setFolderId(query.value(2).toInt());
                days.append(day);
            }
        } else {
            qWarning() << "Error in getLastDaysById:" << query.lastError().text();
        }
    }

    return days;
}

QList<QVariantMap> DatabaseManager::getFoldersById(int userId) {
    QList<QVariantMap> folders;

    if (!openDatabase()) return folders;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);

        query.prepare(R"(
            SELECT f.id, f.name,
                   (SELECT GROUP_CONCAT(d.id)
                    FROM Days d
                    WHERE d.Folder_id = f.id) AS day_ids
            FROM Folders f
            WHERE f.user_id = ?
            ORDER BY f.id DESC
        )");
        query.addBindValue(userId);

        if (query.exec()) {
            while (query.next()) {
                QVariantMap folder;
                folder["id"] = query.value("id");
                folder["name"] = query.value("name");
                const QString dayIdsString = query.value("day_ids").toString();
                QStringList dayIdsList = dayIdsString.split(",", Qt::SkipEmptyParts);
                QVariantList dayIdsVariantList;
                for (auto it = dayIdsList.constBegin(); it != dayIdsList.constEnd(); ++it) {
                    dayIdsVariantList.append(it->toInt());

                }

                folder["day_ids"] = dayIdsVariantList;
                folders.append(folder);
            }
        } else {
            qDebug() << "SQL Error:" << query.lastError().text()
            << "| Query:" << query.lastQuery();
            return folders;
        }
    }

    return folders;
}

bool DatabaseManager::registerUser(const QString &name, const QString &username, const QString &password) {

        if (!openDatabase()) return false;

        {
            QMutexLocker locker(&mutex);
            QSqlDatabase db = QSqlDatabase::database(m_connectionName);
            QSqlQuery query(db);
            query.prepare("INSERT INTO Users (name, username, password) VALUES (?, ?, ?)");
            query.addBindValue(name);
            query.addBindValue(username);
            query.addBindValue(password);

            if (query.exec()) {
                return true;
            }
            qWarning() << "Error registering user:" << query.lastError().text();
        }

    return false;
}




QVariantMap DatabaseManager::authenticate(const QString &username, const QString &password) {
    QVariantMap result;

    if (!openDatabase()) {
        result["success"] = false;
        result["error"] = "Database connection failed";
        return result;
    }

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);

        query.prepare("SELECT id, name FROM Users WHERE username = ? AND password = ?");
        query.addBindValue(username);
        query.addBindValue(password);

        if (!query.exec()) {
            result["success"] = false;
            result["error"] = "Database error: " + query.lastError().text();
            return result;
        }

        if (query.next()) {
            result["success"] = true;
            result["id"] = query.value(0).toInt();
            result["name"] = query.value(1).toString();
        } else {
            result["success"] = false;
            result["error"] = "Invalid credentials";
        }
    }
    return result;
}


bool DatabaseManager::updateFolderAndDay(int folderId, int dayId) {
    if (!openDatabase()) return false;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);

        if (!db.transaction()) {
            qDebug() << "Transaction Error:" << db.lastError().text();
            return false;
        }

        query.prepare(R"(
            UPDATE Days
            SET Folder_id = ?
            WHERE id = ?
        )");
        query.addBindValue(folderId);
        query.addBindValue(dayId);

        if (!query.exec()) {
            qDebug() << "SQL Error (Update Day):" << query.lastError().text()
            << "| Query:" << query.lastQuery();
            db.rollback(); // Откат транзакции в случае ошибки
            return false;
        }

        // Обновление папки: добавляем dayId в day_ids
        query.prepare(R"(
            UPDATE Folders
            SET day_ids = CASE
                WHEN day_ids IS NULL OR day_ids = '' THEN ?
                ELSE CONCAT(day_ids, ',', ?)
            END
            WHERE id = ?
        )");
        query.addBindValue(dayId);
        query.addBindValue(dayId);
        query.addBindValue(folderId);

        // Выполнение запроса на обновление папки
        if (!query.exec()) {
            qDebug() << "SQL Error (Update Folder):" << query.lastError().text()
            << "| Query:" << query.lastQuery();
            db.rollback(); // Откат транзакции в случае ошибки
            return false;
        }

        // Подтверждение транзакции
        if (!db.commit()) {
            qDebug() << "Commit Error:" << db.lastError().text();
            return false;
        }
    }

    return true;
}
bool DatabaseManager::updateTermin(const QVariantMap &termin) {
    if (!openDatabase()) return false;

    QMutexLocker locker(&mutex);
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);

    // Проверяем, существует ли термин с данным ID
    query.prepare("SELECT COUNT(*) FROM Termins WHERE ID = ?");
    query.addBindValue(termin["id"].toInt());

    if (!query.exec()) {
        qWarning() << "Error checking existence of term with ID" << termin["id"].toInt() << ":" << query.lastError().text();
        return false;
    }

    query.next();
    int count = query.value(0).toInt();

    if (count > 0) {
        query.prepare("UPDATE Termins SET Def = ?, translate = ?, memoryLevel = ?, image = ? WHERE ID = ?");
        query.addBindValue(termin["def"].toString());
        query.addBindValue(termin["translate"].toString());
        query.addBindValue(termin["memoryLevel"].toInt());
        query.addBindValue(termin["image"].toString());
        query.addBindValue(termin["id"].toInt());

        if (!query.exec()) {
            qWarning() << "Error updating term with ID" << termin["id"].toInt() << ":" << query.lastError().text();
            return false;
        }
    }

    return true;
}


bool DatabaseManager::deleteTerminsByDayId(int dayId) {
    if (!openDatabase()) return false;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);

        // Начинаем транзакцию
        if (!db.transaction()) {
            qWarning() << "Failed to start transaction:" << db.lastError().text();
            return false;
        }

        // Подготовка запроса для удаления терминов
        query.prepare("DELETE FROM Termins WHERE Day_id = ?");
        query.addBindValue(dayId);

        if (!query.exec()) {
            qWarning() << "Error deleting terms for Day_id" << dayId << ":" << query.lastError().text();
            // Откатываем транзакцию в случае ошибки
            db.rollback();
            return false;
        }

        // Завершаем транзакцию
        if (!db.commit()) {
            qWarning() << "Failed to commit transaction:" << db.lastError().text();
            return false;
        }
    }

    return true;
}

bool DatabaseManager::deleteTermin(int terminId) {
    if (!openDatabase()) return false;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);

        // Начинаем транзакцию
        if (!db.transaction()) {
            qWarning() << "Failed to start transaction:" << db.lastError().text();
            return false;
        }

        // Подготовка запроса для удаления терминов
        query.prepare("DELETE FROM Termins WHERE id = ?");
        query.addBindValue(terminId);

        if (!query.exec()) {
            qWarning() << "Error deleting terms for Day_id" << terminId << ":" << query.lastError().text();
            // Откатываем транзакцию в случае ошибки
            db.rollback();
            return false;
        }

        // Завершаем транзакцию
        if (!db.commit()) {
            qWarning() << "Failed to commit transaction:" << db.lastError().text();
            return false;
        }
    }

    return true;
}

bool DatabaseManager::updateDayName(int dayId, const QString &dayName ) {

    if (!openDatabase()) return false;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare("UPDATE Days SET dayName = ? WHERE id = ?;");
        query.addBindValue(dayName);
        query.addBindValue(dayId);

        if (!query.exec()) {
            qWarning() << "Error in updateDayName:" << query.lastError().text();
            return false;
        }
    }
    return true;
}
bool DatabaseManager::deleteFolder(int folderId) {
    if (!openDatabase()) return false;

    QMutexLocker locker(&mutex);
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);

    try {
        // Начинаем транзакцию
        if (!db.transaction()) {
            qWarning() << "Failed to start transaction:" << db.lastError().text();
            return false;
        }

        // 1. Получаем список day_ids из папки
        QString dayIds;
        {
            QSqlQuery query(db);
            query.prepare("SELECT day_ids FROM Folders WHERE id = ?");
            query.addBindValue(folderId);

            if (!query.exec() || !query.next()) {
                qWarning() << "Error getting folder days:" << query.lastError().text();
                db.rollback();
                return false;
            }

            dayIds = query.value(0).toString();
        }

        // 2. Обновляем связанные дни
        if (!dayIds.isEmpty()) {
            QSqlQuery query(db);
            QStringList ids = dayIds.split(',', Qt::SkipEmptyParts);

            // Формируем плейсхолдеры для IN-условия
            QStringList placeholders;
            for (int i = 0; i < ids.size(); ++i) {
                placeholders << "?";
            }

            query.prepare(QString("UPDATE Days SET folder_id = NULL WHERE id IN (%1)")
                              .arg(placeholders.join(',')));

            for (const QString& id : ids) {
                bool ok;
                int dayId = id.toInt(&ok);
                if (ok) {
                    query.addBindValue(dayId);
                }
            }

            if (!query.exec()) {
                qWarning() << "Error updating days:" << query.lastError().text();
                db.rollback();
                return false;
            }
        }

        // 3. Удаляем саму папку
        {
            QSqlQuery query(db);
            query.prepare("DELETE FROM Folders WHERE id = ?");
            query.addBindValue(folderId);

            if (!query.exec()) {
                qWarning() << "Error deleting folder:" << query.lastError().text();
                db.rollback();
                return false;
            }
        }

        // Фиксируем транзакцию
        if (!db.commit()) {
            qWarning() << "Failed to commit transaction:" << db.lastError().text();
            return false;
        }
        emit foldersChanged();
        emit daysChanged();
        return true;
    }
    catch (...) {
        db.rollback();
        throw;
    }
}
QVariantList DatabaseManager::getTerminsByFolderId(int fodlerId) {
    QVariantList termins;

    if (!openDatabase()) {
        return termins;
    }

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(db);
        query.prepare(
            "SELECT Termins.id, Termins.def, Termins.translate, Termins.memoryLevel, Termins.image "
            "FROM Termins "
            "INNER JOIN Days ON Termins.day_Id = Days.id "
            "WHERE Days.fodler_id = ?"
            );
        query.addBindValue(fodlerId);

        if (query.exec()) {
            while (query.next()) {
                QVariantMap terminMap;
                terminMap["id"] = query.value(0).toInt();
                terminMap["def"] = query.value(1).toString();
                terminMap["translate"] = query.value(2).toString();
                terminMap["memoryLevel"] = query.value(3).toInt();
                terminMap["image"] = query.value(4).toString();
                termins.append(terminMap);
            }
        } else {
            qWarning() << "Error in getTerminsByFolderId:" << query.lastError().text();
        }
    }
    return termins;
}
bool DatabaseManager::deleteDay(int dayId) {
    if (!openDatabase()) return false;

    {
        QMutexLocker locker(&mutex);
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);

        // 1. Удаление терминов
        QSqlQuery deleteTermsQuery(db);
        deleteTermsQuery.prepare("DELETE FROM Termins WHERE Day_id = ?");
        deleteTermsQuery.addBindValue(dayId);

        if (!deleteTermsQuery.exec()) {
            qWarning() << "Error deleting terms:" << deleteTermsQuery.lastError().text();
            return false;
        }

        // 2. Удаление дня
        QSqlQuery deleteDayQuery(db);
        deleteDayQuery.prepare("DELETE FROM Days WHERE id = ?");
        deleteDayQuery.addBindValue(dayId);

        if (!deleteDayQuery.exec()) {
            qWarning() << "Error deleting day:" << deleteDayQuery.lastError().text();
            return false;
        }

        // 3. Обновление папок
        QSqlQuery selectFoldersQuery(db);
        if (!selectFoldersQuery.exec("SELECT id, day_ids FROM Folders")) {
            qWarning() << "Error fetching folders:" << selectFoldersQuery.lastError().text();
            return false;
        }

        const QString targetDayId = QString::number(dayId);
        QVector<QPair<int, QString>> foldersToUpdate;

        while (selectFoldersQuery.next()) {
            int folderId = selectFoldersQuery.value(0).toInt();
            QString dayIds = selectFoldersQuery.value(1).toString();
            QStringList ids = dayIds.split(',', Qt::SkipEmptyParts);

            if (ids.removeAll(targetDayId) > 0) {
                foldersToUpdate.append(qMakePair(folderId, ids.join(',')));
            }
        }

        for (const auto& folder : foldersToUpdate) {
            QSqlQuery updateFolderQuery(db);
            updateFolderQuery.prepare("UPDATE Folders SET day_ids = ? WHERE id = ?");
            updateFolderQuery.addBindValue(folder.second.isEmpty() ? QVariant() : folder.second);
            updateFolderQuery.addBindValue(folder.first);

            if (!updateFolderQuery.exec()) {
                qWarning() << "Error updating folder:" << updateFolderQuery.lastError().text();
                return false;
            }
        }
    }
    emit daysChanged();
    emit foldersChanged();
    return true;
}
