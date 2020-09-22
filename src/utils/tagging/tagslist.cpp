#include "tagslist.h"
#include "tagging.h"

TagsList::TagsList(QObject *parent) : MauiList(parent)
{
    this->tag = Tagging::getInstance();

    connect(this->tag, &Tagging::tagged, [&](QString) { this->setList(); });

    this->setList();
}

void TagsList::setList()
{
    emit this->preListChanged();
    
    if (this->urls.isEmpty())
        this->list = FMH::toModelList(this->tag->getAllTags(this->strict));
    else {
        this->list.clear();
        this->list = std::accumulate(this->urls.constBegin(), this->urls.constEnd(), FMH::MODEL_LIST(), [&](FMH::MODEL_LIST &list, const QString &url) {
            list << FMH::toModelList(this->tag->getUrlTags(url, this->strict));
            return list;
        });
    }    

    emit this->tagsChanged();
    emit this->postListChanged();
}

QVariantMap TagsList::get(const int &index) const
{
    if (index >= this->list.size() || index < 0)
        return QVariantMap();

    const auto folder = this->list.at(index);
    const auto keys = folder.keys();
    return std::accumulate(keys.constBegin(), keys.constEnd(), QVariantMap(), [folder](QVariantMap &res, const FMH::MODEL_KEY &key) {
        res.insert(FMH::MODEL_NAME[key], folder[key]);
        return res;
    });
}

void TagsList::refresh()
{
    this->setList();
}

bool TagsList::contains(const QString &tag)
{
    return this->indexOf(tag) >= 0;
}

int TagsList::indexOf(const QString &tag)
{
    int i = 0;
    for (const auto &item : this->list) {
        if (item.value(FMH::MODEL_KEY::TAG) == tag)
            return i;
        i++;
    }

    return -1;
}

bool TagsList::insert(const QString &tag)
{
    if (this->tag->tag(tag.trimmed()))
        return true;

    return false;
}

void TagsList::insertToUrls(const QString &tag)
{
    if (this->urls.isEmpty())
        return;

    for (const auto &url : this->urls)
        this->tag->tagUrl(url, tag);

    this->refresh();
}

void TagsList::updateToUrls(const QStringList &tags)
{
    if (this->urls.isEmpty())
        return;

    for (const auto &url : this->urls)
        this->tag->updateUrlTags(url, tags);

    this->refresh();
}

void TagsList::removeFromUrls(const int &index)
{
    if (index >= this->list.size() || index < 0)
        return;

    if (this->urls.isEmpty())
        return;

    const auto tag = this->list[index][FMH::MODEL_KEY::TAG];
    for (const auto &url : this->urls)
        this->tag->removeUrlTag(url, tag);

    this->remove(index);
}

void TagsList::removeFromUrls(const QString &tag)
{
    const auto index = indexOf(tag);
    removeFromUrls(index);
}

bool TagsList::remove(const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    emit this->preItemRemoved(index);
    this->list.removeAt(index);
    emit this->tagsChanged();
    emit this->postItemRemoved();

    return true;
}

void TagsList::removeFrom(const int &index, const QString &url)
{
    if (index >= this->list.size() || index < 0)
        return;

    if (this->tag->removeUrlTag(url, this->list[index][FMH::MODEL_KEY::TAG]))
        this->remove(index);
}

void TagsList::erase(const int &index)
{
    Q_UNUSED(index)
}

FMH::MODEL_LIST TagsList::items() const
{
    return this->list;
}

bool TagsList::getStrict() const
{
    return this->strict;
}

void TagsList::setStrict(const bool &value)
{
    if (this->strict == value)
        return;

    this->strict = value;
    this->setList();
    emit this->strictChanged();
}

QStringList TagsList::getTags() const
{
    return std::accumulate(this->list.constBegin(), this->list.constEnd(), QStringList(), [](QStringList &tags, const FMH::MODEL &tag) {
        tags << tag[FMH::MODEL_KEY::TAG];
        return tags;
    });
}

QStringList TagsList::getUrls() const
{
    return this->urls;
}

void TagsList::setUrls(const QStringList &value)
{
    if (this->urls == value)
        return;

    this->urls = value;
    this->setList();
    emit this->urlsChanged();
}

void TagsList::append(const QString &tag)
{
    if (this->contains(tag))
        return;

    emit this->preItemAppended();
    this->list << FMH::MODEL {{FMH::MODEL_KEY::TAG, tag}};
    emit this->tagsChanged();
    emit this->postItemAppended();
}

void TagsList::append(const QStringList &tags)
{
    for (const auto &tag : tags)
        this->append(tag);
}
