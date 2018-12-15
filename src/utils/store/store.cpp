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
	// tell it to get the default Providers
	qDebug()<< "provider local file exists?"<< FMH::fileExists(FMH::DataPath+"/Store/providers.xml");
	m_manager.addProviderFile(QUrl::fromLocalFile(FMH::DataPath+"/Store/providers.xml"));
// 	m_manager.loadDefaultProviders();
}

Store::~Store()
{
}

void Store::searchFor(const QString& query)
{
}

void Store::providersChanged()
{
	if (!m_manager.providers().isEmpty())
	{
		qDebug()<< "Providers names:";
		for(auto prov : m_manager.providers())
			qDebug() << prov.name() << prov.baseUrl();
		
		m_provider = m_manager.providerByUrl(QUrl("https://api.opendesktop.org/v1/"));
		
		if (!m_provider.isValid())
		{
			qDebug() << "Could not find opendesktop.org provider.";
			return;
			
		}else 
		{
			qDebug()<< "Found the Store provider opendesktop";
			qDebug()<< "Has content service" << m_provider.hasContentService();
			
			Attica::ListJob<Attica::Category> *job = m_provider.requestCategories();
            
            connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(categoryListResult(Attica::BaseJob*)));
            job->start();
            
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
    qDebug() << output;
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

// #include "store.moc"
