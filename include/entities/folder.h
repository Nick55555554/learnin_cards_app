#ifndef FOLDER_H
#define FOLDER_H

#include <QObject>
#include <QList>

class OneDay;

class Folder : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString folderName READ folderName WRITE setFolderName NOTIFY folderNameChanged)
    Q_PROPERTY(int userId READ userId WRITE setUserId NOTIFY userIdChanged)
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QList<OneDay*> days READ days NOTIFY daysChanged)
    Q_PROPERTY(QList<int> dayIds READ getDayIds NOTIFY dayIdsChanged) // Новый свойство для хранения ID дней

public:
    explicit Folder(QObject *parent = nullptr);

    QList<int> getDayIds() const { return m_day_ids; }
    QString folderName() const { return m_folderName; }
    int userId() const { return m_userId; }
    int id() const { return m_Id; }
    QList<OneDay*> days() const { return m_days; }

    // Сеттеры
    void setFolderName(const QString &name);
    void setUserId(int id);
    void setId(int id);

    // Работа с днями
    Q_INVOKABLE void addDay(OneDay *day);
    Q_INVOKABLE void removeDay(OneDay *day);

signals:
    void folderNameChanged();
    void userIdChanged();
    void idChanged();
    void daysChanged();
    void dayIdsChanged(); // Новый сигнал для изменения ID дней

private:
    QString m_folderName;
    int m_userId = -1;
    int m_Id = -1; // Инициализация по умолчанию
    QList<OneDay*> m_days;
    QList<int> m_day_ids;
};

#endif
