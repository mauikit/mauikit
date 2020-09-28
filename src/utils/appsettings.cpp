#include "appsettings.h"

SettingSection::SettingSection(QObject *parent) : QObject(parent)
{}

QString SettingSection::key() const
{
    return m_key;
}

QString SettingSection::group() const
{
    return m_group;
}

QVariant SettingSection::value() const
{
    return AppSettings::local().load(m_key, m_group, m_defaultValue);
}

QVariant SettingSection::defaultValue() const
{
    return m_defaultValue;
}

void SettingSection::setKey(QString key)
{
    if (m_key == key)
        return;

    m_key = key;
    emit keyChanged(m_key);
}

void SettingSection::setGroup(QString group)
{
    if (m_group == group)
        return;

    m_group = group;
    emit groupChanged(m_group);
}

void SettingSection::setValue(QVariant value)
{
    AppSettings::local().save(m_key, value, m_group);
}

void SettingSection::setDefaultValue(QVariant defaultValue)
{
    if (m_defaultValue == defaultValue)
        return;

    m_defaultValue = defaultValue;
    emit defaultValueChanged(m_defaultValue);
}

QUrl AppSettings::url() const
{
    return QUrl::fromLocalFile(m_settings->fileName());
}

QVariant AppSettings::load(const QString &key, const QString &group, const QVariant &defaultValue) const
{
    QVariant variant;
    m_settings->beginGroup(group);
    variant = m_settings->value(key, defaultValue);
    m_settings->endGroup();
    return variant;
}

void AppSettings::save(const QString &key, const QVariant &value, const QString &group)
{
    m_settings->beginGroup(group);
    m_settings->setValue(key, value);
    m_settings->endGroup();
    emit this->settingChanged(url(), key, value, group);
}

AppSettings::AppSettings(QString app, QString org)
    : QObject(nullptr)
    , m_app(app)
    , m_org(org)
    , m_settings(new QSettings(m_org, m_app, this))
{
}
