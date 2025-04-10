#include "DayManager.h"
#include <QDebug>

void DayManager::loadDay(int id) {
    if (!m_dbManager->openDatabase()) {
        emit loadError("Database connection error");
        return;
    }

    OneDay *day = m_dbManager->getDayById(id);
    if (day) {
    emit dayLoaded(day->name(), day->userId(), day->folderId());
        delete day;
    } else {
        emit loadError("Failed to load day data");
    }
}
