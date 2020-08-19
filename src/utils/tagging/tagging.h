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

#ifndef TAGGING_H
#define TAGGING_H

#include "tagdb.h"
#include <QObject>
#include <QtGlobal>

#include <QCoreApplication>
#include <QThread>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#define MAX_LIMIT 9999

#ifdef STATIC_MAUIKIT
class Tagging : public TAGDB
#else
class MAUIKIT_EXPORT Tagging : public TAGDB
#endif
{
    Q_OBJECT
public:
    static Tagging *getInstance()
    {
        qWarning() << "GETTIG TAGGING INSTANCE" << QThread::currentThread() << qApp->thread();

        if (QThread::currentThread() != qApp->thread()) {
            qWarning() << "Can not get Tagging instance from a thread different than the mian one  " << QThread::currentThread() << qApp->thread();
            return nullptr;
        }
        static Tagging tag;
        return &tag;
    }

    /**
     * @brief get
     * @param query
     * @param modifier
     * @return
     */
    Q_INVOKABLE const QVariantList get(const QString &query, std::function<bool(QVariantMap &item)> modifier = nullptr);

    /**
     * @brief tagExists
     * @param tag
     * @param strict
     * @return
     */
    Q_INVOKABLE bool tagExists(const QString &tag, const bool &strict = false);

    /**
     * @brief urlTagExists
     * @param url
     * @param tag
     * @param strict
     * @return
     */
    Q_INVOKABLE bool urlTagExists(const QString &url, const QString &tag, const bool &strict = false);

    /* INSERTIIONS */
    /**
     * @brief tag
     * @param tag
     * @param color
     * @param comment
     * @return
     */
    Q_INVOKABLE bool tag(const QString &tag, const QString &color = QString(), const QString &comment = QString());

    /**
     * @brief tagUrl
     * @param url
     * @param tag
     * @param color
     * @param comment
     * @return
     */
    Q_INVOKABLE bool tagUrl(const QString &url, const QString &tag, const QString &color = QString(), const QString &comment = QString());

    /**
     * @brief tagAbstract
     * @param tag
     * @param key
     * @param lot
     * @param color
     * @param comment
     * @return
     */
    Q_INVOKABLE bool tagAbstract(const QString &tag, const QString &key, const QString &lot, const QString &color = QString(), const QString &comment = QString());

    /* UPDATES */
    /**
     * @brief updateUrlTags
     * @param url
     * @param tags
     * @return
     */
    Q_INVOKABLE bool updateUrlTags(const QString &url, const QStringList &tags);

    /**
     * @brief updateUrl
     * @param url
     * @param newUrl
     * @return
     */
    Q_INVOKABLE bool updateUrl(const QString &url, const QString &newUrl);

    /**
     * @brief updateAbstractTags
     * @param key
     * @param lot
     * @param tags
     * @return
     */
    Q_INVOKABLE bool updateAbstractTags(const QString &key, const QString &lot, const QStringList &tags);

    /* QUERIES */

    /**
     * @brief getUrlsTags
     * @param strict
     * @return
     */
    Q_INVOKABLE QVariantList getUrlsTags(const bool &strict = true);

    /**
     * @brief getAbstractsTags
     * @param strict
     * @return
     */
    Q_INVOKABLE QVariantList getAbstractsTags(const bool &strict = true);

    /**
     * @brief getAllTags
     * @param strict
     * @return
     */
    Q_INVOKABLE QVariantList getAllTags(const bool &strict = true);

    /**
     * @brief getUrls
     * @param tag
     * @param strict
     * @param limit
     * @param mimeType
     * @param modifier
     * @return
     */
    Q_INVOKABLE QVariantList getUrls(const QString &tag, const bool &strict = true, const int &limit = MAX_LIMIT, const QString &mimeType = "", std::function<bool(QVariantMap &item)> modifier = nullptr);

    /**
     * @brief getUrlTags
     * @param url
     * @param strict
     * @return
     */
    Q_INVOKABLE QVariantList getUrlTags(const QString &url, const bool &strict = true);

    /**
     * @brief getAbstractTags
     * @param key
     * @param lot
     * @param strict
     * @return
     */
    Q_INVOKABLE QVariantList getAbstractTags(const QString &key, const QString &lot, const bool &strict = true);

    /* DELETES */
    /**
     * @brief removeAbstractTag
     * @param key
     * @param lot
     * @param tag
     * @return
     */
    Q_INVOKABLE bool removeAbstractTag(const QString &key, const QString &lot, const QString &tag);

    /**
     * @brief removeAbstractTags
     * @param key
     * @param lot
     * @return
     */
    Q_INVOKABLE bool removeAbstractTags(const QString &key, const QString &lot);

    /**
     * @brief removeUrlTags
     * @param url
     * @return
     */
    Q_INVOKABLE bool removeUrlTags(const QString &url);

    /**
     * @brief removeUrlTag
     * @param url
     * @param tag
     * @return
     */
    Q_INVOKABLE bool removeUrlTag(const QString &url, const QString &tag);

    /**
     * @brief removeUrl
     * @param url
     * @return
     */
    Q_INVOKABLE bool removeUrl(const QString &url);

    /*STATIC METHODS*/

    /**
     * @brief mac
     * @return
     */
    static QString mac();

    /**
     * @brief device
     * @return
     */
    static QString device();

    /**
     * @brief id
     * @return
     */
    static QString id();

private:
    Tagging();
    Tagging(const Tagging &) = delete;
    Tagging &operator=(const Tagging &) = delete;
    Tagging(Tagging &&) = delete;
    Tagging &operator=(Tagging &&) = delete;

    void setApp();

    QString application = QString();
    QString version = QString();
    QString comment = QString();
    QString uri = QString();

    bool app();
    bool user();

protected:
    bool abstract(const QString &key, const QString &lot, const QString &comment);
    static bool setTagIconName(QVariantMap &item);
    
signals:
    void urlTagged(const QString &url, const QString &tag);
    void abstractTagged(const QString &key, const QString &lot, const QString &tag);
    void tagged(const QString &tag);
};

#endif // TAGGING_H
