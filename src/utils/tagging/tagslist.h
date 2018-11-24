#ifndef TAGSLIST_JH
#define TAGSLIST_JH

#include <QObject>
#include "fmh.h"
#include "tag.h"

class Tagging;
class TagsList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool abstract READ getAbstract WRITE setAbstract NOTIFY abstractChanged)
	Q_PROPERTY(bool strict READ getStrict WRITE setStrict NOTIFY strictChanged)
	Q_PROPERTY(QStringList urls READ getUrls WRITE setUrls NOTIFY urlsChanged)
	Q_PROPERTY(QString lot READ getLot WRITE setLot NOTIFY lotChanged)
	Q_PROPERTY(QString key READ getKey WRITE setKey NOTIFY keyChanged)
	
	Q_PROPERTY(TAG::KEYS sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged())
	
 
public:   
	Q_ENUM(TAG::KEYS)
	
    explicit TagsList(QObject *parent = nullptr);
	TAG::DB_LIST items() const;
	
	TAG::KEYS getSortBy() const;
	void setSortBy(const TAG::KEYS &key);
	
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
	

private:
    TAG::DB_LIST list;
	void setList();
	void sortList();
	Tagging *tag;
	
	TAG::DB_LIST toModel(const QVariantList &data);
   
	bool abstract = false;
	bool strict = true;
	QStringList urls = QStringList();
	QString lot;
	QString key;
	TAG::KEYS sortBy = TAG::KEYS::ADD_DATE;
	
protected:

signals:
    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void updateModel(int index, QVector<int> roles);
    void preListChanged();
    void postListChanged();
	
	void abstractChanged();
	void strictChanged();
	void urlsChanged();
	void lotChanged();
	void keyChanged();
	void sortByChanged();

public slots:    
    QVariantMap get(const int &index) const;
	void append(const QString &tag);
	bool insert(const QString &tag);
	void insertToUrls(const QString &tag);
	void insertToAbstract(const QString &tag);
	void updateToUrls(const QStringList &tags);
	void updateToAbstract(const QStringList &tags);
	
	bool remove(const int &index);
	void removeFrom(const int &index, const QString &url);
	void removeFrom(const int &index, const QString &key, const QString &lot);
	
	void removeFromUrls(const int &index);
	void removeFromAbstract(const int &index);
	
	void erase(const int &index);
    void refresh();

};

#endif // SYNCINGLIST_H
