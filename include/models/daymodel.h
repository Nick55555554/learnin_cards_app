#ifndef DAYMODEL_H
#define DAYMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "entities/myday.h"
#include "managers/databaseManager.h"

class DayModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool ready READ isReady NOTIFY readyChanged)

public:
    explicit DayModel(DatabaseManager* dbManager, QObject *parent = nullptr);
    ~DayModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool isReady() const;
    Q_INVOKABLE void loadData(int userId);
    Q_INVOKABLE void loadDataByFolderId(int folderId);
    Q_INVOKABLE void clear() {
        beginResetModel();
        qDeleteAll(m_days);
        m_days.clear();
        endResetModel();
    }

signals:
    void dataLoaded(const QList<MyDay*>& days);
    void readyChanged();

private:
    DatabaseManager* m_dbManager;
    bool m_ready = false;
    QList<MyDay*> m_days;
};

#endif
