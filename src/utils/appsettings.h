#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QVariant>
#include <QSettings>
#include <QString>
#include <QUrl>

#include <QCoreApplication>
#include "mauikit_export.h"

class SettingSection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString key READ key WRITE setKey NOTIFY keyChanged)
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(QVariant defaultValue READ defaultValue WRITE setDefaultValue NOTIFY defaultValueChanged)

private:
    QString m_key;
    QString m_group;
    QVariant m_defaultValue;

public:
    explicit SettingSection(QObject * parent = nullptr);
    QString key() const;
    QString group() const;
    QVariant defaultValue() const;
    QVariant value() const;

public slots:
    void setKey(QString key);
    void setGroup(QString group);
    void setValue(QVariant value);
    void setDefaultValue(QVariant defaultValue);

signals:
    void keyChanged(QString key);
    void groupChanged(QString group);
    void defaultValueChanged(QVariant defaultValue);
};

/**
 * @brief The AppSettings class
 */

class MAUIKIT_EXPORT AppSettings : public QObject
{
    Q_OBJECT
public:
    /**
     * @brief local
     * @return
     */
    static AppSettings &local()
    {
        static AppSettings settings;
        return settings;
    }

    /**
     * @brief global
     * @return
     */
    static AppSettings &global()
    {
        static AppSettings settings("mauiproject");
        return settings;
    }

    AppSettings(const AppSettings &) = delete;
    AppSettings &operator=(const AppSettings &) = delete;
    AppSettings(AppSettings &&) = delete;
    AppSettings &operator=(AppSettings &&) = delete;

    /**
     * @brief url
     * @return
     */
    QUrl url() const;

    /**
     * @brief load
     * @param key
     * @param group
     * @param defaultValue
     * @return
     */
    QVariant load(const QString &key, const QString &group, const QVariant &defaultValue) const;

    /**
     * @brief save
     * @param key
     * @param value
     * @param group
     */
    void save(const QString &key, const QVariant &value, const QString &group);

private:
    explicit AppSettings(QString app = qApp->applicationName(), QString org = qApp->organizationName().isEmpty() ? QString("org.kde.maui") : qApp->organizationName());

    QString m_app;
    QString m_org;
    QSettings *m_settings;

signals:
    /**
     * @brief settingChanged
     * @param url
     * @param key
     * @param value
     * @param group
     */
    void settingChanged(QUrl url, QString key, QVariant value, QString group);
};

#endif // APPSETTINGS_H
