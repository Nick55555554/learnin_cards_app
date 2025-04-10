#include "DayModel.h"

DayModel::DayModel(DatabaseManager* dbManager, QObject *parent)
    : QAbstractListModel(parent), m_dbManager(dbManager)
{
    Q_ASSERT(m_dbManager != nullptr);
}

DayModel::~DayModel()
{
    qDeleteAll(m_days);
}

void DayModel::loadData(int userId)
{
    beginResetModel();
    qDeleteAll(m_days);
    m_days.clear();

    m_days = m_dbManager->getLastDaysById(userId);
    emit dataLoaded(m_days);

    endResetModel();
    m_ready = true;
    emit readyChanged();
}
void DayModel::loadDataByFolderId(int folderId)
{
    beginResetModel();
    qDeleteAll(m_days);
    m_days.clear();

    m_days = m_dbManager->getDaysByFolderId(folderId);
    emit dataLoaded(m_days);

    endResetModel();
    m_ready = true;
    emit readyChanged();
}

int DayModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_days.size();
}
QVariant DayModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_days.count())
        return QVariant();

    const MyDay* day = m_days.at(index.row());

    switch(role) {
    case Qt::UserRole: return day->id();
    case Qt::UserRole + 1: return day->name();
    case Qt::UserRole + 2: return day->folderId();
    default: return QVariant();
    }
}


QHash<int, QByteArray> DayModel::roleNames() const
{
    static QHash<int, QByteArray> roles {
        {Qt::UserRole, "dayId"},
        {Qt::UserRole + 1, "dayName"},
        {Qt::UserRole + 2, "folderId"},
    };
    return roles;
}


bool DayModel::isReady() const
{
    return m_ready;
}
