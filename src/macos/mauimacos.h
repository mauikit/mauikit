#ifndef MAUIMACOS_H
#define MAUIMACOS_H

#include <QGuiApplication>
#include <QWindow>

class MAUIMacOS
{
public:
 static void removeTitlebarFromWindow(long winId = -1);
 static void runApp(const QString &app, const QList<QUrl> &files);
};

#endif // MAUIMACOS_H
