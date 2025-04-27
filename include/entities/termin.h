#ifndef TERMIN_H
#define TERMIN_H

#include "entities/oneday.h"

class DatabaseManager;

class Termin : public OneDay
{
    Q_OBJECT
    Q_PROPERTY(QString def READ def WRITE setDef NOTIFY defChanged)
    Q_PROPERTY(QString translate READ translate WRITE setTranslate NOTIFY translateChanged)
    Q_PROPERTY(QString image READ image WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(int memoryLevel READ memoryLevel WRITE setMemoryLevel NOTIFY memoryLevelChanged)

public:
    explicit Termin(DatabaseManager* dbManager, QObject *parent = nullptr);

    QString def() const;
    void setDef(const QString &def);

    QString translate() const;
    void setTranslate(const QString &translate);

    QString image() const;
    void setImage(const QString &image);

    int memoryLevel() const;
    void setMemoryLevel(int memoryLevel);
    Q_PROPERTY(int dayId READ dayId WRITE setDayId NOTIFY idChanged)

    int dayId() const { return id(); }
    void setDayId(int id) { setId(id); }

signals:
    void defChanged();
    void translateChanged();
    void imageChanged();
    void memoryLevelChanged();

private:
    DatabaseManager* m_dbManager;
    QString m_def;
    QString m_translate;
    QString m_image;
    int m_memoryLevel = 50;
};

#endif // TERMIN_H
