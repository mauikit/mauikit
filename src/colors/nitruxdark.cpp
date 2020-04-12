#include "nitruxdark.h"

NitruxDark::NitruxDark(QObject* parent) : Kirigami::PlatformTheme(parent)
{
    for (auto group : {QPalette::Active, QPalette::Inactive, QPalette::Disabled}) {
        lightPalette.setColor(group, QPalette::WindowText, "#00FF00");
        lightPalette.setColor(group, QPalette::Window, "#00FF00");
        lightPalette.setColor(group, QPalette::Base, "#00FF00");
        lightPalette.setColor(group, QPalette::Text, "#00FF00");
        lightPalette.setColor(group, QPalette::Button, "#00FF00");
        lightPalette.setColor(group, QPalette::ButtonText, "#00FF00");
        lightPalette.setColor(group, QPalette::Highlight, "#00FF00");
        lightPalette.setColor(group, QPalette::HighlightedText, "#00FF00");
        lightPalette.setColor(group, QPalette::ToolTipBase, "#00FF00");
        lightPalette.setColor(group, QPalette::ToolTipText, "#00FF00");
        lightPalette.setColor(group, QPalette::Link, "#00FF00");
        lightPalette.setColor(group, QPalette::LinkVisited, "#00FF00");
    }

    setTextColor(lightPalette.color(QPalette::Active, QPalette::WindowText));
    setBackgroundColor(lightPalette.color(QPalette::Active, QPalette::Window));
    setHighlightColor(lightPalette.color(QPalette::Active, QPalette::Highlight));
    setHighlightedTextColor(lightPalette.color(QPalette::Active, QPalette::HighlightedText));
    setLinkColor(lightPalette.color(QPalette::Active, QPalette::Link));
    setVisitedLinkColor(lightPalette.color(QPalette::Active, QPalette::LinkVisited));
}

Kirigami::PlatformTheme *NitruxDarkFactory::createPlatformTheme(QObject *parent)
{
    return new NitruxDark(parent);
}
