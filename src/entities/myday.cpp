#include "entities/myday.h"

MyDay::MyDay(QObject *parent) : QObject(parent), m_id(0) {}

int MyDay::id() const {
    return m_id;
}

void MyDay::setId(int id) {
    m_id = id;
}

QString MyDay::name() const {
    return m_name;
}

void MyDay::setName(const QString &name) {
    m_name = name;
}

int MyDay::folderId() const {
    return m_folderId;
}

void MyDay::setFolderId(int folderId) {
    m_folderId = folderId;
}
