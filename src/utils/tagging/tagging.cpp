#include "tagging.h"
#include <QMimeDatabase>
#include <QNetworkInterface>

Tagging::Tagging(const QString &app, const QString &version, const QString &uri, const QString &comment, QObject *parent) : TAGDB(parent)
{
    this->setApp(app, uri, version, comment);
}

Tagging::~Tagging() {}

Tagging *Tagging::instance = nullptr;
Tagging *Tagging::getInstance(const QString &app, const QString &version, const QString &uri, const QString &comment)
{
    if(!instance)
    {
        instance = new Tagging(app, version, uri, comment);
        qDebug() << "getInstance(): First instance\n";
        return instance;
    } else
    {
        qDebug()<< "getInstance(): previous instance\n";
        return instance;
    }
}

Tagging *Tagging::getInstance()
{
    return instance;
}

QVariantList Tagging::get(const QString &queryTxt)
{
    QVariantList mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            QVariantMap data;
            for(auto key : TAG::KEYMAP.keys())
                if(query.record().indexOf(TAG::KEYMAP[key]) > -1)
                    data[TAG::KEYMAP[key]] = query.value(TAG::KEYMAP[key]).toString();

            mapList<< data;

        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

bool Tagging::tagExists(const QString &tag, const bool &strict)
{
    return !strict ? this->checkExistance(TAG::TABLEMAP[TAG::TABLE::TAGS], TAG::KEYMAP[TAG::KEY::TAG], tag) :
            this->checkExistance(QString("select t.tag from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac "
            "where au.app = '%1' and au.uri = '%2' and t.tag = '%3'").arg(this->application, this->uri, tag));
}


void Tagging::setApp(const QString &app, const QString &uri, const QString &version, const QString &comment)
{
    this->application = app;
    this->version = version;
    this->comment = comment;
    this->uri = uri;
    this->app();
}

bool Tagging::tag(const QString &tag, const QString &color, const QString &comment)
{
    if(tag.isEmpty()) return false;

    QVariantMap tag_map
    {
        {TAG::KEYMAP[TAG::KEY::TAG], tag},
        {TAG::KEYMAP[TAG::KEY::COLOR], color},
        {TAG::KEYMAP[TAG::KEY::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEY::COMMENT], comment},
    };

    this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS], tag_map);

    QVariantMap tag_user_map
    {
        {TAG::KEYMAP[TAG::KEY::TAG], tag},
        {TAG::KEYMAP[TAG::KEY::MAC], this->id()}
    };

    if(this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_USERS], tag_user_map))
    {
        emit this->tagged(tag);
        return true;
    }

    return false;
}

bool Tagging::tagUrl(const QString &url, const QString &tag, const QString &color, const QString &comment)
{
    auto myTag = tag.trimmed();

    this->tag(myTag, color, comment);

    QMimeDatabase mimedb;
    auto mime = mimedb.mimeTypeForFile(url);

    QVariantMap tag_url_map
    {
        {TAG::KEYMAP[TAG::KEY::URL], url},
        {TAG::KEYMAP[TAG::KEY::TAG], myTag},
        {TAG::KEYMAP[TAG::KEY::TITLE], QFileInfo(url).baseName()},
        {TAG::KEYMAP[TAG::KEY::MIME], mime.name()},
        {TAG::KEYMAP[TAG::KEY::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEY::COMMENT], comment}
    };

    emit this->urlTagged(url, myTag);
    return this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], tag_url_map);
}

bool Tagging::tagAbstract(const QString &tag, const QString &key, const QString &lot, const QString &color, const QString &comment)
{
    this->abstract(key, lot, comment);
    this->tag(tag, color, comment);

    QVariantMap tag_abstract_map
    {
        {TAG::KEYMAP[TAG::KEY::APP], this->application},
        {TAG::KEYMAP[TAG::KEY::URI], this->uri},
        {TAG::KEYMAP[TAG::KEY::TAG], tag},
        {TAG::KEYMAP[TAG::KEY::KEY], key},
        {TAG::KEYMAP[TAG::KEY::LOT], lot},
        {TAG::KEYMAP[TAG::KEY::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEY::COMMENT], comment},
    };

    emit this->abstractTagged(key, lot, tag);
    return this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_ABSTRACT], tag_abstract_map);
}

bool Tagging::updateUrlTags(const QString &url, const QStringList &tags)
{
    this->removeUrlTags(url);
    for(auto tag : tags)
        this->tagUrl(url, tag);
    
    return true;
}

QVariantList Tagging::getUrlsTags(const bool &strict)
{
    auto query = QString("select distinct t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag "
                         "inner join APPS_USERS au on au.mac = tu.mac "
                         "inner join TAGS_URLS turl on turl.tag = t.tag "
                         "where au.app = '%1' and au.uri = '%2'").arg(this->application, this->uri);

    qDebug()<<"URL TAGS QUEY"<<query;

    auto res = !strict ? this->get("select distinct t.* from tags t inner join TAGS_URLS turl on turl.tag = t.tag") :
                         this->get(query);
    return res;
}

QVariantList Tagging::getAbstractsTags(const bool &strict)
{
    auto res = !strict ? this->get("select t.* from tags t inner join TAGS_ABSTRACT tab on tab.tag = t.tag") :
                         this->get(QString("select t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag "
                                           "inner join APPS_USERS au on au.mac = tu.mac "
                                           "inner join TAGS_ABSTRACT tab on tab.tag = t.tag "
                                           "where au.app = '%1' and au.uri = '%2'").arg(this->application, this->uri));
    return res;
}

QVariantList Tagging::getAllTags(const bool &strict)
{
    auto res = !strict ? this->get("select * from tags") :
                         this->get(QString("select t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac "
                                           "where au.app = '%1' and au.uri = '%2'").arg(this->application, this->uri));
    return res;
}

QVariantList Tagging::getUrls(const QString &tag, const bool &strict)
{
    auto res =  !strict ? this->get(QString("select turl.*, t.color, t.comment as tagComment from TAGS t inner join TAGS_URLS turl on turl.tag = t.tag where t.tag = '%1'").arg(tag)):
                          this->get(QString("select distinct turl.*, t.color, t.comment as tagComment from TAGS t "
                                            "inner join TAGS_USERS tu on t.tag = tu.tag "
                                            "inner join APPS_USERS au on au.mac = tu.mac "
                                            "inner join TAGS_URLS turl on turl.tag = t.tag "
                                            "where au.app = '%1' and au.uri = '%2' "
                                            "and t.tag = '%3'").arg(this->application, this->uri, tag));
    return res;
}

QVariantList Tagging::getUrlTags(const QString &url, const bool &strict)
{

    auto res = !strict ? this->get(QString("select turl.*, t.color, t.comment as tagComment from tags t inner join TAGS_URLS turl on turl.tag = t.tag where turl.url  = '%1'").arg(url)) :
                         this->get(QString("select distinct t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac inner join TAGS_URLS turl on turl.tag = t.tag "
                                           "where au.app = '%1' and au.uri = '%2' and turl.url = '%3'").arg(this->application, this->uri, url));
    return res;
}

QVariantList Tagging::getAbstractTags(const QString &key, const QString &lot, const bool &strict)
{
    auto res = !strict ? this->get(QString("select t.* from TAGS t inner join TAGS_ABSTRACT ta on ta.tag = t.tag where ta.key = '%1' and ta.lot = '%2'").arg(key, lot)) :
                         this->get(QString("select distinct t.*  from TAGS t inner join TAGS_ABSTRACT ta on ta.tag = t.tag "
                                           "inner join TAGS_USERS tu on t.tag = tu.tag "
                                           "inner join APPS_USERS au on au.mac = tu.mac "
                                           "where au.app = '%1' and au.uri = '%2' and ta.key = '%3' and ta.lot = '%4'").arg(this->application, this->uri, key, lot));
    return res;
}

bool Tagging::removeUrlTags(const QString &url)
{
    for(auto map : this->getUrlTags(url))
    {
        auto tag = map.toMap().value(TAG::KEYMAP[TAG::KEY::TAG]).toString();

        TAG::DB data {{TAG::KEY::URL, url}, {TAG::KEY::TAG, tag}};
        this->remove(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], data);
    }

    return true;
}

QString Tagging::mac()
{
    QNetworkInterface mac;
    qDebug()<< "MAC ADDRES:"<< mac.hardwareAddress();
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
    qDebug()<<"REGISTER APP" << this->application<< this->uri<< this->version<< this->comment;
    QVariantMap app_map
    {
        {TAG::KEYMAP[TAG::KEY::APP], this->application},
        {TAG::KEYMAP[TAG::KEY::URI], this->uri},
        {TAG::KEYMAP[TAG::KEY::VERSION], this->version},
        {TAG::KEYMAP[TAG::KEY::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEY::COMMENT], this->comment},
    };

    this->insert(TAG::TABLEMAP[TAG::TABLE::APPS], app_map);

    this->user();

    QVariantMap users_apps_map
    {
        {TAG::KEYMAP[TAG::KEY::APP], this->application},
        {TAG::KEYMAP[TAG::KEY::URI], this->uri},
        {TAG::KEYMAP[TAG::KEY::MAC], this->id()},
        {TAG::KEYMAP[TAG::KEY::ADD_DATE], QDateTime::currentDateTime()},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::APPS_USERS], users_apps_map);

}

bool Tagging::user()
{
    QVariantMap user_map
    {
        {TAG::KEYMAP[TAG::KEY::MAC], this->id()},
        {TAG::KEYMAP[TAG::KEY::NAME], UTIL::whoami()},
        {TAG::KEYMAP[TAG::KEY::LAST_SYNC], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEY::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEY::DEVICE], this->device()},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::USERS], user_map);
}

bool Tagging::abstract(const QString &key, const QString &lot, const QString &comment)
{
    QVariantMap abstract_map
    {
        {TAG::KEYMAP[TAG::KEY::APP], this->application},
        {TAG::KEYMAP[TAG::KEY::URI], this->uri},
        {TAG::KEYMAP[TAG::KEY::KEY], key},
        {TAG::KEYMAP[TAG::KEY::LOT], lot},
        {TAG::KEYMAP[TAG::KEY::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEY::COMMENT], comment},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::ABSTRACT], abstract_map);
}


