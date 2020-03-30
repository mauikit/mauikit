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

struct MauiTheme 
{
	Q_GADGET	
	Q_PROPERTY(int borderRadius READ getRadius CONSTANT FINAL)
	Q_PROPERTY(bool maskButtons READ getMaskButtons CONSTANT FINAL)
	
	static QUrl confFile(const QUrl &path)
	{
		const auto conf = QUrl(path.toString()+"/config.conf");
		qDebug() << "LOOKING FOR STYLE IMAGE" << conf;
		
		if(FMH::fileExists(conf))
		{
			return conf;
		}
		
		return path;
	}
	
	QVariant getSettings(const QString &group, const QString &key, const QVariant &defaultValue) const
	{
		const auto conf = confFile(path);
		
		if(conf.isValid())
		{			
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
	Q_INVOKABLE QUrl buttonAsset(const QString &key, const QString &state) const
	{		
		auto res = getSettings(key, state, QString());
			
		if(!res.toString().isEmpty())
		{			
			auto imageUrl = QUrl(path.toString()+"/"+res.toString());
			if(FMH::fileExists(imageUrl))
			{
				return imageUrl;
			}				
		}
		
		return QUrl();
	}	
	
	int getRadius() const
	{		
		auto res = getSettings("Decoration", "BorderRadius", 6);
		return res.toInt();		
	}
	
	bool getMaskButtons() const
	{
		auto res = getSettings("Decoration", "MaskButtons", true);
		return res.toBool();		
	}
};
Q_DECLARE_METATYPE(MauiTheme)

class MauiAccounts;
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
    Q_PROPERTY(MauiAccounts * accounts READ getAccounts CONSTANT FINAL)
#endif
	
	// CSD support
	Q_PROPERTY(bool enableCSD READ enableCSD WRITE setEnableCSD NOTIFY enableCSDChanged)
	Q_PROPERTY(QStringList leftWindowControls MEMBER m_leftWindowControls NOTIFY leftWindowControlsChanged FINAL)
	Q_PROPERTY(QStringList rightWindowControls MEMBER m_rightWindowControls NOTIFY rightWindowControlsChanged FINAL)
	
	// Theming and branding support
	Q_PROPERTY(MauiTheme theme READ theme NOTIFY themeChanged FINAL )

public:  
    static MauiApp *qmlAttachedProperties(QObject *object);
    
	static MauiApp *instance()
	{
		static MauiApp app;
		return &app;
	}
	
	MauiApp(const MauiApp&) = delete;
	MauiApp& operator=(const MauiApp &) = delete;
	MauiApp(MauiApp &&) = delete;
	MauiApp & operator=(MauiApp &&) = delete;	
	
    static QString getName();

    static QString getDisplayName();

    static QString getVersion();
	
    static QString getOrg();
	
    static QString getDomain();
	
    static QString getMauikitVersion();
	
    static QString getQtVersion();
	
    QString getDescription() const;
	
    void setDescription(const QString &value);
	
    QString getIconName() const;
	
    void setIconName(const QString &value);
	
    QString getWebPage() const;
	
    void setWebPage(const QString &value);
	
    QString getDonationPage() const;
	
    void setDonationPage(const QString &value);
	
    QString getReportPage() const;
	
    void setReportPage(const QString &value);

    bool getHandleAccounts() const;
    void setHandleAccounts(const bool &value);	
    
    QVariantList getCredits() const { return m_credits; }
    void setCredits(const QVariantList &credits) { m_credits = credits; }
	
	//Theming and branding support
	MauiTheme theme()
	{
		return m_theme;
	}
	
	//CSD support
	bool enableCSD() const;
	void setEnableCSD(const bool &value);

#ifdef COMPONENT_ACCOUNTS
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
	
	//Theming and branding support
	MauiTheme m_theme;
	
	//CSD support
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
