/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2018  camilo <email>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "store.h"
#include "fmh.h"
#include <QFile>


Store::Store(QObject *parent) : QObject(parent)
{	
	qDebug()<< "Setting up Store backend";
	
	if(!FMH::fileExists(FMH::DataPath+"/Store/providers.xml"))
	{
		QDir store_dir(FMH::DataPath+"/Store/");
		if (!store_dir.exists())
			store_dir.mkpath(".");
		
		QFile providersFile(":/store/providers.xml");
		providersFile.copy(FMH::DataPath+"/Store/providers.xml");
		
	}
	connect(&m_manager, SIGNAL(defaultProvidersLoaded()), SLOT(providersChanged()));
// 	qDebug()<< "provider local file exists?"<< FMH::fileExists(FMH::DataPath+"/Store/providers.xml");
	m_manager.addProviderFile(QUrl::fromLocalFile(FMH::DataPath+"/Store/providers.xml"));
	m_manager.addProviderFile(QUrl("https://autoconfig.kde.org/ocs/providers.xml"));
// 		m_manager.loadDefaultProviders();
}

Store::~Store()
{
}

void Store::setCategory(const STORE::CATEGORY_KEY& categoryKey)
{
	qDebug()<< "SETTING CATEGORY OFR STORE";
	this->m_category = categoryKey;
	this->listCategories();
}

void Store::searchFor(const STORE::CATEGORY_KEY& categoryKey, const QString &query, const int &limit)
{	
	this->query = query;
	this->limit = limit;	
	
	connect(this, &Store::categoryIDsReady, [this]()
	{
		Attica::Category::List categories;
		qDebug()<< "GOT THE CATEGORY IDS" << this->categoryID;
		
		for(auto key : this->categoryID.keys())
		{
			Attica::Category category;
			category.setId(this->categoryID[key]);
			category.setName(key);
			category.setDisplayName(key);
			categories << category;
			qDebug()<< category.name() << this->categoryID[key];
		}
		
		Attica::ListJob<Attica::Content> *job = this->m_provider.searchContents(categories, this->query, Attica::Provider::SortMode::Rating, 0, this->limit);
		
		connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(contentListResult(Attica::BaseJob*)));	
		job->start();
	});	
	
	this->setCategory(categoryKey);
}

void Store::contentListResult(Attica::BaseJob* j)
{
	qDebug() << "Content list job returned";
	
	FMH::MODEL_LIST list;
	
	if (j->metadata().error() == Attica::Metadata::NoError) 
	{
		Attica::ListJob<Attica::Content> *listJob = static_cast<Attica::ListJob<Attica::Content> *>(j);
		
		foreach (const Attica::Content &p, listJob->itemList()) 
		{
			const auto att = p.attributes();
			list << FMH::MODEL {
				{FMH::MODEL_KEY::ID, p.id()},
				{FMH::MODEL_KEY::URL, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::DOWNLOAD_LINK]]},
				{FMH::MODEL_KEY::THUMBNAIL, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::PREVIEW_SMALL_1]]},
				{FMH::MODEL_KEY::THUMBNAIL_1, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::PREVIEW_1]]},
				{FMH::MODEL_KEY::THUMBNAIL_2, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::PREVIEW_2]]},
				{FMH::MODEL_KEY::THUMBNAIL_3, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::DOWNLOAD_LINK]]},
				{FMH::MODEL_KEY::LABEL, p.name()},
				{FMH::MODEL_KEY::OWNER, p.author()},
				{FMH::MODEL_KEY::LICENSE, p.license()},
				{FMH::MODEL_KEY::DESCRIPTION, p.description()},
				{FMH::MODEL_KEY::RATE, QString::number(p.rating())},
				{FMH::MODEL_KEY::DATE, p.created().toString()},
				{FMH::MODEL_KEY::MODIFIED, p.updated().toString()},
				{FMH::MODEL_KEY::TAG, p.tags().join(",")}	
			}; 
		}
		
		emit this->contentReady(list);
		
		if (listJob->itemList().isEmpty())
		{
			emit this->warning(QLatin1String("No Content found."));
		}
		
	} else if (j->metadata().error() == Attica::Metadata::OcsError)
	{
		emit this->warning(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
		
	} else if (j->metadata().error() == Attica::Metadata::NetworkError)
	{
		emit this->warning(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
	} else
	{
		emit this->warning(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
	}
}

void Store::providersChanged()
{
	if (!m_manager.providers().isEmpty())
	{
		qDebug()<< "Providers names:";
		for(auto prov : m_manager.providers())
			qDebug() << prov.name() << prov.baseUrl();
		
		m_provider = m_manager.providerByUrl(QUrl(STORE::KDELOOK_API));
// 		m_provider = m_manager.providerByUrl(QUrl(STORE::OPENDESKTOP_API));
		
		if (!m_provider.isValid())
		{
			qDebug() << "Could not find opendesktop.org provider.";
			return;
			
		}else 
		{
			qDebug()<< "Found the Store provider for" << m_provider.name();
			qDebug()<< "Has content service" << m_provider.hasContentService(); 
			emit this->storeReady();
		}
		
	}else qDebug() << "Could not find any provider.";
	
}

void Store::categoryListResult(Attica::BaseJob* j)
{
     qDebug() << "Category list job returned";
    QString output = QLatin1String("<b>Categories:</b>");

    if (j->metadata().error() == Attica::Metadata::NoError) 
    {
        Attica::ListJob<Attica::Category> *listJob = static_cast<Attica::ListJob<Attica::Category> *>(j);
        qDebug() << "Yay, no errors ...";
        QStringList projectIds;

        foreach (const Attica::Category &p, listJob->itemList()) 
        {
            qDebug() << "New Category:" << p.id() << p.name();
			
			if(STORE::CATEGORIES[this->m_category].contains(p.name()))
				this->categoryID[p.name()] = p.id();			
			
            output.append(QString(QLatin1String("<br />%1 (%2)")).arg(p.name(), p.id()));
            projectIds << p.id();            
        }
        
        if (listJob->itemList().isEmpty())
        {
            output.append(QLatin1String("No Categories found."));
        }
        
    } else if (j->metadata().error() == Attica::Metadata::OcsError)
    {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
        
    } else if (j->metadata().error() == Attica::Metadata::NetworkError)
    {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else
    {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    
    qDebug()<< "CATEGORY IDS " << this->categoryID;
	emit this->categoryIDsReady();
	
}

void Store::getPersonInfo(const QString& nick)
{
	Attica::ItemJob<Attica::Person>* job = m_provider.requestPerson(nick);
	// connect that job
	connect(job, &Attica::BaseJob::finished, [](Attica::BaseJob* doneJob)
	{
		Attica::ItemJob<Attica::Person> *personJob = static_cast< Attica::ItemJob<Attica::Person> * >( doneJob );
		// check if the request actually worked
		if( personJob->metadata().error() == Attica::Metadata::NoError )
		{
			// use the data to fill the labels
			Attica::Person p(personJob->result());
			qDebug() << (p.firstName() + ' ' + p.lastName());
			qDebug() << p.city();
		} else
		{
			qDebug() << ("Could not fetch information.");
		}
		
	});
	// start the job
	job->start();
}

void Store::listProjects()
{
	Attica::ListJob<Attica::Project> *job = m_provider.requestProjects();
	connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(projectListResult(Attica::BaseJob*)));
	job->start();
}

void Store::listCategories()
{	
	Attica::ListJob<Attica::Category> *job = m_provider.requestCategories();
	connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(categoryListResult(Attica::BaseJob*)));
	job->start();          
}

void Store::projectListResult(Attica::BaseJob *j)
{
	qDebug() << "Project list job returned";
	QString output = QLatin1String("<b>Projects:</b>");
	
	if (j->metadata().error() == Attica::Metadata::NoError) 
	{
		Attica::ListJob<Attica::Project> *listJob = static_cast<Attica::ListJob<Attica::Project> *>(j);
		qDebug() << "Yay, no errors ...";
		QStringList projectIds;
		
		foreach (const Attica::Project &p, listJob->itemList()) 
		{
			qDebug() << "New project:" << p.id() << p.name();
			output.append(QString(QLatin1String("<br />%1 (%2)")).arg(p.name(), p.id()));
			projectIds << p.id();
			// TODO: start project jobs here
		}
		if (listJob->itemList().isEmpty())
		{
			output.append(QLatin1String("No Projects found."));
		}
	} else if (j->metadata().error() == Attica::Metadata::OcsError)
	{
		output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
	} else if (j->metadata().error() == Attica::Metadata::NetworkError) 
	{
		output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
	} else 
	{
		output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
	}
	qDebug() << output;
}

// #include "store.moc"
