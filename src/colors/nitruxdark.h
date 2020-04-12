#ifndef NITRUXDARK_H
#define NITRUXDARK_H

#include <QPluginLoader>
#include "3rdparty/kirigami/src/libkirigami/kirigamipluginfactory.h"

class NitruxDark : public Kirigami::PlatformTheme
{
    Q_OBJECT
    QPalette lightPalette;

public:
    explicit NitruxDark(QObject* parent = nullptr);
};

class NitruxDarkFactory
        : public Kirigami::KirigamiPluginFactory
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.kde.nitrux.KirigamiPluginFactory")
    Q_INTERFACES(Kirigami::KirigamiPluginFactory)

public:
    explicit NitruxDarkFactory(QObject* parent = nullptr)
        : Kirigami::KirigamiPluginFactory(parent)
    {
    }

    Kirigami::PlatformTheme *createPlatformTheme(QObject *parent) override;
};

#endif
