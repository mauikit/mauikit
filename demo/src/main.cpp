#include <QQmlApplicationEngine>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QCommandLineParser>
#include <QFileInfo>
#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#ifdef STATIC_KIRIGAMI
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "./mauikit/src/mauikit.h"
#include <QStyleHints>
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    //    QGuiApplication::styleHints()->setMousePressAndHoldInterval(2000); // in [ms]
#else
    QApplication app(argc, argv);
#endif

    app.setApplicationName("MauiDemo");
    app.setApplicationVersion("1.0.0");
    app.setApplicationDisplayName("Maui Demo");
    app.setWindowIcon(QIcon(":/../assets/mauidemo.svg"));

    QQmlApplicationEngine engine;
#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();

#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
