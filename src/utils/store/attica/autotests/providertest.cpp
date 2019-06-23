/*
    This file is part of KDE.

    Copyright (c) 2018 Ralf Habacker <ralf.habacker@freenet.de>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.

*/

#include <QtTest>
#include <QEventLoop>

#include <QLoggingCategory>

#include <config.h>
#include <providermanager.h>


using namespace Attica;

class ProviderTest : public QObject
{
    Q_OBJECT
public:
    ProviderTest();
    virtual ~ProviderTest();

private:
    void initProvider(const QUrl &url);

private Q_SLOTS:
    void testFetchValidProvider();
    void testFetchInvalidProvider();

protected Q_SLOTS:
    void providerAdded(Attica::Provider p);
    void slotDefaultProvidersLoaded();
    void slotConfigResult(Attica::BaseJob *j);
    void slotTimeout();

private:
    Attica::ProviderManager *m_manager;
    QEventLoop *m_eventloop;
    QTimer m_timer;
    bool m_checkFail;
};

ProviderTest::ProviderTest()
  : m_manager(nullptr),
    m_eventloop(new QEventLoop),
    m_checkFail(true)
{
    QLoggingCategory::setFilterRules(QStringLiteral("org.kde.attica.debug=true"));
}

ProviderTest::~ProviderTest()
{
    delete m_manager;
}

void ProviderTest::slotDefaultProvidersLoaded()
{
    qDebug() << "default providers loaded";
    m_eventloop->exit();
}

void ProviderTest::providerAdded(Attica::Provider p)
{
    qDebug() << "got provider" << p.name();
    m_eventloop->exit();
}

void ProviderTest::initProvider(const QUrl &url)
{
    delete m_manager;
    m_manager = new Attica::ProviderManager;
    m_manager->setAuthenticationSuppressed(true);
    connect(m_manager, SIGNAL(defaultProvidersLoaded()), this, SLOT(slotDefaultProvidersLoaded()));
    connect(m_manager, SIGNAL(providerAdded(Attica::Provider)), this, SLOT(providerAdded(Attica::Provider)));
    m_manager->addProviderFile(url);
    m_timer.singleShot(5000, this, SLOT(slotTimeout()));
    m_checkFail = true;

    m_eventloop->exec();
}
void ProviderTest::testFetchValidProvider()
{
    initProvider(QUrl(QLatin1String("https://autoconfig.kde.org/ocs/providers.xml")));
    Attica::Provider provider = m_manager->providers().at(0);
    ItemJob<Config>* job = provider.requestConfig();
    QVERIFY(job);
    connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(slotConfigResult(Attica::BaseJob*)));
    job->start();
    m_eventloop->exec();
}

void ProviderTest::slotConfigResult(Attica::BaseJob* j)
{
    if (j->metadata().error() == Metadata::NoError) {
        Attica::ItemJob<Config> *itemJob = static_cast<Attica::ItemJob<Config> *>( j );
        Attica::Config p = itemJob->result();
        qDebug() << QLatin1String("Config loaded - Server has version") << p.version();
    } else if (j->metadata().error() == Metadata::OcsError) {
        qDebug() << QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message());
    } else if (j->metadata().error() == Metadata::NetworkError) {
        qDebug() << QString(QLatin1String("Network Error: %1")).arg(j->metadata().message());
    } else {
        qDebug() << QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message());
    }
    m_eventloop->exit();
    m_timer.stop();
    QVERIFY(j->metadata().error() == Metadata::NoError);
}

void ProviderTest::slotTimeout()
{
    if (m_eventloop->isRunning()) {
        m_eventloop->exit();
        if (m_checkFail)
            QFAIL("Could not fetch provider");
    }
}

void ProviderTest::testFetchInvalidProvider()
{
    // TODO error state could only be checked indirectly by timeout
    initProvider(QUrl(QLatin1String("https://invalid-url.org/ocs/providers.xml")));
    m_timer.singleShot(5000, this, SLOT(slotTimeout()));
    m_checkFail = false;
    m_eventloop->exec();
    QVERIFY(m_manager->providers().size() == 0);
}

QTEST_GUILESS_MAIN(ProviderTest)

#include "providertest.moc"
