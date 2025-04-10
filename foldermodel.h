class FolderModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum FolderRoles {
        IdRole = Qt::UserRole + 1,
        NameRole
    };

    FolderModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}

    // Реализация необходимых методов для модели
    // ...

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[IdRole] = "id";
        roles[NameRole] = "name";
        return roles;
    }

    // Метод для загрузки папок из базы данных
    void loadFolders(int userId) {
        // Получите папки из базы данных и обновите модель
        beginResetModel();
        // Заполните данные
        endResetModel();
        emit dataChanged(index(0), index(rowCount() - 1));
    }
};
