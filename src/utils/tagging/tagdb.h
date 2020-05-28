/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef TAGDB_H
#define TAGDB_H

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

#include "tag.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#ifdef STATIC_MAUIKIT
class TAGDB : public QObject
#else
class MAUIKIT_EXPORT TAGDB : public QObject
#endif
{
    Q_OBJECT
private:
    QString name;
    QSqlDatabase m_db;

public:
    /* utils*/
    bool checkExistance(const QString &tableName, const QString &searchId, const QString &search);
    bool checkExistance(const QString &queryStr);

protected:
    TAGDB();
    ~TAGDB();

    QSqlQuery getQuery(const QString &queryTxt);
    void openDB(const QString &name);
    void prepareCollectionDB() const;

    bool insert(const QString &tableName, const QVariantMap &insertData);
    bool update(const QString &tableName, const TAG::DB &updateData, const QVariantMap &where);
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
    bool remove(const QString &tableName, const TAG::DB &removeData);
};

#endif // DB_H
