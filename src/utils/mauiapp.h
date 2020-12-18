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

#ifndef MAUIAPP_H
#define MAUIAPP_H
#include <QObject>
#include <QQmlEngine>

#include "fmh.h"

#include "mauikit_export.h"

#include <QColor>
#include <QSettings>

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include <KAboutData>
#elif defined Q_OS_WIN
#include <KF5/KCoreAddons/KAboutData>
#else
#include <KCoreAddons/KAboutData>
#endif

class MauiAccounts;

/**
 * @brief The MauiApp class
 * The MauiApp is a global instance and is declared to QML as an attached property, so it can be used widely by importing the org.kde.maui namespace
 * Example:
 * import org.kde.mauikit 1.2 as Maui
 *
 * Maui.ApplicationWindow
 * {
 *      title: Maui.App.name
 * }
 */

class MAUIKIT_EXPORT MauiApp : public QObject
{
    Q_OBJECT
    Q_PROPERTY(KAboutData about READ getAbout CONSTANT FINAL)
    Q_PROPERTY(QString iconName READ getIconName WRITE setIconName NOTIFY iconNameChanged)   
    Q_PROPERTY(QString donationPage READ getDonationPage WRITE setDonationPage NOTIFY donationPageChanged)

    Q_PROPERTY(QString mauikitVersion READ getMauikitVersion CONSTANT FINAL)
    Q_PROPERTY(QString qtVersion READ getQtVersion CONSTANT FINAL)
    Q_PROPERTY(bool handleAccounts READ getHandleAccounts WRITE setHandleAccounts NOTIFY handleAccountsChanged)
#ifdef COMPONENT_ACCOUNTS
    Q_PROPERTY(MauiAccounts *accounts READ getAccounts CONSTANT FINAL)
#endif

    // CSD support
    Q_PROPERTY(bool enableCSD READ enableCSD WRITE setEnableCSD NOTIFY enableCSDChanged)
    Q_PROPERTY(QStringList leftWindowControls MEMBER m_leftWindowControls NOTIFY leftWindowControlsChanged FINAL)
    Q_PROPERTY(QStringList rightWindowControls MEMBER m_rightWindowControls NOTIFY rightWindowControlsChanged FINAL)

public:
    static MauiApp *qmlAttachedProperties(QObject *object);

    static MauiApp *instance()
    {
        if(m_instance)
            return m_instance;

        m_instance = new MauiApp;
        return m_instance;
    }

    MauiApp(const MauiApp &) = delete;
    MauiApp &operator=(const MauiApp &) = delete;
    MauiApp(MauiApp &&) = delete;
    MauiApp &operator=(MauiApp &&) = delete;

    /**
     * @brief getMauikitVersion
     * MauiKit string version
     * @return
     */
    static QString getMauikitVersion();

    /**
     * @brief getQtVersion
     * Qt string version
     * @return
     */
    static QString getQtVersion();

      /**
     * @brief getIconName
     * Application icon name as a URL to the image asset
     * @return
     */
    QString getIconName() const;

    /**
     * @brief setIconName
     * Set URL to the image asset to be set as the application icon
     * @param value
     */
    void setIconName(const QString &value);

    /**
     * @brief getDonationPage
     * Application donation web page link
     * @return
     */
    QString getDonationPage() const;

    /**
     * @brief setDonationPage
     * Set application web page link
     * @param value
     */
    void setDonationPage(const QString &value);

    /**
     * @brief getHandleAccounts
     * If the application is meant to support online accounts
     * @return
     * True if the application supports online account
     */
    bool getHandleAccounts() const;

    /**
     * @brief setHandleAccounts
     * Set if the application is meant to support online accounts, if it supports online accounts a list of avaliable accounts is shown in the main application menu
     * @param value
     */
    void setHandleAccounts(const bool &value);

    /**
     * @brief getCredits
     * Returns a model of the credits represented as a QVariantList, some of the fields used are: name, email, year.
     * @return
     */
    KAboutData getAbout() const
    {
        return KAboutData::applicationData();
    }

    /**
     * @brief enableCSD
     * If the apps supports CSD (client side decorations) the window controls are drawn within the app main header, following the system buttons order, and allows to drag to move windows and resizing.
     * @return
     * If the application has been marked manually to use CSD or if in the mauiproject.conf file the CSD field has been set
     */
    bool enableCSD() const;

    /**
     * @brief setEnableCSD
     * Manually enable CSD for this single application ignoreing the system wide mauiproject.conf CSD field value
     * @param value
     */
    void setEnableCSD(const bool &value);

#ifdef COMPONENT_ACCOUNTS
    /**
     * @brief getAccounts
     * Model of the avaliable accounts in the system. This feature can be skipped on building time making use of the variable COMPONENT_ACCOUNTS, if such variable has been set to false then this method doesn't exists.
     * @return
     */
    MauiAccounts *getAccounts() const;
#endif

    static void setDefaultMauiStyle();

private:
    static MauiApp*m_instance;
    MauiApp();
    MauiAccounts *m_accounts;

    QString m_iconName;
    QString m_donationPage;

    // CSD support
    bool m_enableCSD = false;
    QStringList m_leftWindowControls;
    QStringList m_rightWindowControls;

    void getWindowControlsSettings();
    bool handleAccounts = false;

signals:
    void iconNameChanged();
    void donationPageChanged();
    void handleAccountsChanged();
    void sendNotification(QString iconName, QString title, QString body, QJSValue callback, int timeout, QString buttonText);

    // CSD support
    void enableCSDChanged();
    void leftWindowControlsChanged();
    void rightWindowControlsChanged();

public slots:
    void notify(const QString &icon = "emblem-warning", const QString &title = "Oops", const QString &body = "Something needs your attention", const QJSValue &callback = {}, const int &timeout = 2500, const QString &buttonText = "Ok");
};

QML_DECLARE_TYPEINFO(MauiApp, QML_HAS_ATTACHED_PROPERTIES)

#endif // MAUIAPP_H
