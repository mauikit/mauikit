#ifndef PLUGINMANAGER_H
#define PLUGINMANAGER_H

#include "fmh.h"
#include "mauilist.h"
#include <QObject>
#include <QQmlEngine>

namespace MauiKitPlugin
{
class Plugin : public QObject
{
    Q_OBJECT
};

class Interface : public QObject
{
    Q_OBJECT
public:
    Interface(const QString &id, QObject *interface, QObject *parent = nullptr)
        : QObject(parent)
        , m_id(id)
        , m_interface(interface)
    {
    }

private:
    QString m_id;
    QObject *m_interface;
};

class PluginInterfacesModel : public QAbstractListModel
{
    Q_OBJECT
public:
    PluginInterfacesModel(QObject *parent = nullptr);
    void append(Interface *interface);
    bool contains(const QString &id);
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QVector<Interface *> m_interfaces; // id
};

class PluginsModel : public MauiList
{
    Q_OBJECT
public:
    PluginsModel(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const final override;
    void append(Plugin *plugin);

private:
    FMH::MODEL_LIST m_plugins;
signals:
};

class PluginInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int orientation READ orientation WRITE setOrientation NOTIFY orientationChanged)
    Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(int target READ target WRITE setTarget NOTIFY targetChanged)

public:
    static PluginInterface *qmlAttachedProperties(QObject *object)
    {
        return new PluginInterface(object);
    }
    void setOrientation(const uint &value);
    uint orintation() const
    {
        return m_orientation;
    }

    void setType(const uint &value);
    uint type() const
    {
        return m_orientation;
    }

    void setTarget(const uint &value);
    uint target() const
    {
        return m_orientation;
    }

private:
    using QObject::QObject;
    QObject m_interface;
    uint m_orientation;
    uint m_type;
    uint m_target;

signals:
    void orientationChanged();
    void typeChanged();
    void targetChanged();
};

class PluginManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PluginsModel *plugins READ plugins FINAL CONSTANT)
    Q_PROPERTY(PluginInterfacesModel *interfaces READ interfaces FINAL CONSTANT)
public:
    static PluginManager *instance()
    {
        static PluginManager manager;
        return &manager;
    }

    PluginManager(const PluginManager &) = delete;
    PluginManager &operator=(const PluginManager &) = delete;
    PluginManager(PluginManager &&) = delete;
    PluginManager &operator=(PluginManager &&) = delete;

    void registerInterface(QObject *interface, const QString &id);
    PluginsModel *plugins() const
    {
        return m_plugins;
    }
    PluginInterfacesModel *interfaces() const
    {
        return m_interfaces;
    }

private:
    PluginManager(QObject *parent = nullptr);
    QObject m_interface;
    PluginsModel *m_plugins;
    PluginInterfacesModel *m_interfaces;

signals:
    void interfacesChanged();
};
}

#endif // PLUGINMANAGER_H
