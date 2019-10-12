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

#ifdef COMPONENT_ACCOUNTS
#include "mauiaccounts.h"
#endif

MauiApp::MauiApp(QObject *parent) : QObject(parent)
  #ifdef COMPONENT_ACCOUNTS
  , m_accounts(new MauiAccounts(this))
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





