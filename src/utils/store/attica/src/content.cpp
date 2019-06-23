/*
    This file is part of KDE.

    Copyright (c) 2008 Cornelius Schumacher <schumacher@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.

*/

#include "content.h"

#include <QDateTime>

using namespace Attica;

class Content::Private : public QSharedData
{
public:
    QString m_id;
    QString m_name;
    int m_downloads;
    int m_numberOfComments;
    int m_rating;
    QDateTime m_created;
    QDateTime m_updated;
    QList<Icon> m_icons;
    QList<QUrl> m_videos;
    QStringList m_tags;

    QMap<QString, QString> m_extendedAttributes;

    Private()
        : m_downloads(0),
          m_numberOfComments(0),
          m_rating(0)
    {
    }
};

Content::Content()
    : d(new Private)
{
}

Content::Content(const Attica::Content &other)
    : d(other.d)
{
}

Content &Content::operator=(const Attica::Content &other)
{
    d = other.d;
    return *this;
}

Content::~Content()
{
}

void Content::setId(const QString &u)
{
    d->m_id = u;
}

QString Content::id() const
{
    return d->m_id;
}

void Content::setName(const QString &name)
{
    d->m_name = name;
}

QString Content::name() const
{
    return d->m_name;
}

void Content::setRating(int v)
{
    d->m_rating = v;
}

int Content::rating() const
{
    return d->m_rating;
}

void Content::setDownloads(int v)
{
    d->m_downloads = v;
}

int Content::downloads() const
{
    return d->m_downloads;
}

void Content::setNumberOfComments(int v)
{
    d->m_numberOfComments = v;
}

int Content::numberOfComments() const
{
    return d->m_numberOfComments;
}

void Content::setCreated(const QDateTime &date)
{
    d->m_created = date;
}

QDateTime Content::created() const
{
    return d->m_created;
}

void Content::setUpdated(const QDateTime &date)
{
    d->m_updated = date;
}

QDateTime Content::updated() const
{
    return d->m_updated;
}

void Content::addAttribute(const QString &key, const QString &value)
{
    d->m_extendedAttributes.insert(key, value);
}

QString Content::attribute(const QString &key) const
{
    return d->m_extendedAttributes.value(key);
}

QMap<QString, QString> Content::attributes() const
{
    return d->m_extendedAttributes;
}

bool Content::isValid() const
{
    return !(d->m_id.isEmpty());
}

QString Content::summary() const
{
    return attribute(QLatin1String("summary"));
}

QString Content::description() const
{
    return attribute(QLatin1String("description"));
}

QUrl Content::detailpage() const
{
    return QUrl(attribute(QLatin1String("detailpage")));
}

QString Attica::Content::changelog() const
{
    return attribute(QLatin1String("changelog"));

}

QString Attica::Content::depend() const
{
    return attribute(QLatin1String("depend"));
}

QList<Attica::DownloadDescription> Attica::Content::downloadUrlDescriptions() const
{
    QList<Attica::DownloadDescription> descriptions;
    QMap<QString, QString>::const_iterator iter = d->m_extendedAttributes.constBegin();
    while (iter != d->m_extendedAttributes.constEnd()) {
        QString key = iter.key();
        if (key.startsWith(QLatin1String("downloadname"))) {
            bool ok;
            // remove "downloadlink", get the rest as number
            int num = key.rightRef(key.size() - 12).toInt(&ok);
            if (ok) {
                // check if the download actually has a name
                if (!iter.value().isEmpty()) {
                    descriptions.append(downloadUrlDescription(num));
                }
            }
        }
        ++iter;
    }
    return descriptions;
}

Attica::DownloadDescription Attica::Content::downloadUrlDescription(int number) const
{
    QString num(QString::number(number));
    DownloadDescription desc;

    Attica::DownloadDescription::Type downloadType = Attica::DownloadDescription::LinkDownload;
    if (attribute(QLatin1String("downloadway") + num) == QLatin1String("0")) {
        downloadType = Attica::DownloadDescription::FileDownload;
    } else if (attribute(QLatin1String("downloadway") + num) == QLatin1String("1")) {
        downloadType = Attica::DownloadDescription::LinkDownload;
    } else if (attribute(QLatin1String("downloadway") + num) == QLatin1String("2")) {
        downloadType = Attica::DownloadDescription::PackageDownload;
    }
    desc.setType(downloadType);
    desc.setId(number);
    desc.setName(attribute(QLatin1String("downloadname") + num));
    desc.setDistributionType(attribute(QLatin1String("downloadtype") + num));
    desc.setHasPrice(attribute(QLatin1String("downloadbuy") + num) == QLatin1String("1"));
    desc.setLink(attribute(QLatin1String("downloadlink") + num));
    desc.setPriceReason(attribute(QLatin1String("downloadreason") + num));
    desc.setPriceAmount(attribute(QLatin1String("downloadprice") + num));
    desc.setSize(attribute(QLatin1String("downloadsize") + num).toUInt());
    desc.setGpgFingerprint(attribute(QLatin1String("downloadgpgfingerprint") + num));
    desc.setGpgSignature(attribute(QLatin1String("downloadgpgsignature") + num));
    desc.setPackageName(attribute(QLatin1String("downloadpackagename") + num));
    desc.setRepository(attribute(QLatin1String("downloadrepository") + num));
    desc.setTags(attribute(QLatin1String("downloadtags") + num).split(QLatin1Char(',')));
    return desc;
}

QList<HomePageEntry> Attica::Content::homePageEntries()
{
    QList<Attica::HomePageEntry> homepages;
    QMap<QString, QString>::const_iterator iter = d->m_extendedAttributes.constBegin();
    while (iter != d->m_extendedAttributes.constEnd()) {
        QString key = iter.key();
        if (key.startsWith(QLatin1String("homepagetype"))) {
            bool ok;
            // remove "homepage", get the rest as number
            int num = key.rightRef(key.size() - 12).toInt(&ok);
            if (ok) {
                // check if the homepage actually has a valid type
                if (!iter.value().isEmpty()) {
                    homepages.append(homePageEntry(num));
                }
            }
        }
        ++iter;
    }

    return homepages;
}

Attica::HomePageEntry Attica::Content::homePageEntry(int number) const
{
    QString num(QString::number(number));
    HomePageEntry homepage;

    if (number == 1 && attribute(QLatin1String("homepage1")).isEmpty()) {
        num.clear();
    }
    homepage.setType(attribute(QLatin1String("homepagetype") + num));
    homepage.setUrl(QUrl(attribute(QLatin1String("homepage") + num)));
    return homepage;
}

QString Attica::Content::version() const
{
    return attribute(QLatin1String("version"));
}

QString Attica::Content::author() const
{
    return attribute(QLatin1String("personid"));
}

QString Attica::Content::license() const
{
    return attribute(QLatin1String("licensetype"));
}

QString Attica::Content::licenseName() const
{
    return attribute(QLatin1String("license"));
}

QString Attica::Content::previewPicture(const QString &number) const
{
    return attribute(QLatin1String("previewpic") + number);
}

QString Attica::Content::smallPreviewPicture(const QString &number) const
{
    return attribute(QLatin1String("smallpreviewpic") + number);
}

QList<Icon> Attica::Content::icons()
{
    return d->m_icons;
}

QList<Icon> Attica::Content::icons() const
{
    return d->m_icons;
}

void Attica::Content::setIcons(QList<Icon> icons)
{
    d->m_icons = icons;
}

QList<QUrl> Attica::Content::videos()
{
    return d->m_videos;
}

void Attica::Content::setVideos(QList<QUrl> videos)
{
    d->m_videos = videos;
}

QStringList Attica::Content::tags() const
{
    return d->m_tags;
}

void Attica::Content::setTags(const QStringList &tags)
{
    d->m_tags = tags;
}
