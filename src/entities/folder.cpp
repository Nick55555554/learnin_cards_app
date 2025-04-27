#include "entities/folder.h"
#include "entities/oneDay.h"

Folder::Folder(QObject *parent) : QObject(parent) {}

void Folder::setFolderName(const QString &name) {
    if (m_folderName != name) {
        m_folderName = name;
        emit folderNameChanged();
    }
}

void Folder::setUserId(int id) {
    if (m_userId != id) {
        m_userId = id;
        emit userIdChanged();
    }
}


void Folder::setId(int id) {
    if (m_Id == id) return;
    m_Id = id;
    emit idChanged();
}

void Folder::addDay(OneDay *day) {
    if (day && !m_days.contains(day)) {
        m_days.append(day);
        m_day_ids.append(day->id());
        day->setFolderId(this->id()); // Устанавливаем связь
        emit daysChanged();
        emit dayIdsChanged();
    }
}

void Folder::removeDay(OneDay *day) {
    if (m_days.removeOne(day)) {
        m_day_ids.removeAll(day->id());
        day->setFolderId(-1); // Сбрасываем связь
        emit daysChanged();
        emit dayIdsChanged();
    }
}
