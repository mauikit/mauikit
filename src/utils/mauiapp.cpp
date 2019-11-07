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

MauiApp::MauiApp(QObject *parent) : QObject(parent)
  #ifdef COMPONENT_ACCOUNTS
  , m_accounts(MauiAccounts::instance(this))
  #else
  , m_accounts(nullptr)
  #endif
{}

MauiApp::~MauiApp() {}

MauiApp * MauiApp::m_instance = nullptr;
MauiApp * MauiApp::instance()
{
    if(MauiApp::m_instance == nullptr)
        MauiApp::m_instance = new MauiApp();
    
    return MauiApp::m_instance;
}

QString MauiApp::getName()
{
    return Handy::appInfo().value("").toString();
}

QString MauiApp::getVersion()
{
    return Handy::appInfo().value("").toString();
}

QString MauiApp::getOrg()
{
    return Handy::appInfo().value("").toString();
}

QString MauiApp::getDomain()
{
    return Handy::appInfo().value("").toString();
}

QString MauiApp::getMauikitVersion()
{
    return Handy::appInfo().value("mauikit_version").toString();
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
     if(MauiApp::m_instance == nullptr)
        MauiApp::m_instance = new MauiApp(object);
    
    return MauiApp::m_instance;
}





