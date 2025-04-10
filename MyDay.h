#ifndef MYDAY_H
#define MYDAY_H

#include <QObject>

class MyDay : public QObject {
    Q_OBJECT

public:
    explicit MyDay(QObject *parent = nullptr);

    int id() const;
    void setId(int id);

    QString name() const;
    void setName(const QString &name);

    int folderId() const;
    void setFolderId(int folderId);

private:
    int m_id;
    QString m_name;
    int m_folderId = -1;
};

#endif // MYDAY_H
