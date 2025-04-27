// ImageSaver.cpp
#include "imagesaver.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QUuid>

ImageSaver::ImageSaver(QObject* parent) : QObject(parent) {
    QDir dir;
    if (!dir.exists("images")) {
        dir.mkdir("images");
    }
}

QString ImageSaver::saveImage(const QString& sourcePath) {
    QUrl sourceUrl(sourcePath);
    if (!sourceUrl.isLocalFile()) return "";

    QString localPath = sourceUrl.toLocalFile();
    QFileInfo fileInfo(localPath);
    if (!fileInfo.exists()) return "";

    QString uniqueName = QUuid::createUuid().toString(QUuid::WithoutBraces)
                         + "." + fileInfo.suffix();
    QString destPath = QDir("images").absoluteFilePath(uniqueName);

    return QFile::copy(localPath, destPath)
               ? QUrl::fromLocalFile(destPath).toString()
               : "";
}
