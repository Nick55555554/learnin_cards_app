#ifndef DAYMODEL_H
#define DAYMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "MyDay.h"

class DayModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit DayModel(int userId, QObject *parent = nullptr);

    // Объявление необходимых методов
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<MyDay*> m_days; // Список дней
};

#endif // DAYMODEL_H
