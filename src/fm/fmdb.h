#ifndef FMDB_H
#define FMDB_H

#include <QObject>

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlDriver>
#include <QFileInfo>
#include <QDir>
#include <QVariantMap>

#include "fmh.h"

class FMDB : public QObject
{
    Q_OBJECT

private:
    QString name;
    QSqlDatabase m_db;

public:
    /* utils*/
    Q_INVOKABLE bool checkExistance(const QString &tableName, const QString &searchId, const QString &search);
    Q_INVOKABLE bool checkExistance(const QString &queryStr);

protected:
    FMDB(QObject *parent = nullptr);
    ~ FMDB();

    QSqlQuery getQuery(const QString &queryTxt);
    void openDB(const QString &name);
    void prepareCollectionDB() const;

    bool insert(const QString &tableName, const QVariantMap &insertData);
    bool update(const QString &tableName, const FMH::DB &updateData, const QVariantMap &where);
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
    bool remove(const QString &tableName, const FMH::DB &removeData);

signals:

public slots:
};

#endif // FMDB_H
