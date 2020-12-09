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

#include "mauikit_export.h"

/**
 * @brief The TAGDB class
 */
class MAUIKIT_EXPORT TAGDB : public QObject
{
    Q_OBJECT
private:
    QString name;
    QSqlDatabase m_db;

public:
    /* utils*/
    /**
     * @brief checkExistance
     * @param tableName
     * @param searchId
     * @param search
     * @return
     */
    bool checkExistance(const QString &tableName, const QString &searchId, const QString &search);

    /**
     * @brief checkExistance
     * @param queryStr
     * @return
     */
    bool checkExistance(const QString &queryStr);

protected:
    TAGDB();
    ~TAGDB();

    /**
     * @brief getQuery
     * @param queryTxt
     * @return
     */
    QSqlQuery getQuery(const QString &queryTxt);

    /**
     * @brief openDB
     * @param name
     */
    void openDB(const QString &name);

    /**
     * @brief prepareCollectionDB
     */
    void prepareCollectionDB() const;

    /**
     * @brief insert
     * @param tableName
     * @param insertData
     * @return
     */
    bool insert(const QString &tableName, const QVariantMap &insertData);

    /**
     * @brief update
     * @param tableName
     * @param updateData
     * @param where
     * @return
     */
    bool update(const QString &tableName, const FMH::MODEL &updateData, const QVariantMap &where);

    /**
     * @brief update
     * @param table
     * @param column
     * @param newValue
     * @param op
     * @param id
     * @return
     */
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);

    /**
     * @brief remove
     * @param tableName
     * @param removeData
     * @return
     */
    bool remove(const QString &tableName, const FMH::MODEL &removeData);
};

#endif // DB_H
