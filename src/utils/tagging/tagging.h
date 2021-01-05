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

#include "mauikit_export.h"

#define MAX_LIMIT 9999

/**
 * @brief The Tagging class
 * Provides quick methods to access and modify the tags associated to files.
 * This class follows a singleton pattern and it is not thread safe, so only the main thread can have access to it.
 */
class MAUIKIT_EXPORT Tagging : public TAGDB
{
    Q_OBJECT
public:

    /**
     * @brief getInstance
     * Returns an instance to the tagging object. This instance can only be accessed from the main thread, otherwise it will return a nullptr and segfault
     * @return
     */
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
     * Retrieve the information into a model, optionally you can pass a modifier callback function to manipulate or discard items in the model
     * @param query
     * Query to be retrieved
     * @param modifier
     * A callback function that sends as an argument a reference to the current item being retrieved, which can be modified, and expects a boolean value to be returned to decide if such item should de added to the model or not
     * @return
     * The model
     */
    Q_INVOKABLE const QVariantList get(const QString &query, std::function<bool(QVariantMap &item)> modifier = nullptr);

    /**
     * @brief tagExists
     * Checks if a given tag exists, it can be strictly enforced, meaning it is checked if the tag was created by the application making the request
     * @param tag
     * The tag to search
     * @param strict
     * If the search should be strictly enforced. If strict is true then the tag should have been created by the app making the request, otherwise checks if the tag exists and could have been created by any other application.
     * @return
     */
    Q_INVOKABLE bool tagExists(const QString &tag, const bool &strict = false);

    /**
     * @brief urlTagExists
     * Checks if a given tag is associated to a give file URL. The check can be strictly enforced, meaning the given URL was tagged by the application making the request
     * @param url
     * The file URL
     * @param tag
     * The tag to perfrom the check
     * @param strict
     * Strictly enforced check
     * @return
     */
    Q_INVOKABLE bool urlTagExists(const QString &url, const QString &tag, const bool &strict = false);

    /* INSERTIIONS */
    /**
     * @brief tag
     * Adds a new tag, the newly created tag gets associated to the app making the call. If the tag already exists nothing is changed //TODO if the tag exists the app making the request should get associated to the tag too
     * @param tag
     * The name of the tag
     * @param color
     * Optional color for the tag
     * @param comment
     * Optional comment for the tag \deprecated
     * @return
     * Returns if the operation was sucessfull, meaning the tag was created
     */
    Q_INVOKABLE bool tag(const QString &tag, const QString &color = QString(), const QString &comment = QString());

    /**
     * @brief tagUrl
     * Adds a tag to a given file URL, if the given tag doesnt exists then it gets created
     * @param url
     * File URL to be tagged
     * @param tag
     * Tag to be added to the file URL
     * @param color \deprecated
     * Optional color
     * @param comment
     * Optional comment
     * @return
     */
    Q_INVOKABLE bool tagUrl(const QString &url, const QString &tag, const QString &color = QString(), const QString &comment = QString());

    /* UPDATES */
    /**
     * @brief updateUrlTags
     * Updates the tags associated to a file URL. If any of the given tags doesnt exists then they get created, if a tag associated to the current file URL is missing in the new passed tags then those get removed
     * @param url
     * File URL
     * @param tags
     * New set of tags to be associated to the file URL
     * @return
     */
    Q_INVOKABLE bool updateUrlTags(const QString &url, const QStringList &tags);

    /**
     * @brief updateUrl
     * Updates a file URL to a new URL, preserving all associated tags. This is useful if a file is rename or moved to a new location
     * @param url
     * Previous file URL
     * @param newUrl
     * New file URL
     * @return
     */
    Q_INVOKABLE bool updateUrl(const QString &url, const QString &newUrl);

    /* QUERIES */

    /**
     * @brief getUrlsTags \deprecated
     * Give a list of all tags associated to files
     * @param strict
     * @return
     */
    Q_INVOKABLE QVariantList getUrlsTags(const bool &strict = true);

    /**
     * @brief getAllTags
     * Retruns a list model of all the tags. The model can be strictly enforced to only tags that were created by the application making the call
     * @param strict
     * If true returns only tags created by the application making the request
     * @return
     * Model with the info of all the requested tags
     */
    Q_INVOKABLE QVariantList getAllTags(const bool &strict = true);

    /**
     * @brief getUrls
     * Returns a model of all the file URLs associated to a tag, the result can be strictly enforced to only file URLs associated to a tag created by the application making the request, restrinct it to a maximum limit, filter by the mimetype or just add a modifier function
     * @param tag
     * Tag name to perfrom the search
     * @param strict
     * Strictly enforced to only file URLs associated to the given tag created by the application making the request
     * @param limit
     * Maximum limit of results
     * @param mimeType
     * Filter by mimetype, for example: "image/\*" or "image/png"
     * @param modifier
     * A callback function that sends as an argument a reference to the current item being retrieved, which can be modified, and expects a boolean value to be returned to decide if such item should be added to the model or not
     * @return
     */
    Q_INVOKABLE QVariantList getUrls(const QString &tag, const bool &strict = true, const int &limit = MAX_LIMIT, const QString &mimeType = "", std::function<bool(QVariantMap &item)> modifier = nullptr);

    /**
     * @brief getUrlTags
     * Returns a model list of all the tags associated to a file URL. The result can be strictly enforced to only tags created by the application making the call
     * @param url
     * File URL
     * @param strict
     * Strictly enforced to only tags created by the application making the request
     * @return
     */
    Q_INVOKABLE QVariantList getUrlTags(const QString &url, const bool &strict = true);

    /* DELETES */
    /**
     * @brief removeUrlTags
     * Given a file URL remove all the tags associated to it
     * @param url
     * File URL
     * @return
     * If the operation was sucessfull
     */
    Q_INVOKABLE bool removeUrlTags(const QString &url);

    /**
     * @brief removeUrlTag
     * Removes a given tag associated to a given file URL
     * @param url
     * File URL
     * @param tag
     * Tag associated to file URL to be removed
     * @return
     * If the operation was sucessfull
     */
    Q_INVOKABLE bool removeUrlTag(const QString &url, const QString &tag);

    /**
     * @brief removeUrl /todo
     * Removes a URL with its associated tags
     * @param url
     * File URL
     * @return
     * If the operation was sucessfull
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
    static bool setTagIconName(QVariantMap &item);
    
signals:
    void urlTagged(const QString &url, const QString &tag);
    void tagged(const QVariantMap &tag);
};

#endif // TAGGING_H
