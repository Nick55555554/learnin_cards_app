// ImageSaver.h
#include <QObject>
#include <QString>
#include <QUrl>

class ImageSaver : public QObject {
    Q_OBJECT
public:
    explicit ImageSaver(QObject* parent = nullptr);

    Q_INVOKABLE QString saveImage(const QString& sourcePath);
};
