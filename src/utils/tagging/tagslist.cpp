#include "tagslist.h"
#include "tagging.h"

TagsList::TagsList(QObject *parent) : QObject(parent)
{
	this->tag = Tagging::getInstance();
	this->setList();
}

TAG::DB_LIST TagsList::toModel(const QVariantList& data)
{
	TAG::DB_LIST res;
	for(auto item : data)
	{
		const auto map = item.toMap();
		TAG::DB model;
		for(auto key : map.keys())
			model.insert(TAG::MAPKEY[key], map[key].toString());
		
		res << model;
	}
	
	return res;
}

void TagsList::setList()
{
	emit this->preListChanged();
	
	
	if(this->abstract)
	{
		if(this->lot.isEmpty() || this->key.isEmpty())			
			this->list = this->toModel(this->tag->getAbstractsTags(this->strict));
		else  
			this->list = this->toModel(this->tag->getAbstractTags(this->key, this->lot, this->strict));
		
	}else
	{
		if(this->urls.isEmpty())
			this->list = this->toModel(this->tag->getAllTags(this->strict));
		else
		{
			this->list.clear();
			for(auto url : this->urls)
				this->list << this->toModel(this->tag->getUrlTags(url, this->strict));
		}
	}
	
	qDebug()<< "TAGGING LIST"<< list;
	
	emit this->postListChanged();
}

QVariantMap TagsList::get(const int &index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	
	const auto folder = this->list.at(index);
	
	QVariantMap res;
	for(auto key : folder.keys())
		res.insert(TAG::KEYMAP[key], folder[key]);
	
	return res;
}

void TagsList::refresh()
{
	this->setList();
}

bool TagsList::insert(const QString &tag)
{	
	qDebug() << "trying to insert tag "<< tag;
	
	auto _tag = tag.trimmed();
	
	if(this->tag->tag(_tag))
	{
		emit this->preItemAppended();
		
		qDebug()<< "tag inserted";
		this->list << TAG::DB {{TAG::KEYS::TAG, _tag}};
		
		emit this->postItemAppended();
		return true;
	}
	
	return false;
}

bool TagsList::remove(const int& index)
{	
	if(index >= this->list.size() || index < 0)
		return false;
	
	emit this->preItemRemoved(index);
	this->list.removeAt(index);
	emit this->postItemRemoved();
	
	return true;
}

void TagsList::removeFrom(const int& index, const QString& key, const QString& lot)
{
	if(index >= this->list.size() || index < 0)
		return;
	
	emit this->preItemRemoved(index);
	auto item = this->list.takeAt(index);
	this->tag->removeAbstractTag(key, lot, item[TAG::KEYS::TAG]);
	emit this->postItemRemoved();
}

void TagsList::removeFrom(const int& index, const QString& url)
{
	if(index >= this->list.size() || index < 0)
			return;
		
		emit this->preItemRemoved(index);
	auto item = this->list.takeAt(index);
	this->tag->removeUrlTag(url, item[TAG::KEYS::TAG]);
	emit this->postItemRemoved();
}

void TagsList::erase(const int& index)
{
}

TAG::DB_LIST TagsList::items() const
{
	return this->list;
}

bool TagsList::getAbstract() const
{
	return this->abstract;
}

void TagsList::setAbstract(const bool& value)
{
	if(this->abstract == value)
		return;
	
	this->abstract = value;
	this->setList();
	emit this->abstractChanged();
}

bool TagsList::getStrict() const
{
	return this->strict;
}

void TagsList::setStrict(const bool& value)
{
	if(this->strict == value)
		return;
	
	this->strict = value;
	this->setList();
	emit this->strictChanged();
}

QString TagsList::getKey() const
{
	return this->key;
}

void TagsList::setKey(const QString& value)
{
	if(this->key == value)
		return;
	
	this->key = value;
	this->setList();
	emit this->keyChanged();
}

QString TagsList::getLot() const
{
	return this->lot;
}

void TagsList::setLot(const QString& value)
{
	if(this->lot == value)
		return;
	
	this->lot = value;
	this->setList();
	emit this->lotChanged();
}

QStringList TagsList::getUrls() const
{
	return this->urls;
}

void TagsList::setUrls(const QStringList& value)
{
	if(this->urls == value)
		return;
	
	this->urls = value;
	this->setList();
	emit this->urlsChanged();
}

void TagsList::append(const QString &tag)
{
	qDebug() << "trying to append tag "<< tag;	
	
	if(!this->insert(tag))
	{
		emit this->preItemAppended();
		this->list << TAG::DB {{TAG::KEYS::TAG, tag}};
		emit this->postItemAppended();
		qDebug() << "done appending tag "<< tag;	
		
	}
		
}
