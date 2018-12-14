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

Store::Store(QObject *parent) : QObject(parent)
{	
	qDebug()<< "Setting up Store backend";
	connect(&m_manager, SIGNAL(defaultProvidersLoaded()), SLOT(providersChanged()));
	// tell it to get the default Providers
	m_manager.addProviderFileToDefaultProviders(QUrl("qrc:/store/providers.xml"));
	m_manager.loadDefaultProviders();
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
			qDebug() << prov.name();
		
		m_provider = m_manager.providerByUrl(QUrl("https://api.opendesktop.org/v1/"));
		
		if (!m_provider.isValid())
		{
			qDebug() << "Could not find opendesktop.org provider.";
			return;
		}	
		
		qDebug()<< "Found the Store provider";
	}
}

// #include "store.moc"
