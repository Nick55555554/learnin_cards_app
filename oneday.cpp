#include "OneDay.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

OneDay::OneDay(QObject *parent) : Folder(parent) {
}

OneDay::OneDay(int id, QSqlDatabase db, QObject *parent)
    : Folder(parent), m_id(id), m_database(db) {
    loadData();
}

bool OneDay::loadData() {
    QSqlQuery query(m_database);
    query.prepare("SELECT DayName, User_id FROM Days WHERE ID = ?");
    query.addBindValue(m_id);

    if (!query.exec()) {
        qDebug() << "Query error:" << query.lastError().text();
        return false;
    }

    if (query.next()) {
        setName(query.value(0).toString());
        setUserId(query.value(1).toInt());
        return true;
    }
    return false;
}

void OneDay::setId(int id) {
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void OneDay::setName(const QString &dayName) {
    if (m_dayName != dayName) {
        m_dayName = dayName;
        emit dayNameChanged();
    }
}

void OneDay::setUserId(int userId) {
    if (m_userId != userId) {
        m_userId = userId;
        emit userIdChanged();
    }
}

void OneDay::setFolderId(int folderId) {
    if (m_folderId != folderId) {
        m_folderId = folderId;
        emit folderIdChanged(); // Не забудьте добавить сигнал, если он нужен
    }
}


void OneDay::setTerminCount(int count) {
    if (m_terminCount != count) {
        m_terminCount = count;
        emit terminCountChanged();
    }
}
