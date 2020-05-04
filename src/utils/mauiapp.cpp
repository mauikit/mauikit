/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  camilo <chiguitar@unal.edu.co>
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

#include "mauiapp.h"
#include "utils.h"
#include <QIcon>
#include "fmh.h"
#include "handy.h"
#ifdef COMPONENT_ACCOUNTS
#include "mauiaccounts.h"
#endif

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include <KConfig>
#include <KSharedConfig>
#include <KConfigGroup>
#include <QFileSystemWatcher>
#endif

#ifndef STATIC_MAUIKIT
#include "../mauikit_version.h"
#endif

static const QUrl CONF_FILE = FMH::ConfigPath + "/kwinrc";

MauiApp::MauiApp() : QObject(nullptr)
  #ifdef COMPONENT_ACCOUNTS
  , m_accounts(MauiAccounts::instance())
  #else
  , m_accounts(nullptr)
  #endif
{
	m_theme.path = QUrl::fromLocalFile(QStandardPaths::locate(QStandardPaths::GenericDataLocation, QString("/maui/csd/%1").arg("Nitrux"), QStandardPaths::LocateDirectory));

    this->setEnableCSD(UTIL::loadSettings("CSD", "GLOBAL", m_enableCSD, true).toBool());

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID    
	auto configWatcher = new QFileSystemWatcher({CONF_FILE.toLocalFile()}, this);
	connect(configWatcher, &QFileSystemWatcher::fileChanged, [&](QString)
	{
		getWindowControlsSettings();
	});
#endif
    
    getWindowControlsSettings();    
}

QString MauiApp::getName()
{
	return qApp->applicationName();
}

QString MauiApp::getDisplayName()
{
	return qApp->applicationDisplayName();
}

QString MauiApp::getVersion()
{
	return  qApp->applicationVersion();
}

QString MauiApp::getOrg()
{
	return qApp->organizationName();
}

QString MauiApp::getDomain()
{
	return qApp->organizationDomain();
}

QString MauiApp::getMauikitVersion()
{
    return MAUIKIT_VERSION_STRING;
}

QString MauiApp::getQtVersion()
{
	return Handy::appInfo().value("qt_version").toString();
}

QString MauiApp::getDescription() const
{
	return description;
}

void MauiApp::setDescription(const QString &value)
{
	if(description == value)
		return;

	description = value;
	emit this->descriptionChanged(description);
}

QString MauiApp::getIconName() const
{
	return iconName;
}

void MauiApp::setIconName(const QString &value)
{
	if(iconName == value)
		return;

	iconName = value;
	emit this->iconNameChanged(iconName);
}

QString MauiApp::getWebPage() const
{
	return webPage;
}

void MauiApp::setWebPage(const QString &value)
{
	if(webPage == value)
		return;

	webPage = value;
	emit this->webPageChanged(webPage);
}

QString MauiApp::getDonationPage() const
{
	return donationPage;
}

void MauiApp::setDonationPage(const QString &value)
{
	if(donationPage == value)
		return;

	donationPage = value;
	emit this->donationPageChanged(donationPage);
}

QString MauiApp::getReportPage() const
{
	return reportPage;
}

void MauiApp::setReportPage(const QString &value)
{
	if(reportPage == value)
		return;

	reportPage = value;
	emit this->reportPageChanged(reportPage);
}

bool MauiApp::getHandleAccounts() const
{
	return this->handleAccounts;
}

void MauiApp::setHandleAccounts(const bool &value)
{
#ifdef COMPONENT_ACCOUNTS
	if(this->handleAccounts == value)
		return;

	this->handleAccounts = value;
	emit this->handleAccountsChanged();
#endif
}

#ifdef COMPONENT_ACCOUNTS
MauiAccounts * MauiApp::getAccounts() const
{
	return this->m_accounts;
}
#endif

MauiApp * MauiApp::qmlAttachedProperties(QObject* object)
{
	Q_UNUSED(object)
	return MauiApp::instance();
}

void MauiApp::notify(const QString &icon, const QString& title, const QString& body, const QJSValue& callback, const int& timeout, const QString& buttonText)
{
	emit this->sendNotification(icon, title, body, callback, timeout, buttonText);
}

bool MauiApp::enableCSD() const
{
	return m_enableCSD;
}

void MauiApp::setEnableCSD(const bool& value)
{
#if defined Q_OS_ANDROID || defined Q_OS_IOS // ignore csd for those
    return;
#else

	if(m_enableCSD == value)
		return;

	m_enableCSD = value;
// 	UTIL::saveSettings("CSD", m_enableCSD, "GLOBAL");
	emit enableCSDChanged();

	if(m_enableCSD)
	{
		getWindowControlsSettings();
	}
#endif
}

void MauiApp::getWindowControlsSettings()
{
	#if defined Q_OS_LINUX && !defined Q_OS_ANDROID

	auto kconf = KSharedConfig::openConfig("kwinrc");
	const auto group = kconf->group("org.kde.kdecoration2");

	if( group.hasKey("ButtonsOnLeft"))
	{
		m_leftWindowControls = group.readEntry("ButtonsOnLeft", "").split("", QString::SkipEmptyParts);
		emit this->leftWindowControlsChanged();
	}

	if( group.hasKey("ButtonsOnRight"))
	{
		m_rightWindowControls = group.readEntry("ButtonsOnRight", "").split("", QString::SkipEmptyParts);
		emit this->rightWindowControlsChanged();
	}

	/*if( group.hasKey("Theme"))
	{
		const auto path = QUrl(FMH::DataPath+"/maui/csd/Default");
		if(FMH::fileExists(path))
		{
			m_theme.path = path;
		}
	}*/

// 	m_theme.path = QUrl(FMH::DataPath+"/maui/csd/Default");


    #elif defined Q_OS_MACOS || defined Q_OS_ANDROID
	m_leftWindowControls = QStringList{"X","I","A"};
	emit this->leftWindowControlsChanged();
    
    #elif defined  Q_OS_WIN32
    m_rightWindowControls = QStringList{"I","A","X"};
    emit this->rightWindowControlsChanged();
	#endif
}







