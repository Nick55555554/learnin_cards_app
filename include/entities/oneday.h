#ifndef ONEDAY_H
#define ONEDAY_H

#include "entities/folder.h" // Предполагается, что OneDay наследует от Folder
#include <QObject>
#include <QSqlDatabase>

class OneDay : public Folder {
    Q_OBJECT

public:
    explicit OneDay(QObject *parent = nullptr);
    OneDay(int id, QSqlDatabase db, QObject *parent = nullptr);

    bool loadData();

    // Геттеры и сеттеры
    int id() const { return m_id; }
    void setId(int id);

    QString name() const { return m_dayName; }
    void setName(const QString &dayName);

    int userId() const { return m_userId; }
    void setUserId(int userId);

    int folderId() const { return m_folderId; }
    void setFolderId(int folderId);

    void setTerminCount(int count);

signals:
    void idChanged();
    void dayNameChanged();
    void userIdChanged();
    void terminCountChanged();
    void folderIdChanged();

private:
    int m_id; // ID дня
    QString m_dayName; // Имя дня
    int m_userId; // ID пользователя
    int m_terminCount; // Количество терминов
    int m_folderId = -1; // ID папки, инициализация по умолчанию
    QSqlDatabase m_database; // База данных
};

#endif // ONEDAY_H
