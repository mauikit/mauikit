#ifndef PLATFORM_H
#define PLATFORM_H

#include <QObject>
#include "abstractplatform.h"

class Platform : public AbstractPlatform
{
    Q_OBJECT
public:
    static Platform *instance()
    {
        static Platform platform;
        return &platform;
    }

    Platform(const Platform &) = delete;
    Platform &operator=(const Platform &) = delete;
    Platform(Platform &&) = delete;
    Platform &operator=(Platform &&) = delete;

    // AbstractPlatform interface
public slots:
    void shareFiles(const QList<QUrl> &urls) override final;
    void shareText(const QString &text) override final;
    void openUrl(const QUrl &url) override final;
    bool hasKeyboard() override final;
    bool hasMouse() override final;

private:
    explicit Platform(QObject *parent = nullptr);

    AbstractPlatform *m_platform;
};

#endif //PLATFORM_H
