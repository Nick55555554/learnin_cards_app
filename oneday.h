#ifndef ONEDAY_H
#define ONEDAY_H

#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlDatabase>
#include <QVariant>

class OneDay
{
public:
    OneDay(int id, QSqlDatabase db);
    bool loadData();

    QString getDayName() const { return dayName; }
    int getUserId() const { return userId; }

private:
    int id; // ID записи
    QString dayName; // Название дня
    int userId; // ID пользователя
    QSqlDatabase database; // База данных
};

#endif // ONEDAY_H
