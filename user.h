#ifndef USER_H
#define USER_H

#include <QObject>
#include <QString>

class User : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ id WRITE setId NOTIFY userChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY userChanged)
    Q_PROPERTY(QString login READ login WRITE setLogin NOTIFY userChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY userChanged)

public:
    explicit User(QObject *parent = nullptr);

    // Геттеры
    int id() const { return m_id; }
    QString name() const { return m_name; }
    QString login() const { return m_login; }
    QString password() const { return m_password; }

    // Сеттеры
    void setId(int id) {
        if(m_id != id) {
            m_id = id;
            emit userChanged();
        }
    }

    void setName(const QString &name) {
        if(m_name != name) {
            m_name = name;
            emit userChanged();
        }
    }

    void setLogin(const QString &login) {
        if(m_login != login) {
            m_login = login;
            emit userChanged();
        }
    }

    void setPassword(const QString &password) {
        if(m_password != password) {
            m_password = password;
            emit userChanged();
        }
    }
    Q_INVOKABLE void clearUserData() {
        setId(-1);
        setName("");
        setLogin("");
        setPassword("");
    }

signals:
    void userChanged();

private:
    int m_id = -1;
    QString m_name;
    QString m_login;
    QString m_password;
};

#endif // USER_H
