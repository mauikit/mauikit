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

#ifndef FMH_H
#define FMH_H

#include <QDateTime>
#include <QDebug>
#include <QDirIterator>
#include <QFileInfo>
#include <QHash>
#include <QMimeData>
#include <QMimeDatabase>
#include <QMimeType>
#include <QSettings>
#include <QStandardPaths>
#include <QString>
#include <QUrl>
#include <QVector>

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#elif defined(Q_OS_LINUX)
#include <KConfig>
#include <KConfigGroup>
#include <KFileItem>
#include <KFilePlacesModel>
#endif

/**
 * A set of helpers related to file management and modeling of data
 */
namespace FMH
{
/**
 * @brief isAndroid
 * @return
 */
static constexpr bool isAndroid()
{
#if defined(Q_OS_ANDROID)
    return true;
#else
    return false;
#endif
}

/**
 * @brief isWindows
 * @return
 */
static constexpr bool isWindows()
{
#if defined(Q_OS_WIN32)
    return true;
#elif defined(Q_OS_WIN64)
    return true;
#else
    return false;
#endif
}

/**
 * @brief isLinux
 * @return
 */
static constexpr bool isLinux()
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    return true;
#else
    return false;
#endif
}

/**
 * @brief isMac
 * @return
 */
static constexpr bool isMac()
{
#if defined(Q_OS_MACOS)
    return true;
#elif defined(Q_OS_MAC)
    return true;
#else
    return false;
#endif
}

/**
 * @brief isIOS
 * @return
 */
static constexpr bool isIOS()
{
#if defined(Q_OS_iOS)
    return true;
#else
    return false;
#endif
}

/**
 * @brief The FILTER_TYPE enum
 */
enum FILTER_TYPE : int { AUDIO, VIDEO, TEXT, IMAGE, DOCUMENT, NONE };


static const QStringList AUDIO_MIMETYPES = {"audio/mpeg", "audio/mp4", "audio/flac", "audio/ogg", "audio/wav"};
static const QStringList VIDEO_MIMETYPES = {"video/mp4", "video/x-matroska", "video/webm", "video/avi", "video/flv", "video/mpg", "video/wmv", "video/mov", "video/ogg", "video/mpeg", "video/jpeg"};
static const QStringList TEXT_MIMETYPES = {"text/markdown",
                                     "text/x-chdr",
                                     "text/x-c++src",
                                     "text/x-c++hdr",
                                     "text/css",
                                     "text/html",
                                     "text/plain",
                                     "text/richtext",
                                     "text/scriptlet",
                                     "text/x-vcard",
                                     "text/x-go",
                                     "text/x-cmake",
                                     "text/x-qml",
                                     "application/xml",
                                     "application/javascript",
                                     "application/json",
                                     "application/pgp-keys",
                                     "application/x-shellscript",
                                     "application/x-cmakecache",
                                     "application/x-kicad-project"};
static const QStringList IMAGE_MIMETYPES = {"image/bmp", "image/webp", "image/png", "image/gif", "image/jpeg", "image/web", "image/svg", "image/svg+xml"};
static const QStringList DOCUMENT_MIMETYPES = {"application/pdf", "application/rtf", "application/doc", "application/odf"};

static const QMap<FMH::FILTER_TYPE, QStringList> SUPPORTED_MIMETYPES {{FMH::FILTER_TYPE::AUDIO, AUDIO_MIMETYPES},
                                                                {FMH::FILTER_TYPE::VIDEO, VIDEO_MIMETYPES},
                                                                {FMH::FILTER_TYPE::TEXT, TEXT_MIMETYPES},
                                                                {FMH::FILTER_TYPE::IMAGE, IMAGE_MIMETYPES},
                                                                {FMH::FILTER_TYPE::DOCUMENT, DOCUMENT_MIMETYPES}};
/**
 * @brief getMimeTypeSuffixes
 * @param type
 * @return
 */
static const QStringList getMimeTypeSuffixes(const FMH::FILTER_TYPE &type, QString (*cb)(QString) = nullptr)
{
    QStringList res;
    QMimeDatabase mimedb;
    for (const auto &mime : FMH::SUPPORTED_MIMETYPES[type]) {
        if (cb)
            for (const QString &_suffix : mimedb.mimeTypeForName(mime).suffixes())
                res << cb(_suffix);
        else
            res << mimedb.mimeTypeForName(mime).suffixes();
    }
    return res;
}


static const QHash<FMH::FILTER_TYPE, QStringList> FILTER_LIST = {{FILTER_TYPE::AUDIO, FMH::getMimeTypeSuffixes(FMH::FILTER_TYPE::AUDIO, [](QString suffix) -> QString { return "*." + suffix; })},
                                                                 {FILTER_TYPE::VIDEO, FMH::getMimeTypeSuffixes(FMH::FILTER_TYPE::VIDEO, [](QString suffix) -> QString { return "*." + suffix; })},
                                                                 {FILTER_TYPE::TEXT, FMH::getMimeTypeSuffixes(FMH::FILTER_TYPE::TEXT, [](QString suffix) -> QString { return "*." + suffix; })},
                                                                 {FILTER_TYPE::DOCUMENT, FMH::getMimeTypeSuffixes(FMH::FILTER_TYPE::DOCUMENT, [](QString suffix) -> QString { return "*." + suffix; })},
                                                                 {FILTER_TYPE::IMAGE, FMH::getMimeTypeSuffixes(FMH::FILTER_TYPE::IMAGE, [](QString suffix) -> QString { return "*." + suffix; })},
                                                                 {FILTER_TYPE::NONE, QStringList()}};
/**
 * @brief The MODEL_KEY enum
 */
enum MODEL_KEY : int {
    ICON,
    LABEL,
    PATH,
    URL,
    TYPE,
    GROUP,
    OWNER,
    SUFFIX,
    NAME,
    DATE,
    SIZE,
    MODIFIED,
    MIME,
    TAG,
    PERMISSIONS,
    THUMBNAIL,
    THUMBNAIL_1,
    THUMBNAIL_2,
    THUMBNAIL_3,
    HIDDEN,
    ICONSIZE,
    DETAILVIEW,
    SHOWTHUMBNAIL,
    SHOWTERMINAL,
    COUNT,
    SORTBY,
    USER,
    PASSWORD,
    SERVER,
    FOLDERSFIRST,
    VIEWTYPE,
    ADDDATE,
    FAV,
    FAVORITE,
    COLOR,
    RATE,
    FORMAT,
    PLACE,
    LOCATION,
    ALBUM,
    ARTIST,
    TRACK,
    DURATION,
    ARTWORK,
    PLAYLIST,
    LYRICS,
    WIKI,
    MOOD,
    SOURCETYPE,
    GENRE,
    NOTE,
    COMMENT,
    CONTEXT,
    SOURCE,
    TITLE,
    ID,
    PARENT_ID,
    RELEASEDATE,
    LICENSE,
    DESCRIPTION,
    BOOKMARK,
    ACCOUNT,
    ACCOUNTTYPE,
    VERSION,
    DOMAIN_M,
    CATEGORY,
    CONTENT,
    PIN,
    IMG,
    PREVIEW,
    LINK,
    STAMP,
    BOOK,

    /** ccdav keys **/
    N,
    PHOTO,
    GENDER,
    ADR,
    ADR_2,
    ADR_3,
    EMAIL,
    EMAIL_2,
    EMAIL_3,
    LANG,
    NICKNAME,
    ORG,
    PROFILE,
    TZ,
    TEL,
    TEL_2,
    TEL_3,
    IM,

    /** other keys **/
    CITY,
    STATE,
    COUNTRY,

    /** keys from opendesktop store **/
    PACKAGE_ARCH,
    PACKAGE_TYPE,
    GPG_FINGERPRINT,
    GPG_SIGNATURE,
    PACKAGE_NAME,
    PRICE,
    REPOSITORY,
    TAGS,
    WAY,
    PIC,
    SMALL_PIC,
    CHANGED,
    COMMENTS,
    CREATED,
    DETAIL_PAGE,
    DETAILS,
    TOTAL_DOWNLOADS,
    GHNS_EXCLUDED,
    LANGUAGE,
    PERSON_ID,
    SCORE,
    SUMMARY,
    TYPE_ID,
    TYPE_NAME,
    XDG_TYPE,

    // file props
    SYMLINK,
    IS_SYMLINK,
    IS_DIR,
    IS_FILE,
    IS_REMOTE,
    EXECUTABLE,
    READABLE,
    WRITABLE,
    LAST_READ,
    VALUE,
    KEY,

    MAC,
    LOT,
    APP,
    URI,
    DEVICE,
    LASTSYNC

};

static const QHash<FMH::MODEL_KEY, QString> MODEL_NAME = {{MODEL_KEY::ICON, "icon"},
                                                          {MODEL_KEY::LABEL, "label"},
                                                          {MODEL_KEY::PATH, "path"},
                                                          {MODEL_KEY::URL, "url"},
                                                          {MODEL_KEY::TYPE, "type"},
                                                          {MODEL_KEY::GROUP, "group"},
                                                          {MODEL_KEY::OWNER, "owner"},
                                                          {MODEL_KEY::SUFFIX, "suffix"},
                                                          {MODEL_KEY::NAME, "name"},
                                                          {MODEL_KEY::DATE, "date"},
                                                          {MODEL_KEY::MODIFIED, "modified"},
                                                          {MODEL_KEY::MIME, "mime"},
                                                          {MODEL_KEY::SIZE, "size"},
                                                          {MODEL_KEY::TAG, "tag"},
                                                          {MODEL_KEY::PERMISSIONS, "permissions"},
                                                          {MODEL_KEY::THUMBNAIL, "thumbnail"},
                                                          {MODEL_KEY::THUMBNAIL_1, "thumbnail_1"},
                                                          {MODEL_KEY::THUMBNAIL_2, "thumbnail_2"},
                                                          {MODEL_KEY::THUMBNAIL_3, "thumbnail_3"},
                                                          {MODEL_KEY::ICONSIZE, "iconsize"},
                                                          {MODEL_KEY::HIDDEN, "hidden"},
                                                          {MODEL_KEY::DETAILVIEW, "detailview"},
                                                          {MODEL_KEY::SHOWTERMINAL, "showterminal"},
//                                                          {MODEL_KEY::SHOWTHUMBNAIL, "showthumbnail"},
                                                          {MODEL_KEY::COUNT, "count"},
                                                          {MODEL_KEY::SORTBY, "sortby"},
                                                          {MODEL_KEY::USER, "user"},
                                                          {MODEL_KEY::PASSWORD, "password"},
                                                          {MODEL_KEY::SERVER, "server"},
                                                          {MODEL_KEY::FOLDERSFIRST, "foldersfirst"},
                                                          {MODEL_KEY::VIEWTYPE, "viewtype"},
                                                          {MODEL_KEY::ADDDATE, "adddate"},
                                                          {MODEL_KEY::FAV, "fav"},
                                                          {MODEL_KEY::FAVORITE, "favorite"},
                                                          {MODEL_KEY::COLOR, "color"},
                                                          {MODEL_KEY::RATE, "rate"},
                                                          {MODEL_KEY::FORMAT, "format"},
                                                          {MODEL_KEY::PLACE, "place"},
                                                          {MODEL_KEY::LOCATION, "location"},
                                                          {MODEL_KEY::ALBUM, "album"},
                                                          {MODEL_KEY::DURATION, "duration"},
                                                          {MODEL_KEY::RELEASEDATE, "releasedate"},
                                                          {MODEL_KEY::ARTIST, "artist"},
                                                          {MODEL_KEY::LYRICS, "lyrics"},
                                                          {MODEL_KEY::TRACK, "track"},
                                                          {MODEL_KEY::GENRE, "genre"},
                                                          {MODEL_KEY::WIKI, "wiki"},
                                                          {MODEL_KEY::CONTEXT, "context"},
                                                          {MODEL_KEY::SOURCETYPE, "sourcetype"},
                                                          {MODEL_KEY::ARTWORK, "artwork"},
                                                          {MODEL_KEY::NOTE, "note"},
                                                          {MODEL_KEY::MOOD, "mood"},
                                                          {MODEL_KEY::COMMENT, "comment"},
                                                          {MODEL_KEY::PLAYLIST, "playlist"},
                                                          {MODEL_KEY::SOURCE, "source"},
                                                          {MODEL_KEY::TITLE, "title"},
                                                          {MODEL_KEY::ID, "id"},
                                                          {MODEL_KEY::PERSON_ID, "personid"},
                                                          {MODEL_KEY::PARENT_ID, "parentid"},
                                                          {MODEL_KEY::LICENSE, "license"},
                                                          {MODEL_KEY::DESCRIPTION, "description"},
                                                          {MODEL_KEY::BOOKMARK, "bookmark"},
                                                          {MODEL_KEY::ACCOUNT, "account"},
                                                          {MODEL_KEY::ACCOUNTTYPE, "accounttype"},
                                                          {MODEL_KEY::VERSION, "version"},
                                                          {MODEL_KEY::DOMAIN_M, "domain"},
                                                          {MODEL_KEY::CATEGORY, "category"},
                                                          {MODEL_KEY::CONTENT, "content"},
                                                          {MODEL_KEY::PIN, "pin"},
                                                          {MODEL_KEY::IMG, "img"},
                                                          {MODEL_KEY::PREVIEW, "preview"},
                                                          {MODEL_KEY::LINK, "link"},
                                                          {MODEL_KEY::STAMP, "stamp"},
                                                          {MODEL_KEY::BOOK, "book"},

                                                          /** ccdav keys **/
                                                          {MODEL_KEY::N, "n"},
                                                          {MODEL_KEY::IM, "im"},
                                                          {MODEL_KEY::PHOTO, "photo"},
                                                          {MODEL_KEY::GENDER, "gender"},
                                                          {MODEL_KEY::ADR, "adr"},
                                                          {MODEL_KEY::ADR_2, "adr2"},
                                                          {MODEL_KEY::ADR_3, "adr3"},
                                                          {MODEL_KEY::EMAIL, "email"},
                                                          {MODEL_KEY::EMAIL_2, "email2"},
                                                          {MODEL_KEY::EMAIL_3, "email3"},
                                                          {MODEL_KEY::LANG, "lang"},
                                                          {MODEL_KEY::NICKNAME, "nickname"},
                                                          {MODEL_KEY::ORG, "org"},
                                                          {MODEL_KEY::PROFILE, "profile"},
                                                          {MODEL_KEY::TZ, "tz"},
                                                          {MODEL_KEY::TEL, "tel"},
                                                          {MODEL_KEY::TEL_2, "tel2"},
                                                          {MODEL_KEY::TEL_3, "tel3"},

                                                          {MODEL_KEY::CITY, "city"},
                                                          {MODEL_KEY::STATE, "state"},
                                                          {MODEL_KEY::COUNTRY, "country"},

                                                          // opendesktop keys
                                                          {MODEL_KEY::PACKAGE_ARCH, "packagearch"},
                                                          {MODEL_KEY::PACKAGE_TYPE, "packagetype"},
                                                          {MODEL_KEY::GPG_FINGERPRINT, "gpgfingerprint"},
                                                          {MODEL_KEY::GPG_SIGNATURE, "gpgsignature"},
                                                          {MODEL_KEY::PACKAGE_NAME, "packagename"},
                                                          {MODEL_KEY::PRICE, "price"},
                                                          {MODEL_KEY::REPOSITORY, "repository"},
                                                          {MODEL_KEY::TAGS, "tags"},
                                                          {MODEL_KEY::WAY, "way"},
                                                          {MODEL_KEY::PIC, "pic"},
                                                          {MODEL_KEY::SMALL_PIC, "smallpic"},
                                                          {MODEL_KEY::CHANGED, "changed"},
                                                          {MODEL_KEY::COMMENTS, "comments"},
                                                          {MODEL_KEY::CREATED, "created"},
                                                          {MODEL_KEY::DETAIL_PAGE, "detailpage"},
                                                          {MODEL_KEY::DETAILS, "details"},
                                                          {MODEL_KEY::TOTAL_DOWNLOADS, "totaldownloads"},
                                                          {MODEL_KEY::GHNS_EXCLUDED, "ghnsexcluded"},
                                                          {MODEL_KEY::LANGUAGE, "language"},
                                                          {MODEL_KEY::SCORE, "score"},
                                                          {MODEL_KEY::SUMMARY, "summary"},
                                                          {MODEL_KEY::TYPE_ID, "typeid"},
                                                          {MODEL_KEY::TYPE_NAME, "typename"},
                                                          {MODEL_KEY::XDG_TYPE, "xdgtype"},

                                                          // file props
                                                          {MODEL_KEY::SYMLINK, "symlink"},
                                                          {MODEL_KEY::IS_SYMLINK, "issymlink"},
                                                          {MODEL_KEY::LAST_READ, "lastread"},
                                                          {MODEL_KEY::READABLE, "readable"},
                                                          {MODEL_KEY::WRITABLE, "writeable"},
                                                          {MODEL_KEY::IS_DIR, "isdir"},
                                                          {MODEL_KEY::IS_FILE, "isfile"},
                                                          {MODEL_KEY::IS_REMOTE, "isremote"},
                                                          {MODEL_KEY::EXECUTABLE, "executable"},
                                                          {MODEL_KEY::VALUE, "value"},
                                                          {MODEL_KEY::KEY, "key"},

                                                          {MODEL_KEY::MAC, "mac"},
                                                          {MODEL_KEY::LOT, "lot"},
                                                          {MODEL_KEY::APP, "app"},
                                                          {MODEL_KEY::URI, "uri"},
                                                          {MODEL_KEY::DEVICE, "device"},
                                                          {MODEL_KEY::LASTSYNC, "lastsync"}

                                                         };

static const QHash<QString, FMH::MODEL_KEY> MODEL_NAME_KEY = {{MODEL_NAME[MODEL_KEY::ICON], MODEL_KEY::ICON},
                                                              {MODEL_NAME[MODEL_KEY::LABEL], MODEL_KEY::LABEL},
                                                              {MODEL_NAME[MODEL_KEY::PATH], MODEL_KEY::PATH},
                                                              {MODEL_NAME[MODEL_KEY::URL], MODEL_KEY::URL},
                                                              {MODEL_NAME[MODEL_KEY::TYPE], MODEL_KEY::TYPE},
                                                              {MODEL_NAME[MODEL_KEY::GROUP], MODEL_KEY::GROUP},
                                                              {MODEL_NAME[MODEL_KEY::OWNER], MODEL_KEY::OWNER},
                                                              {MODEL_NAME[MODEL_KEY::SUFFIX], MODEL_KEY::SUFFIX},
                                                              {MODEL_NAME[MODEL_KEY::NAME], MODEL_KEY::NAME},
                                                              {MODEL_NAME[MODEL_KEY::DATE], MODEL_KEY::DATE},
                                                              {MODEL_NAME[MODEL_KEY::MODIFIED], MODEL_KEY::MODIFIED},
                                                              {MODEL_NAME[MODEL_KEY::MIME], MODEL_KEY::MIME},
                                                              {
                                                                  MODEL_NAME[MODEL_KEY::SIZE],
                                                                  MODEL_KEY::SIZE,
                                                              },
                                                              {MODEL_NAME[MODEL_KEY::TAG], MODEL_KEY::TAG},
                                                              {MODEL_NAME[MODEL_KEY::PERMISSIONS], MODEL_KEY::PERMISSIONS},
                                                              {MODEL_NAME[MODEL_KEY::THUMBNAIL], MODEL_KEY::THUMBNAIL},
                                                              {MODEL_NAME[MODEL_KEY::THUMBNAIL_1], MODEL_KEY::THUMBNAIL_1},
                                                              {MODEL_NAME[MODEL_KEY::THUMBNAIL_2], MODEL_KEY::THUMBNAIL_2},
                                                              {MODEL_NAME[MODEL_KEY::THUMBNAIL_3], MODEL_KEY::THUMBNAIL_3},
                                                              {MODEL_NAME[MODEL_KEY::ICONSIZE], MODEL_KEY::ICONSIZE},
                                                              {MODEL_NAME[MODEL_KEY::HIDDEN], MODEL_KEY::HIDDEN},
                                                              {MODEL_NAME[MODEL_KEY::DETAILVIEW], MODEL_KEY::DETAILVIEW},
                                                              {MODEL_NAME[MODEL_KEY::SHOWTERMINAL], MODEL_KEY::SHOWTERMINAL},
                                                              {MODEL_NAME[MODEL_KEY::SHOWTHUMBNAIL], MODEL_KEY::SHOWTHUMBNAIL},
                                                              {MODEL_NAME[MODEL_KEY::COUNT], MODEL_KEY::COUNT},
                                                              {MODEL_NAME[MODEL_KEY::SORTBY], MODEL_KEY::SORTBY},
                                                              {MODEL_NAME[MODEL_KEY::USER], MODEL_KEY::USER},
                                                              {MODEL_NAME[MODEL_KEY::PASSWORD], MODEL_KEY::PASSWORD},
                                                              {MODEL_NAME[MODEL_KEY::SERVER], MODEL_KEY::SERVER},
                                                              {MODEL_NAME[MODEL_KEY::VIEWTYPE], MODEL_KEY::VIEWTYPE},
                                                              {MODEL_NAME[MODEL_KEY::ADDDATE], MODEL_KEY::ADDDATE},
                                                              {MODEL_NAME[MODEL_KEY::FAV], MODEL_KEY::FAV},
                                                              {MODEL_NAME[MODEL_KEY::FAVORITE], MODEL_KEY::FAVORITE},
                                                              {MODEL_NAME[MODEL_KEY::COLOR], MODEL_KEY::COLOR},
                                                              {MODEL_NAME[MODEL_KEY::RATE], MODEL_KEY::RATE},
                                                              {MODEL_NAME[MODEL_KEY::FORMAT], MODEL_KEY::FORMAT},
                                                              {MODEL_NAME[MODEL_KEY::PLACE], MODEL_KEY::PLACE},
                                                              {MODEL_NAME[MODEL_KEY::LOCATION], MODEL_KEY::LOCATION},
                                                              {MODEL_NAME[MODEL_KEY::ALBUM], MODEL_KEY::ALBUM},
                                                              {MODEL_NAME[MODEL_KEY::ARTIST], MODEL_KEY::ARTIST},
                                                              {MODEL_NAME[MODEL_KEY::DURATION], MODEL_KEY::DURATION},
                                                              {MODEL_NAME[MODEL_KEY::TRACK], MODEL_KEY::TRACK},
                                                              {MODEL_NAME[MODEL_KEY::GENRE], MODEL_KEY::GENRE},
                                                              {MODEL_NAME[MODEL_KEY::LYRICS], MODEL_KEY::LYRICS},
                                                              {MODEL_NAME[MODEL_KEY::RELEASEDATE], MODEL_KEY::RELEASEDATE},
                                                              {MODEL_NAME[MODEL_KEY::FORMAT], MODEL_KEY::FORMAT},
                                                              {MODEL_NAME[MODEL_KEY::WIKI], MODEL_KEY::WIKI},
                                                              {MODEL_NAME[MODEL_KEY::SOURCETYPE], MODEL_KEY::SOURCETYPE},
                                                              {MODEL_NAME[MODEL_KEY::ARTWORK], MODEL_KEY::ARTWORK},
                                                              {MODEL_NAME[MODEL_KEY::NOTE], MODEL_KEY::NOTE},
                                                              {MODEL_NAME[MODEL_KEY::MOOD], MODEL_KEY::MOOD},
                                                              {MODEL_NAME[MODEL_KEY::COMMENT], MODEL_KEY::COMMENT},
                                                              {MODEL_NAME[MODEL_KEY::CONTEXT], MODEL_KEY::CONTEXT},
                                                              {MODEL_NAME[MODEL_KEY::SOURCE], MODEL_KEY::SOURCE},
                                                              {MODEL_NAME[MODEL_KEY::PLAYLIST], MODEL_KEY::PLAYLIST},
                                                              {MODEL_NAME[MODEL_KEY::TITLE], MODEL_KEY::TITLE},
                                                              {MODEL_NAME[MODEL_KEY::ID], MODEL_KEY::ID},
                                                              {MODEL_NAME[MODEL_KEY::PARENT_ID], MODEL_KEY::PARENT_ID},
                                                              {MODEL_NAME[MODEL_KEY::LICENSE], MODEL_KEY::LICENSE},
                                                              {MODEL_NAME[MODEL_KEY::DESCRIPTION], MODEL_KEY::DESCRIPTION},
                                                              {MODEL_NAME[MODEL_KEY::BOOKMARK], MODEL_KEY::BOOKMARK},
                                                              {MODEL_NAME[MODEL_KEY::ACCOUNT], MODEL_KEY::ACCOUNT},
                                                              {MODEL_NAME[MODEL_KEY::ACCOUNTTYPE], MODEL_KEY::ACCOUNTTYPE},
                                                              {MODEL_NAME[MODEL_KEY::VERSION], MODEL_KEY::VERSION},
                                                              {MODEL_NAME[MODEL_KEY::DOMAIN_M], MODEL_KEY::DOMAIN_M},
                                                              {MODEL_NAME[MODEL_KEY::CATEGORY], MODEL_KEY::CATEGORY},
                                                              {MODEL_NAME[MODEL_KEY::CONTENT], MODEL_KEY::CONTENT},
                                                              {MODEL_NAME[MODEL_KEY::PIN], MODEL_KEY::PIN},
                                                              {MODEL_NAME[MODEL_KEY::IMG], MODEL_KEY::IMG},
                                                              {MODEL_NAME[MODEL_KEY::PREVIEW], MODEL_KEY::PREVIEW},
                                                              {MODEL_NAME[MODEL_KEY::LINK], MODEL_KEY::LINK},
                                                              {MODEL_NAME[MODEL_KEY::STAMP], MODEL_KEY::STAMP},
                                                              {MODEL_NAME[MODEL_KEY::BOOK], MODEL_KEY::BOOK},

                                                              /** ccdav keys **/
                                                              {MODEL_NAME[MODEL_KEY::N], MODEL_KEY::N},
                                                              {MODEL_NAME[MODEL_KEY::IM], MODEL_KEY::IM},
                                                              {MODEL_NAME[MODEL_KEY::PHOTO], MODEL_KEY::PHOTO},
                                                              {MODEL_NAME[MODEL_KEY::GENDER], MODEL_KEY::GENDER},
                                                              {MODEL_NAME[MODEL_KEY::ADR], MODEL_KEY::ADR},
                                                              {MODEL_NAME[MODEL_KEY::ADR_2], MODEL_KEY::ADR_2},
                                                              {MODEL_NAME[MODEL_KEY::ADR_3], MODEL_KEY::ADR_3},
                                                              {MODEL_NAME[MODEL_KEY::EMAIL], MODEL_KEY::EMAIL},
                                                              {MODEL_NAME[MODEL_KEY::EMAIL_2], MODEL_KEY::EMAIL_2},
                                                              {MODEL_NAME[MODEL_KEY::EMAIL_3], MODEL_KEY::EMAIL_3},
                                                              {MODEL_NAME[MODEL_KEY::LANG], MODEL_KEY::LANG},
                                                              {MODEL_NAME[MODEL_KEY::NICKNAME], MODEL_KEY::NICKNAME},
                                                              {MODEL_NAME[MODEL_KEY::ORG], MODEL_KEY::ORG},
                                                              {MODEL_NAME[MODEL_KEY::PROFILE], MODEL_KEY::PROFILE},
                                                              {MODEL_NAME[MODEL_KEY::TZ], MODEL_KEY::TZ},
                                                              {MODEL_NAME[MODEL_KEY::TEL], MODEL_KEY::TEL},
                                                              {MODEL_NAME[MODEL_KEY::TEL_2], MODEL_KEY::TEL_2},
                                                              {MODEL_NAME[MODEL_KEY::TEL_3], MODEL_KEY::TEL_3},

                                                              {MODEL_NAME[MODEL_KEY::CITY], MODEL_KEY::CITY},
                                                              {MODEL_NAME[MODEL_KEY::STATE], MODEL_KEY::STATE},
                                                              {MODEL_NAME[MODEL_KEY::COUNTRY], MODEL_KEY::COUNTRY},

                                                              // opendesktop store keys
                                                              {MODEL_NAME[MODEL_KEY::PACKAGE_ARCH], MODEL_KEY::PACKAGE_ARCH},
                                                              {MODEL_NAME[MODEL_KEY::PACKAGE_TYPE], MODEL_KEY::PACKAGE_TYPE},
                                                              {MODEL_NAME[MODEL_KEY::GPG_FINGERPRINT], MODEL_KEY::GPG_FINGERPRINT},
                                                              {MODEL_NAME[MODEL_KEY::GPG_SIGNATURE], MODEL_KEY::GPG_SIGNATURE},
                                                              {MODEL_NAME[MODEL_KEY::PACKAGE_NAME], MODEL_KEY::PACKAGE_NAME},
                                                              {MODEL_NAME[MODEL_KEY::PRICE], MODEL_KEY::PRICE},
                                                              {MODEL_NAME[MODEL_KEY::REPOSITORY], MODEL_KEY::REPOSITORY},
                                                              {MODEL_NAME[MODEL_KEY::TAGS], MODEL_KEY::TAGS},
                                                              {MODEL_NAME[MODEL_KEY::WAY], MODEL_KEY::WAY},
                                                              {MODEL_NAME[MODEL_KEY::PIC], MODEL_KEY::PIC},
                                                              {MODEL_NAME[MODEL_KEY::SMALL_PIC], MODEL_KEY::SMALL_PIC},
                                                              {MODEL_NAME[MODEL_KEY::CHANGED], MODEL_KEY::CHANGED},
                                                              {MODEL_NAME[MODEL_KEY::COMMENTS], MODEL_KEY::COMMENTS},
                                                              {MODEL_NAME[MODEL_KEY::CREATED], MODEL_KEY::CREATED},
                                                              {MODEL_NAME[MODEL_KEY::DETAIL_PAGE], MODEL_KEY::DETAIL_PAGE},
                                                              {MODEL_NAME[MODEL_KEY::DETAILS], MODEL_KEY::DETAILS},
                                                              {MODEL_NAME[MODEL_KEY::TOTAL_DOWNLOADS], MODEL_KEY::TOTAL_DOWNLOADS},
                                                              {MODEL_NAME[MODEL_KEY::GHNS_EXCLUDED], MODEL_KEY::GHNS_EXCLUDED},
                                                              {MODEL_NAME[MODEL_KEY::LANGUAGE], MODEL_KEY::LANGUAGE},
                                                              {MODEL_NAME[MODEL_KEY::PERSON_ID], MODEL_KEY::PERSON_ID},
                                                              {MODEL_NAME[MODEL_KEY::SCORE], MODEL_KEY::SCORE},
                                                              {MODEL_NAME[MODEL_KEY::SUMMARY], MODEL_KEY::SUMMARY},
                                                              {MODEL_NAME[MODEL_KEY::TYPE_ID], MODEL_KEY::TYPE_ID},
                                                              {MODEL_NAME[MODEL_KEY::TYPE_NAME], MODEL_KEY::TYPE_NAME},
                                                              {MODEL_NAME[MODEL_KEY::XDG_TYPE], MODEL_KEY::XDG_TYPE},

                                                              // file props
                                                              {MODEL_NAME[MODEL_KEY::SYMLINK], MODEL_KEY::SYMLINK},
                                                              {MODEL_NAME[MODEL_KEY::IS_SYMLINK], MODEL_KEY::IS_SYMLINK},
                                                              {MODEL_NAME[MODEL_KEY::LAST_READ], MODEL_KEY::LAST_READ},
                                                              {MODEL_NAME[MODEL_KEY::READABLE], MODEL_KEY::READABLE},
                                                              {MODEL_NAME[MODEL_KEY::WRITABLE], MODEL_KEY::WRITABLE},
                                                              {MODEL_NAME[MODEL_KEY::IS_DIR], MODEL_KEY::IS_DIR},
                                                              {MODEL_NAME[MODEL_KEY::IS_FILE], MODEL_KEY::IS_FILE},
                                                              {MODEL_NAME[MODEL_KEY::IS_REMOTE], MODEL_KEY::IS_REMOTE},
                                                              {MODEL_NAME[MODEL_KEY::EXECUTABLE], MODEL_KEY::EXECUTABLE},
                                                              {MODEL_NAME[MODEL_KEY::VALUE], MODEL_KEY::VALUE},
                                                              {MODEL_NAME[MODEL_KEY::KEY], MODEL_KEY::KEY},

                                                              {MODEL_NAME[MODEL_KEY::MAC], MODEL_KEY::MAC},
                                                              {MODEL_NAME[MODEL_KEY::LOT], MODEL_KEY::LOT},
                                                              {MODEL_NAME[MODEL_KEY::APP], MODEL_KEY::APP},
                                                              {MODEL_NAME[MODEL_KEY::URI], MODEL_KEY::URI},
                                                              {MODEL_NAME[MODEL_KEY::DEVICE], MODEL_KEY::DEVICE},
                                                              {MODEL_NAME[MODEL_KEY::LASTSYNC], MODEL_KEY::LASTSYNC}
                                                             };
/**
 * @brief MODEL
 */
typedef QHash<FMH::MODEL_KEY, QString> MODEL;

/**
 * @brief MODEL_LIST
 */
typedef QVector<MODEL> MODEL_LIST;

/**
 * @brief modelRoles
 * @param model
 * @return
 */
static const QVector<int> modelRoles(const FMH::MODEL &model)
{
    const auto keys = model.keys();
    return std::accumulate(keys.begin(), keys.end(), QVector<int>(), [](QVector<int> &res, const FMH::MODEL_KEY &key) {
        res.append(key);
        return res;
    });
}

/**
 * @brief mapValue
 * @param map
 * @param key
 * @return
 */
static const QString mapValue(const QVariantMap &map, const FMH::MODEL_KEY &key)
{
    return map[FMH::MODEL_NAME[key]].toString();
}

/**
 * @brief toMap
 * @param model
 * @return
 */
static const QVariantMap toMap(const FMH::MODEL &model)
{
    QVariantMap map;
    for (const auto &key : model.keys())
        map.insert(FMH::MODEL_NAME[key], model[key]);

    return map;
}

/**
 * @brief toModel
 * @param map
 * @return
 */
static const FMH::MODEL toModel(const QVariantMap &map)
{
    FMH::MODEL model;
    for (const auto &key : map.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], map[key].toString());

    return model;
}

/**
         * Creates a FMH::MODEL_LIST from a QVariantList
         * */
/**
 * @brief toModelList
 * @param list
 * @return
 */
static const FMH::MODEL_LIST toModelList(const QVariantList &list)
{
    FMH::MODEL_LIST res;
    return std::accumulate(list.constBegin(), list.constEnd(), res, [](FMH::MODEL_LIST &res, const QVariant &item) -> FMH::MODEL_LIST
    {
        res << FMH::toModel(item.toMap());
        return res;
    });
}

/**
         * Creates a QVariantList from a FMH::MODEL_LIST
         * */
/**
 * @brief toMapList
 * @param list
 * @return
 */
static const QVariantList toMapList(const FMH::MODEL_LIST &list)
{
    QVariantList res;
    return std::accumulate(list.constBegin(), list.constEnd(), res, [](QVariantList &res, const FMH::MODEL &item) -> QVariantList
    {
        res << FMH::toMap(item);
        return res;
    });
}

/**
         * Creates a new FMH::MODEL from another filtered by the given array of FMH::MODEL_KEY
         * */
/**
 * @brief filterModel
 * @param model
 * @param keys
 * @return
 */
static const FMH::MODEL filterModel(const FMH::MODEL &model, const QVector<FMH::MODEL_KEY> &keys)
{
    FMH::MODEL res;
    return std::accumulate(keys.constBegin(), keys.constEnd(), res, [=](FMH::MODEL &res, const FMH::MODEL_KEY &key) -> FMH::MODEL
    {
        if (model.contains(key))
            res[key] = model[key];
        return res;
    });
}

/**
         * Extracts from a FMH::MODEL_LIST the values from a given MODEL::KEY into a QStringList
         * */

/**
 * @brief modelToList
 * @param list
 * @param key
 * @return
 */
static const QStringList modelToList(const FMH::MODEL_LIST &list, const FMH::MODEL_KEY &key)
{
    QStringList res;
    return std::accumulate(list.constBegin(), list.constEnd(), res, [key](QStringList &res, const FMH::MODEL &item) -> QStringList
    {
        if (item.contains(key))
            res << item[key];
        return res;
    });
}

/**
 * @brief The PATH_CONTENT struct
 */
struct PATH_CONTENT {
    QUrl path;               // the url holding all the content
    FMH::MODEL_LIST content; // the content from the url
};

/**
 * @brief The PATHTYPE_KEY enum
 */
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS // for android, windows and mac use this for now
enum PATHTYPE_KEY : int {
    PLACES_PATH,
    REMOTE_PATH,
    DRIVES_PATH,
    REMOVABLE_PATH,
    TAGS_PATH,
    UNKNOWN_TYPE,
    APPS_PATH,
    TRASH_PATH,
    SEARCH_PATH,
    CLOUD_PATH,
    FISH_PATH,
    MTP_PATH,
    QUICK_PATH,
    BOOKMARKS_PATH,
    OTHER_PATH,
};
#else
enum PATHTYPE_KEY : int {
    PLACES_PATH = KFilePlacesModel::GroupType::PlacesType,
    REMOTE_PATH = KFilePlacesModel::GroupType::RemoteType,
    DRIVES_PATH = KFilePlacesModel::GroupType::DevicesType,
    REMOVABLE_PATH = KFilePlacesModel::GroupType::RemovableDevicesType,
    TAGS_PATH = KFilePlacesModel::GroupType::TagsType,
    UNKNOWN_TYPE = KFilePlacesModel::GroupType::UnknownType,
    APPS_PATH = 9,
    TRASH_PATH = 10,
    SEARCH_PATH = 11,
    CLOUD_PATH = 12,
    FISH_PATH = 13,
    MTP_PATH = 14,
    QUICK_PATH = 15,
    BOOKMARKS_PATH = 16,
    OTHER_PATH = 17
};
#endif

static const QHash<PATHTYPE_KEY, QString> PATHTYPE_SCHEME = {{PATHTYPE_KEY::PLACES_PATH, "file"},
                                                             {PATHTYPE_KEY::BOOKMARKS_PATH, "file"},
                                                             {PATHTYPE_KEY::DRIVES_PATH, "drives"},
                                                             {PATHTYPE_KEY::APPS_PATH, "applications"},
                                                             {PATHTYPE_KEY::REMOTE_PATH, "remote"},
                                                             {PATHTYPE_KEY::REMOVABLE_PATH, "removable"},
                                                             {PATHTYPE_KEY::UNKNOWN_TYPE, "Unkown"},
                                                             {PATHTYPE_KEY::TRASH_PATH, "trash"},
                                                             {PATHTYPE_KEY::TAGS_PATH, "tags"},
                                                             {PATHTYPE_KEY::SEARCH_PATH, "search"},
                                                             {PATHTYPE_KEY::CLOUD_PATH, "cloud"},
                                                             {PATHTYPE_KEY::FISH_PATH, "fish"},
                                                             {PATHTYPE_KEY::MTP_PATH, "mtp"}};

static const QHash<QString, PATHTYPE_KEY> PATHTYPE_SCHEME_NAME ={{PATHTYPE_SCHEME[PATHTYPE_KEY::PLACES_PATH], PATHTYPE_KEY::PLACES_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::BOOKMARKS_PATH], PATHTYPE_KEY::BOOKMARKS_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::DRIVES_PATH], PATHTYPE_KEY::DRIVES_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::APPS_PATH], PATHTYPE_KEY::APPS_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::REMOTE_PATH], PATHTYPE_KEY::REMOTE_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::REMOVABLE_PATH], PATHTYPE_KEY::REMOVABLE_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::UNKNOWN_TYPE], PATHTYPE_KEY::UNKNOWN_TYPE},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::TRASH_PATH], PATHTYPE_KEY::TRASH_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::TAGS_PATH], PATHTYPE_KEY::TAGS_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::SEARCH_PATH], PATHTYPE_KEY::SEARCH_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::CLOUD_PATH], PATHTYPE_KEY::CLOUD_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::FISH_PATH], PATHTYPE_KEY::FISH_PATH},
                                                                 {PATHTYPE_SCHEME[PATHTYPE_KEY::MTP_PATH], PATHTYPE_KEY::MTP_PATH}};

static const QHash<PATHTYPE_KEY, QString> PATHTYPE_URI = {{PATHTYPE_KEY::PLACES_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::PLACES_PATH] + "://"},
                                                          {PATHTYPE_KEY::BOOKMARKS_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::BOOKMARKS_PATH] + "://"},
                                                          {PATHTYPE_KEY::DRIVES_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::DRIVES_PATH] + "://"},
                                                          {PATHTYPE_KEY::APPS_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::APPS_PATH] + ":///"},
                                                          {PATHTYPE_KEY::REMOTE_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::REMOTE_PATH] + "://"},
                                                          {PATHTYPE_KEY::REMOVABLE_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::REMOVABLE_PATH] + "://"},
                                                          {PATHTYPE_KEY::UNKNOWN_TYPE, PATHTYPE_SCHEME[PATHTYPE_KEY::UNKNOWN_TYPE] + "://"},
                                                          {PATHTYPE_KEY::TRASH_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::TRASH_PATH] + "://"},
                                                          {PATHTYPE_KEY::TAGS_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::TAGS_PATH] + ":///"},
                                                          {PATHTYPE_KEY::SEARCH_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::SEARCH_PATH] + "://"},
                                                          {PATHTYPE_KEY::CLOUD_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::CLOUD_PATH] + ":///"},
                                                          {PATHTYPE_KEY::FISH_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::FISH_PATH] + "://"},
                                                          {PATHTYPE_KEY::MTP_PATH, PATHTYPE_SCHEME[PATHTYPE_KEY::MTP_PATH] + "://"}};

static const QHash<PATHTYPE_KEY, QString> PATHTYPE_LABEL = {{PATHTYPE_KEY::PLACES_PATH, ("Places")},
                                                            {PATHTYPE_KEY::BOOKMARKS_PATH, ("Bookmarks")},
                                                            {PATHTYPE_KEY::DRIVES_PATH, ("Drives")},
                                                            {PATHTYPE_KEY::APPS_PATH, ("Apps")},
                                                            {PATHTYPE_KEY::REMOTE_PATH, ("Remote")},
                                                            {PATHTYPE_KEY::REMOVABLE_PATH, ("Removable")},
                                                            {PATHTYPE_KEY::UNKNOWN_TYPE, ("Unknown")},
                                                            {PATHTYPE_KEY::TRASH_PATH, ("Trash")},
                                                            {PATHTYPE_KEY::TAGS_PATH, ("Tags")},
                                                            {PATHTYPE_KEY::SEARCH_PATH, ("Search")},
                                                            {PATHTYPE_KEY::CLOUD_PATH, ("Cloud")},
                                                            {PATHTYPE_KEY::FISH_PATH, ("Remote")},
                                                            {PATHTYPE_KEY::MTP_PATH, ("Drives")},
                                                            {PATHTYPE_KEY::OTHER_PATH, ("Others")},
                                                            {PATHTYPE_KEY::QUICK_PATH, ("Quick")}};

/**
 * @brief DataPath
 */
static const QString DataPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);

/**
 * @brief ConfigPath
 */
static const QString ConfigPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)).toString();

/**
 * @brief CloudCachePath
 */
static const QString CloudCachePath = FMH::DataPath + "/Cloud/";

/**
 * @brief DesktopPath
 */
static const QString DesktopPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation)).toString();

/**
 * @brief AppsPath
 */
static const QString AppsPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation)).toString();

/**
 * @brief RootPath
 */
static const QString RootPath = QUrl::fromLocalFile("/").toString();

#if defined(Q_OS_ANDROID)
static const QString PicturesPath = QUrl::fromLocalFile(PATHS::PicturesPath).toString();
static const QString DownloadsPath = QUrl::fromLocalFile(PATHS::DownloadsPath).toString();
static const QString DocumentsPath = QUrl::fromLocalFile(PATHS::DocumentsPath).toString();
static const QString HomePath = QUrl::fromLocalFile(PATHS::HomePath).toString();
static const QString MusicPath = QUrl::fromLocalFile(PATHS::MusicPath).toString();
static const QString VideosPath = QUrl::fromLocalFile(PATHS::VideosPath).toString();

static const QStringList defaultPaths = {FMH::HomePath, FMH::DocumentsPath, FMH::PicturesPath, FMH::MusicPath, FMH::VideosPath, FMH::DownloadsPath};

#else
static const QString PicturesPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)).toString();
static const QString DownloadsPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)).toString();
static const QString DocumentsPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)).toString();
static const QString HomePath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::HomeLocation)).toString();
static const QString MusicPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::MusicLocation)).toString();
static const QString VideosPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::MoviesLocation)).toString();

static const QStringList defaultPaths = {
    FMH::HomePath,
    FMH::DesktopPath,
    FMH::DocumentsPath,
    FMH::PicturesPath,
    FMH::MusicPath,
    FMH::VideosPath,
    FMH::DownloadsPath,
    // 		FMH::RootPath
};

#endif

static const QMap<QString, QString> folderIcon {{PicturesPath, "folder-pictures"},
                                         {DownloadsPath, "folder-download"},
                                         {DocumentsPath, "folder-documents"},
                                         {HomePath, "user-home"},
                                         {MusicPath, "folder-music"},
                                         {VideosPath, "folder-videos"},
                                         {DesktopPath, "user-desktop"},
                                         {AppsPath, "system-run"},
                                         {RootPath, "folder-root"}};

/**
         * Checks if a local file exists.
         * The URL must represent a local file path, by using the scheme file://
         **/
/**
 * @brief fileExists
 * @param path
 * @return
 */
static bool fileExists(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file" << path;
        return false;
    }
    return QFileInfo::exists(path.toLocalFile());
}

/**
 * @brief fileDir
 * @param path
 * @return
 */
static const QString fileDir(const QUrl &path) // the directory path of the file
{
    QString res = path.toString();
    if (path.isLocalFile()) {
        const QFileInfo file(path.toLocalFile());
        if (file.isDir())
            res = path.toString();
        else
            res = QUrl::fromLocalFile(file.dir().absolutePath()).toString();
    } else
        qWarning() << "The path is not a local one. FM::fileDir";

    return res;
}

/**
 * @brief parentDir
 * @param path
 * @return
 */
static const QUrl parentDir(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file, FM::parentDir" << path;
        return path;
    }

    QDir dir(path.toLocalFile());
    dir.cdUp();
    return QUrl::fromLocalFile(dir.absolutePath());
}

/**
         * Return the configuration of a single directory represented
         * by a QVariantMap.
         * The passed path must be a local file URL.
         **/
/**
 * @brief dirConf
 * @param path
 * @return
 */
static QVariantMap dirConf(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file" << path;
        return QVariantMap();
    }

    if (!FMH::fileExists(path))
        return QVariantMap();

    QString icon, iconsize, hidden, detailview, showthumbnail, showterminal;

    uint count = 0, sortby = FMH::MODEL_KEY::MODIFIED, viewType = 0;

    bool foldersFirst = false;

#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    QSettings file(path.toLocalFile(), QSettings::Format::NativeFormat);
    file.beginGroup(QString("Desktop Entry"));
    icon = file.value("Icon").toString();
    file.endGroup();

    file.beginGroup(QString("Settings"));
    hidden = file.value("HiddenFilesShown").toString();
    file.endGroup();

    file.beginGroup(QString("MAUIFM"));
    iconsize = file.value("IconSize").toString();
    detailview = file.value("DetailView").toString();
    showthumbnail = file.value("ShowThumbnail").toString();
    showterminal = file.value("ShowTerminal").toString();
    count = file.value("Count").toInt();
    sortby = file.value("SortBy").toInt();
    foldersFirst = file.value("FoldersFirst").toBool();
    viewType = file.value("ViewType").toInt();
    file.endGroup();

#else
    KConfig file(path.toLocalFile());
    icon = file.entryMap(QString("Desktop Entry"))["Icon"];
    hidden = file.entryMap(QString("Settings"))["HiddenFilesShown"];
    iconsize = file.entryMap(QString("MAUIFM"))["IconSize"];
    detailview = file.entryMap(QString("MAUIFM"))["DetailView"];
    showthumbnail = file.entryMap(QString("MAUIFM"))["ShowThumbnail"];
    showterminal = file.entryMap(QString("MAUIFM"))["ShowTerminal"];
    count = file.entryMap(QString("MAUIFM"))["Count"].toInt();
    sortby = file.entryMap(QString("MAUIFM"))["SortBy"].toInt();
    foldersFirst = file.entryMap(QString("MAUIFM"))["FoldersFirst"] == "true" ? true : false;
    viewType = file.entryMap(QString("MAUIFM"))["ViewType"].toInt();
#endif

    return QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], icon.isEmpty() ? "folder" : icon},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::ICONSIZE], iconsize},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::COUNT], count},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTERMINAL], showterminal.isEmpty() ? "false" : showterminal},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTHUMBNAIL], showthumbnail.isEmpty() ? "false" : showthumbnail},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::DETAILVIEW], detailview.isEmpty() ? "false" : detailview},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN], hidden.isEmpty() ? false : (hidden == "true" ? true : false)},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SORTBY], sortby},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::FOLDERSFIRST], foldersFirst},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::VIEWTYPE], viewType}});
}

/**
 * @brief setDirConf
 * @param path
 * @param group
 * @param key
 * @param value
 */
static void setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file" << path;
        return;
    }

#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    QSettings file(path.toLocalFile(), QSettings::Format::IniFormat);
    file.beginGroup(group);
    file.setValue(key, value);
    file.endGroup();
    file.sync();
#else
    KConfig file(path.toLocalFile(), KConfig::SimpleConfig);
    auto kgroup = file.group(group);
    kgroup.writeEntry(key, value);
    // 		file.reparseConfiguration();
    file.sync();
#endif
}

/**
         * Returns the icon name for certain file.
         * The file path must be represented as a local file URL.
         * It also looks into the directory config file to get custom set icons
         **/
/**
 * @brief getIconName
 * @param path
 * @return
 */
static QString getIconName(const QUrl &path)
{
    if (!path.isLocalFile())
        qWarning() << "URL recived is not a local file. FMH::getIconName" << path;

    if (path.isLocalFile() && QFileInfo(path.toLocalFile()).isDir()) {
        if (folderIcon.contains(path.toString()))
            return folderIcon[path.toString()];
        else {
            const auto icon = FMH::dirConf(QString(path.toString() + "/%1").arg(".directory"))[FMH::MODEL_NAME[FMH::MODEL_KEY::ICON]].toString();
            return icon.isEmpty() ? "folder" : icon;
        }

    } else {
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
        QMimeDatabase mime;
        const auto type = mime.mimeTypeForFile(path.toString());
        return type.iconName();
#else
        KFileItem mime(path);
        return mime.iconName();
#endif
    }
}

/**
 * @brief getMime
 * @param path
 * @return
 */
static QString getMime(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file, FMH::getMime" << path;
        return QString();
    }

    const QMimeDatabase mimedb;
    return mimedb.mimeTypeForFile(path.toLocalFile()).name();
}

/**
 * @brief mimeInherits
 * @param baseType
 * @param type
 * @return
 */
static bool mimeInherits(const QString baseType, const QString &type)
{
    const QMimeDatabase _m;
    return _m.mimeTypeForName(baseType).inherits(type);
}

/**
 * @brief checkFileType
 * @param type
 * @param mimeTypeName
 * @return
 */
static bool checkFileType(const FMH::FILTER_TYPE &type, const QString &mimeTypeName)
{
    return FMH::SUPPORTED_MIMETYPES[type].contains(mimeTypeName);
}

/**
 * @brief thumbnailUrl
 * Returns a valid thumbnail Url to an image provider if supported, otherwise an empty URL
 * @param url
 * @return
 */
static QUrl thumbnailUrl(const QUrl &url, const QString &mimetype)
{
    if(checkFileType(FMH::FILTER_TYPE::DOCUMENT, mimetype) || checkFileType(FMH::FILTER_TYPE::VIDEO, mimetype))
    {
        return QUrl("image://thumbnailer/"+url.toString());
    }

    if(checkFileType(FMH::FILTER_TYPE::IMAGE, mimetype))
    {
        return url;
    }

    return QUrl();
}

#if !defined Q_OS_ANDROID && defined Q_OS_LINUX
/**
 * @brief packFileInfo
 * @param item
 * @return
 */
static FMH::MODEL getFileInfo(const KFileItem &kfile)
{
    return FMH::MODEL {{FMH::MODEL_KEY::LABEL, kfile.name()},
        {FMH::MODEL_KEY::NAME, kfile.name().remove(kfile.name().lastIndexOf("."), kfile.name().size())},
        {FMH::MODEL_KEY::DATE, kfile.time(KFileItem::FileTimes::CreationTime).toString(Qt::TextDate)},
        {FMH::MODEL_KEY::MODIFIED, kfile.time(KFileItem::FileTimes::ModificationTime).toString(Qt::TextDate)},
        {FMH::MODEL_KEY::LAST_READ, kfile.time(KFileItem::FileTimes::AccessTime).toString(Qt::TextDate)},
        {FMH::MODEL_KEY::PATH, kfile.mostLocalUrl().toString()},
        {FMH::MODEL_KEY::THUMBNAIL, thumbnailUrl(kfile.mostLocalUrl(), kfile.mimetype()).toString()},
        {FMH::MODEL_KEY::SYMLINK, kfile.linkDest()},
        {FMH::MODEL_KEY::IS_SYMLINK, QVariant(kfile.isLink()).toString()},
        {FMH::MODEL_KEY::HIDDEN, QVariant(kfile.isHidden()).toString()},
        {FMH::MODEL_KEY::IS_DIR, QVariant(kfile.isDir()).toString()},
        {FMH::MODEL_KEY::IS_FILE, QVariant(kfile.isFile()).toString()},
        {FMH::MODEL_KEY::WRITABLE, QVariant(kfile.isWritable()).toString()},
        {FMH::MODEL_KEY::READABLE, QVariant(kfile.isReadable()).toString()},
        {FMH::MODEL_KEY::EXECUTABLE, QVariant(kfile.isDesktopFile()).toString()},
        {FMH::MODEL_KEY::MIME, kfile.mimetype()},
        {FMH::MODEL_KEY::GROUP, kfile.group()},
        {FMH::MODEL_KEY::ICON, kfile.iconName()},
        {FMH::MODEL_KEY::SIZE, QString::number(kfile.size())},
        {FMH::MODEL_KEY::OWNER, kfile.user()},
        {FMH::MODEL_KEY::COUNT, kfile.isLocalFile() && kfile.isDir() ? QString::number(QDir(kfile.localPath()).count() - 2) : "0"}};
#endif
}

/**
 * @brief getFileInfoModel
 * @param path
 * @return
 */
static FMH::MODEL getFileInfoModel(const QUrl &path)
{
    FMH::MODEL res;
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    const QFileInfo file(path.toLocalFile());
    if (!file.exists())
        return FMH::MODEL();

    const auto mime = FMH::getMime(path);
    res = FMH::MODEL {{FMH::MODEL_KEY::GROUP, file.group()},
    {FMH::MODEL_KEY::OWNER, file.owner()},
    {FMH::MODEL_KEY::SUFFIX, file.completeSuffix()},
    {FMH::MODEL_KEY::LABEL, /*file.isDir() ? file.baseName() :*/ path == FMH::HomePath ? QStringLiteral("Home") : file;::MODIFIED, file.lastModified().toString(Qt::TextDate)},
    {FMH::MODEL_KEY::LAST_READ, file.lastRead().toString(Qt::TextDate)},
    {FMH::MODEL_KEY::MIME, mime},
    {FMH::MODEL_KEY::SYMLINK, file.symLinkTarget()},
    {FMH::MODEL_KEY::IS_SYMLINK, QVariant(file.isSymLink()).toString()},
    {FMH::MODEL_KEY::IS_FILE, QVariant(file.isFile()).toString()},
    {FMH::MODEL_KEY::HIDDEN, QVariant(file.isHidden()).toString()},
    {FMH::MODEL_KEY::IS_DIR, QVariant(file.isDir()).toString()},
    {FMH::MODEL_KEY::WRITABLE, QVariant(file.isWritable()).toString()},
    {FMH::MODEL_KEY::READABLE, QVariant(file.isReadable()).toString()},
    {FMH::MODEL_KEY::EXECUTABLE, QVariant(file.suffix().endsWith(".desktop")).toString()},
    {FMH::MODEL_KEY::ICON, FMH::getIconName(path)},
    {FMH::MODEL_KEY::SIZE, QString::number(file.size()) /*locale.formattedDataSize(file.size())*/},
    {FMH::MODEL_KEY::PATH, path.toString()},
    {FMH::MODEL_KEY::THUMBNAIL, thumbnailUrl(path, mime},
    {FMH::MODEL_KEY::COUNT, file.isDir() ? QString::number(QDir(path.toLocalFile()).count() - 2) : "0"}};
        #else

    res = getFileInfo(KFileItem(path, KFileItem::MimeTypeDetermination::NormalMimeTypeDetermination));
        #endif
            return res;
}

            /**
                     * @brief getFileInfo
                     * @param path
                     * @return
                     */
            static QVariantMap getFileInfo(const QUrl &path)
    {
            return FMH::toMap(FMH::getFileInfoModel(path));
}

            /**
                     * @brief getDirInfoModel
                     * @param path
                     * @param type
                     * @return
                     */
            static FMH::MODEL getDirInfoModel(const QUrl &path, const QString &type = QString())
    {
            auto res = getFileInfoModel(path);
            res[FMH::MODEL_KEY::TYPE] = type;
            return res;
}

            /**
                     * @brief getDirInfo
                     * @param path
                     * @param type
                     * @return
                     */
            static QVariantMap getDirInfo(const QUrl &path, const QString &type = QString())
    {
            return FMH::toMap(FMH::getDirInfoModel(path));
}

            /**
                     * @brief getPathType
                     * @param url
                     * @return
                     */
            static FMH::PATHTYPE_KEY getPathType(const QUrl &url)
    {
            return FMH::PATHTYPE_SCHEME_NAME[url.scheme()];
}
}


#endif // FMH_H
