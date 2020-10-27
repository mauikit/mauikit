#ifndef MAUIWINDOWSH_H
#define MAUIWINDOWSH_H

#include <QObject>
#include "abstractplatform.h"

class MAUIWindows : public AbstractPlatform
{
    Q_OBJECT
public:
    explicit MAUIWindows(QObject *parent = nullptr);

public slots:
    void shareFiles(const QList<QUrl> &urls) override final;
    void shareText(const QString &urls) override final;
    void openUrl(const QUrl &url) override final;
    bool hasKeyboard() override final;
    bool hasMouse() override final;
    void notify(const QString &title, const QString &message, const QString &icon, const QString &imageUrl) override final;
};

#endif // MAUIWINDOWSH_H
