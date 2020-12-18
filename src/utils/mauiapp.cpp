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
#include "fmh.h"
#include "handy.h"
#include "utils.h"

#ifdef COMPONENT_ACCOUNTS
#include "mauiaccounts.h"
#endif

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include <KConfig>
#include <KConfigGroup>
#include <KSharedConfig>
#include <QFileSystemWatcher>
#endif

#if defined Q_OS_ANDROID || defined Q_OS_MACOS || defined Q_OS_WIN
#include <QIcon>
#include <QQuickStyle>
#endif

#include "../mauikit_version.h"

static const QUrl CONF_FILE = FMH::ConfigPath + "/kwinrc";

MauiApp * MauiApp::m_instance = nullptr;

MauiApp::MauiApp()
    : QObject(nullptr)
#ifdef COMPONENT_ACCOUNTS
    , m_accounts(MauiAccounts::instance())
#else
    , m_accounts(nullptr)
#endif
{
    this->setEnableCSD(UTIL::loadSettings("CSD", "GLOBAL", m_enableCSD, true).toBool());

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    auto configWatcher = new QFileSystemWatcher({CONF_FILE.toLocalFile()}, this);
    connect(configWatcher, &QFileSystemWatcher::fileChanged, [&](QString) { getWindowControlsSettings(); });
#endif

    connect(qApp, &QCoreApplication::aboutToQuit, this, &MauiApp::deleteLater);

    getWindowControlsSettings();

#if defined Q_OS_ANDROID || defined Q_OS_MACOS || defined Q_OS_WIN
    setDefaultMauiStyle();
#endif
}

QString MauiApp::getMauikitVersion()
{
    return MAUIKIT_VERSION_STRING;
}

QString MauiApp::getQtVersion()
{
    return QT_VERSION_STR;
}

QString MauiApp::getIconName() const
{
    qDebug() << "REQUESTING ICONNAME" << m_iconName << this;
    return m_iconName;
}

void MauiApp::setIconName(const QString &value)
{
    if (m_iconName == value)
        return;

    m_iconName = value;
    emit this->iconNameChanged();
}

QString MauiApp::getDonationPage() const
{
    return m_donationPage;
}

void MauiApp::setDonationPage(const QString &value)
{
    if (m_donationPage == value)
        return;

    m_donationPage = value;
    emit this->donationPageChanged();
}

bool MauiApp::getHandleAccounts() const
{
    return this->handleAccounts;
}

void MauiApp::setHandleAccounts(const bool &value)
{
#ifdef COMPONENT_ACCOUNTS
    if (this->handleAccounts == value)
        return;

    this->handleAccounts = value;
    emit this->handleAccountsChanged();
#endif
}

#ifdef COMPONENT_ACCOUNTS
MauiAccounts *MauiApp::getAccounts() const
{
    return this->m_accounts;
}
#endif

void MauiApp::setDefaultMauiStyle()
{
#if defined QICON_H && defined QQUICKSTYLE_H
    QIcon::setThemeSearchPaths({":/icons/luv-icon-theme"});
    QIcon::setThemeName("Luv");
    QQuickStyle::setStyle("maui-style");
#endif
}

MauiApp *MauiApp::qmlAttachedProperties(QObject *object)
{
    Q_UNUSED(object)
    return MauiApp::instance();
}

void MauiApp::notify(const QString &icon, const QString &title, const QString &body, const QJSValue &callback, const int &timeout, const QString &buttonText)
{
    emit this->sendNotification(icon, title, body, callback, timeout, buttonText);
}

bool MauiApp::enableCSD() const
{
    return m_enableCSD;
}

void MauiApp::setEnableCSD(const bool &value)
{
#if defined Q_OS_ANDROID || defined Q_OS_IOS // ignore csd for those
    return;
#else
    
    if (qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE")) 
    {
        if(QByteArrayList{"1", "true"}.contains(qgetenv("QT_QUICK_CONTROLS_MOBILE")))
            return;
    } 

    if (m_enableCSD == value)
        return;

    m_enableCSD = value;
    // 	UTIL::saveSettings("CSD", m_enableCSD, "GLOBAL");
    emit enableCSDChanged();

    if (m_enableCSD) {
        getWindowControlsSettings();
    }
#endif
}

void MauiApp::getWindowControlsSettings()
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID

    auto kconf = KSharedConfig::openConfig("kwinrc");
    const auto group = kconf->group("org.kde.kdecoration2");

    if (group.hasKey("ButtonsOnLeft")) {
        m_leftWindowControls = group.readEntry("ButtonsOnLeft", "").split("", Qt::SkipEmptyParts);
        emit this->leftWindowControlsChanged();
    }

    if (group.hasKey("ButtonsOnRight")) {
        m_rightWindowControls = group.readEntry("ButtonsOnRight", "").split("", Qt::SkipEmptyParts);
        emit this->rightWindowControlsChanged();
    }

#elif defined Q_OS_MACOS || defined Q_OS_ANDROID
    m_leftWindowControls = QStringList {"X", "I", "A"};
    emit this->leftWindowControlsChanged();

#elif defined Q_OS_WIN32
    m_rightWindowControls = QStringList {"I", "A", "X"};
    emit this->rightWindowControlsChanged();
#endif
}
