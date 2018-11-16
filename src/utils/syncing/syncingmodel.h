#ifndef SYNCINGMODEL_H
#define SYNCINGMODEL_H

#include <QAbstractListModel>
#include <QList>

class SyncingList;
class SyncingModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(SyncingList *list READ getList WRITE setList)

public:
    explicit SyncingModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    SyncingList* getList() const;
    void setList(SyncingList *value);

private:
    SyncingList *mList;
signals:
    void listChanged();
};

#endif // SYNCINGMODEL_H
