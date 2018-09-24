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

#ifndef TAG_H
#define TAG_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QVariantList>

namespace TAG
{
    enum class TABLE : uint8_t
    {
        USERS,
        TAGS_USERS,
        APPS_USERS,
        TAGS,
        TAGS_URLS,
        APPS,
        ABSTRACT,
        TAGS_ABSTRACT,
        NONE
    };

    static const QMap<TABLE,QString> TABLEMAP =
    {
        {TABLE::TAGS, "tags"},
        {TABLE::TAGS_URLS,"tags_urls"},
        {TABLE::USERS, "users"},
        {TABLE::TAGS_USERS,"tags_users"},
        {TABLE::APPS, "apps"},
        {TABLE::ABSTRACT,"abstract"},
        {TABLE::TAGS_ABSTRACT, "tags_abstract"},
        {TABLE::APPS_USERS,"apps_users"}
    };

    enum class KEY :uint8_t
    {
        URL,
        APP,
        URI,
        MAC,
        LAST_SYNC,
        NAME,
        VERSION,
        LOT,
        TAG,
        COLOR,
        ADD_DATE,
        COMMENT,
        MIME,
        TITLE,
        DEVICE,
        KEY,
        NONE
    };

    typedef QMap<TAG::KEY, QString> DB;

    static const DB KEYMAP =
    {
        {KEY::URL, "url"},
        {KEY::TAG, "tag"},
        {KEY::COLOR, "color"},
        {KEY::ADD_DATE, "addDate"},
        {KEY::COMMENT, "comment"},
        {KEY::MIME, "mime"},
        {KEY::TITLE, "title"},
        {KEY::NAME, "name"},
        {KEY::DEVICE, "device"},
        {KEY::MAC, "mac"},
        {KEY::LAST_SYNC, "lastSync"},
        {KEY::LOT, "lot"},
        {KEY::KEY, "key"},
        {KEY::NAME, "name"},
        {KEY::APP, "app"},
        {KEY::URI, "uri"},
        {KEY::VERSION, "version"}
    };

    const QString TaggingPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/maui/tagging/";
    const QString DBName = "tagging.db";


}

#endif // TAG_H
