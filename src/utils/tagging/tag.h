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
