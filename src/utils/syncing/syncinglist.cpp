#include "syncinglist.h"
#include "fm.h"

SyncingList::SyncingList(QObject *parent) : QObject(parent)
{
	this->fm = FM::getInstance();
	this->setList();
}

void SyncingList::setList()
{
    emit this->preListChanged();

    this->list = this->fm->getCloudAccounts();
	qDebug()<< "SYNCIGN LIST"<< list;

    emit this->postListChanged();
}

QVariantMap SyncingList::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    const auto folder = this->list.at(index);

    QVariantMap res;
    for(auto key : folder.keys())
        res.insert(FMH::MODEL_NAME[key], folder[key]);

    return res;
}

void SyncingList::refresh()
{
    this->setList();
}

void SyncingList::insert(const QVariantMap& data)
{	
	FMH::MODEL model;
	for(auto key : data.keys())
		model.insert(FMH::MODEL_NAME_KEY[key], data[key].toString());		
	
	if(this->fm->addCloudAccount(model[FMH::MODEL_KEY::SERVER], model[FMH::MODEL_KEY::USER], model[FMH::MODEL_KEY::PASSWORD]))
	{
		this->setList();
	}	
}

void SyncingList::remove(const int& index)
{	
	if(index >= this->list.size() || index < 0)
		return;
	
	//todo
}

FMH::MODEL_LIST SyncingList::items() const
{
	return this->list;
}

