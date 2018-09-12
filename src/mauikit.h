#ifndef MAUIKIT_H
#define MAUIKIT_H

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class MauiKit : public QQmlExtensionPlugin
{
    Q_OBJECT

#ifndef STATIC_MAUIKIT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
#endif

public:    
    void registerTypes(const char *uri) Q_DECL_OVERRIDE;

    static MauiKit& getInstance()
    {
        static MauiKit instance;
        return instance;
    }

    static void registerTypes()
    {
        static MauiKit instance;
        instance.registerTypes("org.kde.mauikit");
    }

private:
    QUrl componentUrl(const QString &fileName) const;
    QString resolveFilePath(const QString &path) const
    {
#ifdef MAUI_APP
        return QStringLiteral(":/org/kde/mauikit/") + path;
#else
        return baseUrl().toLocalFile() + QLatin1Char('/') + path;
#endif
    }
    
    QString resolveFileUrl(const QString &filePath) const
    {
#ifdef MAUI_APP
        return filePath;
#else
        return baseUrl().toString() + QLatin1Char('/') + filePath;
#endif
    }

signals:

public slots:
};

#endif // MAUIKIT_H
