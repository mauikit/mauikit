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

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#include <QColor>
#include <QSettings>

/**
 * @brief The MauiTheme struct
 * This is a helpful struct if the application makes usage of CSD
 * It makes use of a config file names mauiproject.conf and the following fields.
 *
 */
struct MauiTheme {
    Q_GADGET
    Q_PROPERTY(int borderRadius READ getRadius CONSTANT FINAL)
    Q_PROPERTY(bool maskButtons READ getMaskButtons CONSTANT FINAL)

    static QUrl confFile(const QUrl &path)
    {
        const auto conf = QUrl(path.toString() + "/config.conf");
        qDebug() << "LOOKING FOR STYLE IMAGE" << conf;

        if (FMH::fileExists(conf)) {
            return conf;
        }

        return path;
    }

    QVariant getSettings(const QString &group, const QString &key, const QVariant &defaultValue) const
    {
        const auto conf = confFile(path);

        if (conf.isValid()) {
            QSettings settings(conf.toLocalFile(), QSettings::IniFormat);
            QVariant res;
            settings.setDefaultFormat(QSettings::IniFormat);
            settings.beginGroup(group);
            res = settings.value(key, defaultValue);
            settings.endGroup();

            return res;
        }

        return defaultValue;
    }

public:
    QUrl path;

    /**
     * @brief buttonAsset
     * @param key
     * @param state
     * @return
     */
    Q_INVOKABLE QUrl buttonAsset(const QString &key, const QString &state) const
    {
        auto res = getSettings(key, state, QString());

        if (!res.toString().isEmpty()) {
            auto imageUrl = QUrl(path.toString() + "/" + res.toString());
            if (FMH::fileExists(imageUrl)) {
                return imageUrl;
            }
        }

        return QUrl();
    }

    /**
     * @brief getRadius
     * Border radius
     * @return
     */
    int getRadius() const
    {
        auto res = getSettings("Decoration", "BorderRadius", 6);
        return res.toInt();
    }

    /**
     * @brief getMaskButtons
     * if the buttons should be colored following the system colorscheme or not
     * @return
     */
    bool getMaskButtons() const
    {
        auto res = getSettings("Decoration", "MaskButtons", true);
        return res.toBool();
    }
};
Q_DECLARE_METATYPE(MauiTheme)

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

#ifdef STATIC_MAUIKIT
class MauiApp : public QObject
#else
class MAUIKIT_EXPORT MauiApp : public QObject
#endif
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName CONSTANT FINAL)
    Q_PROPERTY(QString displayName READ getDisplayName CONSTANT FINAL)
    Q_PROPERTY(QString version READ getVersion CONSTANT FINAL)
    Q_PROPERTY(QString org READ getOrg CONSTANT FINAL)
    Q_PROPERTY(QString domain READ getDomain CONSTANT FINAL)

    Q_PROPERTY(QVariantList credits READ getCredits CONSTANT FINAL)

    Q_PROPERTY(QString iconName READ getIconName WRITE setIconName NOTIFY iconNameChanged)
    Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString webPage READ getWebPage WRITE setWebPage NOTIFY webPageChanged)
    Q_PROPERTY(QString reportPage READ getReportPage WRITE setReportPage NOTIFY reportPageChanged)
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

    // Theming and branding support
    Q_PROPERTY(MauiTheme theme READ theme NOTIFY themeChanged FINAL)

public:
    static MauiApp *qmlAttachedProperties(QObject *object);

    static MauiApp *instance()
    {
        static MauiApp app;
        return &app;
    }

    MauiApp(const MauiApp &) = delete;
    MauiApp &operator=(const MauiApp &) = delete;
    MauiApp(MauiApp &&) = delete;
    MauiApp &operator=(MauiApp &&) = delete;

    /**
     * @brief getName
     * Application name
     * @return
     */
    static QString getName();

    /**
     * @brief getDisplayName
     * Application display name, usually capitalized
     * @return
     */
    static QString getDisplayName();

    /**
     * @brief getVersion
     * Application version string
     * @return
     */
    static QString getVersion();

    /**
     * @brief getOrg
     * Name of the organization
     * @return
     */
    static QString getOrg();

    /**
     * @brief getDomain
     * Domain of the organization
     * @return
     */
    static QString getDomain();

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
     * @brief getDescription
     * Application short description
     * @return
     */
    QString getDescription() const;

    /**
     * @brief setDescription
     * Set application short description, this is display in the about dialog
     * @param value
     */
    void setDescription(const QString &value);

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
     * @brief getWebPage
     * Application official web page link
     * @return
     */
    QString getWebPage() const;

    /**
     * @brief setWebPage
     * Set application official web page link
     * @param value
     */
    void setWebPage(const QString &value);

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
     * @brief getReportPage
     * Application bug & issues report web page link
     * @return
     */
    QString getReportPage() const;

    /**
     * @brief setReportPage
     * Set bugs & issues report web page link
     * @param value
     */
    void setReportPage(const QString &value);

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
    QVariantList getCredits() const
    {
        return m_credits;
    }

    /**
     * @brief setCredits
     * Sets the credits for the application developers, designers, translators and other figures involved. The fields used in the about dialog are: name, email and year.
     * @param credits
     * Example:
     *     MauiApp::instance()->setCredits ({QVariantMap({{"name", "Camilo Higuita"}, {"email", "milo.h@aol.com"}, {"year", "2019-2020"}})});
     */
    void setCredits(const QVariantList &credits)
    {
        m_credits = credits;
    }

    /**
     * @brief theme
     * Structure that describes the style of a Maui Application that make suse of CSD (client side decorations), such as borderRadius, maskButtons, etc.
     * @return
     */
    MauiTheme theme()
    {
        return m_theme;
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

private:
    MauiApp();
    MauiAccounts *m_accounts;

    QString description;
    QString iconName;

    QString webPage;
    QString donationPage;
    QString reportPage;
    QVariantList m_credits;

    // Theming and branding support
    MauiTheme m_theme;

    // CSD support
    bool m_enableCSD = false;
    QStringList m_leftWindowControls;
    QStringList m_rightWindowControls;

    void getWindowControlsSettings();

#ifdef COMPONENT_ACCOUNTS
    bool handleAccounts = true;
#else
    bool handleAccounts = false;
#endif

signals:
    void iconNameChanged(QString iconName);
    void descriptionChanged(QString description);
    void webPageChanged(QString webPage);
    void donationPageChanged(QString donationPage);
    void reportPageChanged(QString reportPage);
    void handleAccountsChanged();
    void sendNotification(QString iconName, QString title, QString body, QJSValue callback, int timeout, QString buttonText);

    // CSD support
    void enableCSDChanged();
    void leftWindowControlsChanged();
    void rightWindowControlsChanged();
    void themeChanged();

public slots:
    void notify(const QString &icon = "emblem-warning", const QString &title = "Oops", const QString &body = "Something needs your attention", const QJSValue &callback = {}, const int &timeout = 2500, const QString &buttonText = "Ok");
};

QML_DECLARE_TYPEINFO(MauiApp, QML_HAS_ATTACHED_PROPERTIES)

#endif // MAUIAPP_H
