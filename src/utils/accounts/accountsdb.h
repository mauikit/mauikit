#ifndef ACCOUNTSDB_H
#define ACCOUNTSDB_H

#include <QObject>

#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QList>
#include <QObject>
#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QString>
#include <QStringList>
#include <QVariantMap>

#include "fmh.h"

class AccountsDB : public QObject
{
    Q_OBJECT

private:
    QString name;
    QSqlDatabase m_db;

public:
    /* utils*/
    explicit AccountsDB(QObject *parent = nullptr);
    ~AccountsDB();
    bool checkExistance(const QString &tableName, const QString &searchId, const QString &search);
    bool checkExistance(const QString &queryStr);
    QSqlQuery getQuery(const QString &queryTxt);
    void openDB(const QString &name);
    void prepareCollectionDB() const;

    bool insert(const QString &tableName, const QVariantMap &insertData);
    bool update(const QString &tableName, const FMH::MODEL &updateData, const QVariantMap &where);
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
    bool remove(const QString &tableName, const FMH::MODEL &removeData);

signals:

public slots:
};
#endif // ACCOUNTSDB_H
