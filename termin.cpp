#include "termin.h"
#include "databasemanager.h"

Termin::Termin(DatabaseManager* dbManager, QObject *parent)
    : OneDay(parent), m_dbManager(dbManager)
{
    Q_ASSERT(dbManager != nullptr);
}

QString Termin::def() const { return m_def; }
QString Termin::translate() const { return m_translate; }
QString Termin::image() const { return m_image; }
int Termin::memoryLevel() const { return m_memoryLevel; }

void Termin::setDef(const QString &def) {
    if (m_def != def) {
        m_def = def;
        emit defChanged();
    }
}

void Termin::setTranslate(const QString &translate) {
    if (m_translate != translate) {
        m_translate = translate;
        emit translateChanged();
    }
}

void Termin::setImage(const QString &image) {
    if (m_image != image) {
        m_image = image;
        emit imageChanged();
    }
}

void Termin::setMemoryLevel(int memoryLevel) {
    memoryLevel = qBound(0, memoryLevel, 100);
    if (m_memoryLevel != memoryLevel) {
        m_memoryLevel = memoryLevel;
        emit memoryLevelChanged();
        m_dbManager->updateTerminMemoryLevel(id(), m_memoryLevel);
    }
}
