#include "pluginmanager.h"

using namespace MauiKitPlugin;

MauiKitPlugin::PluginsModel::PluginsModel(QObject *parent)
    : MauiList(parent)
{
}

FMH::MODEL_LIST MauiKitPlugin::PluginsModel::items() const
{
    return m_plugins;
}

void MauiKitPlugin::PluginInterface::setType(const uint &value)
{
    if (m_type == value) {
        return;
    }

    m_type = value;
    emit typeChanged();
}

void MauiKitPlugin::PluginInterface::setTarget(const uint &value)
{
}

void MauiKitPlugin::PluginInterface::setOrientation(const uint &value)
{
}

MauiKitPlugin::PluginManager::PluginManager(QObject *parent)
    : QObject(parent)
    , m_plugins(new PluginsModel(this))
    , m_interfaces(new PluginInterfacesModel(this))
{
}

void MauiKitPlugin::PluginManager::registerInterface(QObject *interface, const QString &id)
{
    if (m_interfaces.contains(id)) {
        qWarning() << "Interface id has already been registered" << id;
        return;
    }

    m_interfaces.append(id, interface);
}
