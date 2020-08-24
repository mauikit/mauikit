#ifndef MAUIMACOS_H
#define MAUIMACOS_H

#include <QGuiApplication>
#include <QWindow>

/**
 * @brief The MAUIMacOS class
 */
class MAUIMacOS
{
public:
    /**
  * @brief removeTitlebarFromWindow
  * @param winId
  */
 static void removeTitlebarFromWindow(long winId = -1);

 /**
  * @brief runApp
  * @param app
  * @param files
  */
 static void runApp(const QString &app, const QList<QUrl> &files);
};

#endif // MAUIMACOS_H
