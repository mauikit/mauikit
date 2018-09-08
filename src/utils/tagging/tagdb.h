#ifndef TAGDB_H
#define TAGDB_H

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

#include "tag.h"
#include "utils.h"


class TAGDB : public QObject
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
    TAGDB(QObject *parent = nullptr);
    ~ TAGDB();

    QSqlQuery getQuery(const QString &queryTxt);
    void openDB(const QString &name);
    void prepareCollectionDB() const;

    bool insert(const QString &tableName, const QVariantMap &insertData);
    bool update(const QString &tableName, const TAG::DB &updateData, const QVariantMap &where);
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
    bool remove(const QString &tableName, const TAG::DB &removeData);

signals:

public slots:
};


#endif // DB_H
