#ifndef TAGSLIST_JH
#define TAGSLIST_JH

#include "fmh.h"
#include "tag.h"
#include <QObject>

#include "mauilist.h"

class Tagging;
class TagsList : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(bool abstract READ getAbstract WRITE setAbstract NOTIFY abstractChanged)
    Q_PROPERTY(bool strict READ getStrict WRITE setStrict NOTIFY strictChanged)
    Q_PROPERTY(QStringList urls READ getUrls WRITE setUrls NOTIFY urlsChanged)
    Q_PROPERTY(QStringList tags READ getTags NOTIFY tagsChanged)
    Q_PROPERTY(QString lot READ getLot WRITE setLot NOTIFY lotChanged)
    Q_PROPERTY(QString key READ getKey WRITE setKey NOTIFY keyChanged)

    Q_PROPERTY(TagsList::KEYS sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged())

public:
    enum KEYS : uint_fast8_t {
        URL = FMH::MODEL_KEY::URL,
        APP = FMH::MODEL_KEY::APP,
        URI = FMH::MODEL_KEY::URI,
        MAC = FMH::MODEL_KEY::MAC,
        LAST_SYNC = FMH::MODEL_KEY::LASTSYNC,
        NAME = FMH::MODEL_KEY::NAME,
        VERSION = FMH::MODEL_KEY::VERSION,
        LOT = FMH::MODEL_KEY::LOT,
        TAG = FMH::MODEL_KEY::TAG,
        COLOR = FMH::MODEL_KEY::COLOR,
        ADD_DATE = FMH::MODEL_KEY::ADDDATE,
        COMMENT = FMH::MODEL_KEY::COMMENT,
        MIME = FMH::MODEL_KEY::MIME,
        TITLE = FMH::MODEL_KEY::TITLE,
        DEVICE = FMH::MODEL_KEY::DEVICE,
        KEY = FMH::MODEL_KEY::KEY
    };
    Q_ENUM(KEYS)

    explicit TagsList(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override;

    TagsList::KEYS getSortBy() const;
    void setSortBy(const TagsList::KEYS &key);

    bool getAbstract() const;
    void setAbstract(const bool &value);

    bool getStrict() const;
    void setStrict(const bool &value);

    QStringList getUrls() const;
    void setUrls(const QStringList &value);

    QString getLot() const;
    void setLot(const QString &value);

    QString getKey() const;
    void setKey(const QString &value);

    QStringList getTags() const;

private:
    FMH::MODEL_LIST list;
    void setList();
    void sortList();
    Tagging *tag;

    bool abstract = false;
    bool strict = true;
    QStringList urls = QStringList();
    QString lot;
    QString key;
    TagsList::KEYS sortBy = TagsList::KEYS::ADD_DATE;

signals:
    void abstractChanged();
    void strictChanged();
    void urlsChanged();
    void lotChanged();
    void keyChanged();
    void sortByChanged();
    void tagsChanged();

public slots:
    QVariantMap get(const int &index) const;
    void append(const QString &tag);
    void append(const QStringList &tags);
    bool insert(const QString &tag);
    void insertToUrls(const QString &tag);
    void insertToAbstract(const QString &tag);
    void updateToUrls(const QStringList &tags);
    void updateToAbstract(const QStringList &tags);

    bool remove(const int &index);
    void removeFrom(const int &index, const QString &url);
    void removeFrom(const int &index, const QString &key, const QString &lot);

    void removeFromUrls(const int &index);
    void removeFromUrls(const QString &tag);
    void removeFromAbstract(const int &index);

    void erase(const int &index);
    void refresh();

    bool contains(const QString &tag);
    int indexOf(const QString &tag);
};

#endif // SYNCINGLIST_H
