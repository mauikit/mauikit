#ifndef MAUIMACOS_H
#define MAUIMACOS_H

#include <QGuiApplication>
#include <QWindow>

class MAUIMacOS
{
public:
 static void removeTitlebarFromWindow(long winId = -1);
};

#endif // MAUIMACOS_H
