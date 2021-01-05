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

#include "tagging.h"
#include <QMimeDatabase>
#include <QNetworkInterface>
#include <QCoreApplication>
#include "utils.h"

Tagging::Tagging() : TAGDB()
{
    this->setApp();
}

const QVariantList Tagging::get(const QString &queryTxt, std::function<bool(QVariantMap &item)> modifier)
{
    QVariantList mapList;

    auto query = this->getQuery(queryTxt);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap data;
            const auto keys = FMH::MODEL_NAME.keys();
            for (const auto &key : keys) {
                if (query.record().indexOf(FMH::MODEL_NAME[key]) > -1)
                    data[FMH::MODEL_NAME[key]] = query.value(FMH::MODEL_NAME[key]).toString();
            }

            if (modifier) {
                if (!modifier(data))
                    continue;
            }
            mapList << data;
        }

    } else
        qDebug() << query.lastError() << query.lastQuery();

    return mapList;
}

bool Tagging::tagExists(const QString &tag, const bool &strict)
{
    return !strict ? this->checkExistance(TAG::TABLEMAP[TAG::TABLE::TAGS], FMH::MODEL_NAME[FMH::MODEL_KEY::TAG], tag)
            : this->checkExistance(QString("select t.tag from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac "
            "where au.app = '%1' and au.uri = '%2' and t.tag = '%3'")
            .arg(this->application, this->uri, tag));
}

bool Tagging::urlTagExists(const QString &url, const QString &tag, const bool &strict)
{
    return !strict ? this->checkExistance(QString("select * from TAGS_URLS where url = '%1' and tag = '%2'").arg(url, tag))
                   : this->checkExistance(QString("select t.tag from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac "
                                                  "where au.app = '%1' and au.uri = '%2' and t.tag = '%3'")
                                          .arg(this->application, this->uri, tag));
}

void Tagging::setApp()
{
    this->application = qApp->applicationName();
    this->version = qApp->applicationVersion();
    this->comment = QString();
    this->uri = qApp->organizationDomain().isEmpty() ? QString("org.maui.%1").arg(this->application) : qApp->organizationDomain();
    this->app(); // here register the app
}

bool Tagging::tag(const QString &tag, const QString &color, const QString &comment)
{
    if (tag.isEmpty())
        return false;

    QVariantMap tag_map {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::TAG], tag},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::APP], this->application},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR], color},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime().toString(Qt::TextDate)},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::COMMENT], comment},
    };

    this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS], tag_map);

    QVariantMap tag_user_map {{FMH::MODEL_NAME[FMH::MODEL_KEY::TAG], tag}, {FMH::MODEL_NAME[FMH::MODEL_KEY::MAC], this->id()}};
    if (this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_USERS], tag_user_map)) {
        setTagIconName(tag_map);        
        emit this->tagged(tag_map);
        return true;
    }

    return false;
}

bool Tagging::tagUrl(const QString &url, const QString &tag, const QString &color, const QString &comment)
{
    const auto myTag = tag.trimmed();

    this->tag(myTag, color, comment);

    QMimeDatabase mimedb;
    auto mime = mimedb.mimeTypeForFile(url);

    QVariantMap tag_url_map {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url},
                             {FMH::MODEL_NAME[FMH::MODEL_KEY::TAG], myTag},
                             {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], QFileInfo(url).baseName()},
                             {FMH::MODEL_NAME[FMH::MODEL_KEY::MIME], mime.name()},
                             {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()},
                             {FMH::MODEL_NAME[FMH::MODEL_KEY::COMMENT], comment}};

    emit this->urlTagged(url, myTag);
    return this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], tag_url_map);
}

bool Tagging::updateUrlTags(const QString &url, const QStringList &tags)
{
    this->removeUrlTags(url);
    for (const auto &tag : qAsConst(tags))
        this->tagUrl(url, tag);

    return true;
}

bool Tagging::updateUrl(const QString &url, const QString &newUrl)
{
    return this->update(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], {{FMH::MODEL_KEY::URL, newUrl}}, {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url}});
}

QVariantList Tagging::getUrlsTags(const bool &strict)
{
    const auto query = QString("select distinct t.* from TAGS t "
                               "where t.app = '%1'")
            .arg(this->application);

    return !strict ? this->get("select distinct t.* from tags t inner join TAGS_URLS turl on turl.tag = t.tag", &setTagIconName) : this->get(query, &setTagIconName);
}

bool Tagging::setTagIconName(QVariantMap &item)
{
    item.insert("icon", item.value("tag").toString() == "fav" ? "love" : "tag");
    return true;
}

QVariantList Tagging::getAllTags(const bool &strict)
{
    return !strict ? this->get("select * from tags group by tag", &setTagIconName)
                   : this->get(QString("select t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac and au.app = t.app "
                                       "where au.app = '%1' and au.uri = '%2'")
                               .arg(this->application, this->uri),
                               &setTagIconName);
}

QVariantList Tagging::getUrls(const QString &tag, const bool &strict, const int &limit, const QString &mimeType, std::function<bool(QVariantMap &item)> modifier)
{
    return !strict ? this->get(QString("select distinct * from TAGS_URLS where tag = '%1' and mime like '%2%' limit %3").arg(tag, mimeType, QString::number(limit)), modifier)
                   : this->get(QString("select distinct turl.*, t.color, t.comment as tagComment from TAGS t "
                                       "inner join TAGS_USERS tu on t.tag = tu.tag "
                                       "inner join APPS_USERS au on au.mac = tu.mac and au.app = t.app "
                                       "inner join TAGS_URLS turl on turl.tag = t.tag "
                                       "where au.app = '%1' and au.uri = '%2' and turl.mime like '%5%' "
                                       "and t.tag = '%3' limit %4")
                               .arg(this->application, this->uri, tag, QString::number(limit), mimeType),
                               modifier);
}

QVariantList Tagging::getUrlTags(const QString &url, const bool &strict)
{
    return !strict ? this->get(QString("select distinct turl.*, t.color, t.comment as tagComment from tags t inner join TAGS_URLS turl on turl.tag = t.tag where turl.url  = '%1'").arg(url))
                   : this->get(QString("select distinct t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac and au.app = t.app inner join TAGS_URLS turl on turl.tag = t.tag "
                                       "where au.app = '%1' and au.uri = '%2' and turl.url = '%3'")
                               .arg(this->application, this->uri, url));
}

bool Tagging::removeUrlTags(const QString &url)
{
    const auto tags = getUrlTags(url);
    for (const auto &map : tags) {
        auto tag = map.toMap().value(FMH::MODEL_NAME[FMH::MODEL_KEY::TAG]).toString();
        this->removeUrlTag(url, tag);
    }

    return true;
}

bool Tagging::removeUrlTag(const QString &url, const QString &tag)
{
    FMH::MODEL data {{FMH::MODEL_KEY::URL, url}, {FMH::MODEL_KEY::TAG, tag}};
    return this->remove(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], data);
}

bool Tagging::removeUrl(const QString &url)
{
    return this->remove(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], {{FMH::MODEL_KEY::URL, url}});
}

QString Tagging::mac()
{
    QNetworkInterface mac;
    qDebug() << "MAC ADDRES:" << mac.hardwareAddress();
    return mac.hardwareAddress();
}

QString Tagging::device()
{
    return QSysInfo::prettyProductName();
}

QString Tagging::id()
{
    return QSysInfo::machineHostName();

    //    qDebug()<< "VERSION IS LES THAN "<< QT_VERSION;

    //#if QT_VERSION < QT_VERSION_CHECK(5, 1, 1)
    //    return QSysInfo::machineHostName();
    //#else
    //    return QString(QSysInfo::machineUniqueId());
    //#endif
}

bool Tagging::app()
{
    qDebug() << "REGISTER APP" << this->application << this->uri << this->version << this->comment;
    QVariantMap app_map {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::APP], this->application},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::URI], this->uri},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::VERSION], this->version},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::COMMENT], this->comment},
    };

    this->insert(TAG::TABLEMAP[TAG::TABLE::APPS], app_map);

    this->user();

    QVariantMap users_apps_map {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::APP], this->application},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::URI], this->uri},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::MAC], this->id()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::APPS_USERS], users_apps_map);
}

bool Tagging::user()
{
    QVariantMap user_map {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::MAC], this->id()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::NAME], UTIL::whoami()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::LASTSYNC], QDateTime::currentDateTime()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::DEVICE], this->device()},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::USERS], user_map);
}
