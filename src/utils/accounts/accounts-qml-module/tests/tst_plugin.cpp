/*
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: Alberto Mardegan <alberto.mardegan@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 2.1.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <Accounts/AccountService>
#include <Accounts/Manager>
#include <QAbstractListModel>
#include <QDebug>
#include <QDir>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QTest>

using namespace Accounts;

static bool mapIsSubset(const QVariantMap &set, const QVariantMap &test)
{
    QMapIterator<QString, QVariant> it(set);
    while (it.hasNext()) {
        it.next();
        if (QMetaType::Type(it.value().type()) == QMetaType::QVariantMap) {
            if (!mapIsSubset(it.value().toMap(),
                             test.value(it.key()).toMap())) {
                return false;
            }
        } else if (test.value(it.key()) != it.value()) {
            qDebug() << "Maps differ: expected" << it.value() <<
                "but found" << test.value(it.key());
            return false;
        }
    }

    return true;
}

class PluginTest: public QObject
{
    Q_OBJECT

public:
    PluginTest();

private Q_SLOTS:
    void initTestCase();
    void testLoadPlugin();
    void testEmptyModel();
    void testModel();
    void testModelSignals();
    void testModelDisplayName();
    void testProviderModel();
    void testProviderModelWithApplication();
    void testAccountService();
    void testAccountServiceUpdate();
    void testAuthentication_data();
    void testAuthentication();
    void testAuthenticationErrors_data();
    void testAuthenticationErrors();
    void testAuthenticationDeleted();
    void testAuthenticationCancel();
    void testAuthenticationWithCredentials();
    void testManagerCreate();
    void testManagerLoad();
    void testAccountInvalid();
    void testAccount();
    void testCredentials();
    void testAccountCredentialsRemoval_data();
    void testAccountCredentialsRemoval();
    void testAccountServiceCredentials();
    void testApplicationModel();

private:
    void clearDb();
    QVariant get(const QAbstractListModel *model, int row, QString roleName);
};

PluginTest::PluginTest():
    QObject(0)
{
}

void PluginTest::clearDb()
{
    QDir dbroot(QString::fromLatin1(qgetenv("ACCOUNTS")));
    dbroot.remove("accounts.db");
}

QVariant PluginTest::get(const QAbstractListModel *model, int row,
                         QString roleName)
{
    QHash<int, QByteArray> roleNames = model->roleNames();

    int role = roleNames.key(roleName.toLatin1(), -1);
    return model->data(model->index(row), role);
}

void PluginTest::initTestCase()
{
    qputenv("QML2_IMPORT_PATH", "../src");
    qputenv("ACCOUNTS", "/tmp/");
    qputenv("AG_APPLICATIONS", TEST_DATA_DIR);
    qputenv("AG_SERVICES", TEST_DATA_DIR);
    qputenv("AG_SERVICE_TYPES", TEST_DATA_DIR);
    qputenv("AG_PROVIDERS", TEST_DATA_DIR);
    qputenv("XDG_DATA_HOME", TEST_DATA_DIR);

    clearDb();
}

void PluginTest::testLoadPlugin()
{
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountServiceModel {}",
                      QUrl());
    QObject *object = component.create();
    QVERIFY(object != 0);
    delete object;
}

void PluginTest::testEmptyModel()
{
    clearDb();

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountServiceModel {}",
                      QUrl());
    QObject *object = component.create();
    QVERIFY(object != 0);
    QAbstractListModel *model = qobject_cast<QAbstractListModel*>(object);
    QVERIFY(model != 0);

    QCOMPARE(model->rowCount(), 0);

    /* We'll now add some accounts but set the service type filter so that they
     * should not appear in the model. */
    model->setProperty("serviceType", QString("e-mail"));
    QCOMPARE(model->property("serviceType").toString(), QString("e-mail"));

    /* Create some disabled accounts */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service badMail = manager->service("badmail");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(false);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->syncAndBlock();

    Account *account2 = manager->createAccount("bad");
    QVERIFY(account2 != 0);

    account2->setEnabled(true);
    account2->setDisplayName("BadAccount");
    account2->selectService(badMail);
    account2->setEnabled(false);
    account2->syncAndBlock();

    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 0);

    delete manager;
    delete object;
}

void PluginTest::testModel()
{
    clearDb();
    /* Create some accounts */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service coolShare = manager->service("coolshare");
    Service badMail = manager->service("badmail");
    Service badShare = manager->service("badshare");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->selectService(coolShare);
    account1->setEnabled(false);
    account1->syncAndBlock();

    Account *account2 = manager->createAccount("bad");
    QVERIFY(account2 != 0);

    account2->setEnabled(true);
    account2->setDisplayName("BadAccount");
    account2->selectService(badMail);
    account2->setEnabled(true);
    account2->selectService(badShare);
    account2->setEnabled(true);
    account2->syncAndBlock();

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountServiceModel {}",
                      QUrl());
    QObject *object = component.create();
    QVERIFY(object != 0);
    QAbstractListModel *model = qobject_cast<QAbstractListModel*>(object);
    QVERIFY(model != 0);

    QCOMPARE(model->rowCount(), 3);
    QCOMPARE(model->property("count").toInt(), 3);

    QCOMPARE(get(model, 0, "displayName").toString(), QString("BadAccount"));
    QCOMPARE(get(model, 0, "providerName").toString(), QString("Bad provider"));
    QCOMPARE(get(model, 0, "accountId").toUInt(), account2->id());
    QObject *accountHandle = get(model, 0, "accountHandle").value<QObject*>();
    Account *tmpAccount = qobject_cast<Account*>(accountHandle);
    QVERIFY(tmpAccount != 0);
    QCOMPARE(tmpAccount->id(), account2->id());
    // Same value, but using the deprecated role name
    QCOMPARE(get(model, 0, "account").value<QObject*>(), accountHandle);
    QCOMPARE(get(model, 1, "displayName").toString(), QString("BadAccount"));
    QCOMPARE(get(model, 1, "providerName").toString(), QString("Bad provider"));
    QCOMPARE(get(model, 2, "displayName").toString(), QString("CoolAccount"));
    QCOMPARE(get(model, 2, "providerName").toString(), QString("Cool provider"));
    QCOMPARE(get(model, 2, "accountId").toUInt(), account1->id());
    QVariant value;
    QVERIFY(QMetaObject::invokeMethod(model, "get",
                                      Q_RETURN_ARG(QVariant, value),
                                      Q_ARG(int, 2),
                                      Q_ARG(QString, "providerName")));
    QCOMPARE(value.toString(), QString("Cool provider"));
    QObject *accountServiceHandle =
        get(model, 2, "accountServiceHandle").value<QObject*>();
    QVERIFY(accountServiceHandle != 0);
    QCOMPARE(accountServiceHandle->metaObject()->className(), "Accounts::AccountService");
    // Same value, but using the deprecated role name
    QCOMPARE(get(model, 2, "accountService").value<QObject*>(),
             accountServiceHandle);

    model->setProperty("includeDisabled", true);
    QCOMPARE(model->property("includeDisabled").toBool(), true);
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 4);
    QCOMPARE(get(model, 0, "enabled").toBool(), true);
    QCOMPARE(get(model, 1, "enabled").toBool(), true);
    QCOMPARE(get(model, 2, "enabled").toBool(), true);
    QCOMPARE(get(model, 3, "enabled").toBool(), false);

    /* Test the accountId filter */
    model->setProperty("accountId", account1->id());
    QCOMPARE(model->property("accountId").toUInt(), account1->id());
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(get(model, 0, "accountId").toUInt(), account1->id());
    QCOMPARE(get(model, 1, "accountId").toUInt(), account1->id());
    model->setProperty("accountId", 0);

    /* Test the account filter */
    model->setProperty("account", QVariant::fromValue<QObject*>(account2));
    QCOMPARE(model->property("account").value<QObject*>(), account2);
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(get(model, 0, "accountId").toUInt(), account2->id());
    QCOMPARE(get(model, 1, "accountId").toUInt(), account2->id());
    model->setProperty("account", QVariant::fromValue<QObject*>(account2));
    QCOMPARE(model->property("account").value<QObject*>(), account2);
    model->setProperty("account", QVariant::fromValue<QObject*>(0));

    /* Test the application filter */
    model->setProperty("applicationId", QString("mailer"));
    QCOMPARE(model->property("applicationId").toString(), QString("mailer"));
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 2);
    QSet<QString> services;
    services.insert(get(model, 0, "serviceName").toString());
    services.insert(get(model, 1, "serviceName").toString());
    QSet<QString> expectedServices;
    expectedServices.insert("Cool Mail");
    expectedServices.insert("Bad Mail");
    QCOMPARE(services, expectedServices);
    /* Reset the application filter */
    model->setProperty("applicationId", QString());

    /* Test the provider filter */
    model->setProperty("provider", QString("bad"));
    QCOMPARE(model->property("provider").toString(), QString("bad"));
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(get(model, 0, "providerName").toString(), QString("Bad provider"));
    QCOMPARE(get(model, 1, "providerName").toString(), QString("Bad provider"));

    /* Test the service filter */
    model->setProperty("service", QString("coolmail"));
    QCOMPARE(model->property("service").toString(), QString("coolmail"));
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 0);
    /* Reset the provider, to get some results */
    model->setProperty("provider", QString());
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 1);
    QCOMPARE(get(model, 0, "providerName").toString(), QString("Cool provider"));
    QCOMPARE(get(model, 0, "serviceName").toString(), QString("Cool Mail"));
    QCOMPARE(get(model, 0, "enabled").toBool(), true);
    /* Retrieve global accounts */
    model->setProperty("service", QString("global"));
    QCOMPARE(model->property("service").toString(), QString("global"));
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(get(model, 0, "providerName").toString(), QString("Bad provider"));
    QCOMPARE(get(model, 1, "providerName").toString(), QString("Cool provider"));
    /* The AccountService objects should refer to a null Service */
    for (int i = 0; i < 2; i++) {
        QObject *tmp = get(model, i, "accountServiceHandle").value<QObject*>();
        AccountService *accountService1 = qobject_cast<AccountService*>(tmp);
        QVERIFY(accountService1 != 0);
        QVERIFY(!accountService1->service().isValid());
    }

    /* Test the service-type filter */
    model->setProperty("serviceType", QString("sharing"));
    QCOMPARE(model->property("serviceType").toString(), QString("sharing"));
    /* Reset the service, to get some results */
    model->setProperty("service", QString());
    QTest::qWait(10);
    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(get(model, 0, "serviceName").toString(), QString("Bad Share"));
    QCOMPARE(get(model, 1, "serviceName").toString(), QString("Cool Share"));

    delete manager;
    delete object;
}

void PluginTest::testModelSignals()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service coolShare = manager->service("coolshare");
    Service badMail = manager->service("badmail");
    Service badShare = manager->service("badshare");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->selectService(coolShare);
    account1->setEnabled(false);
    account1->syncAndBlock();

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountServiceModel {}",
                      QUrl());
    QObject *object = component.create();
    QVERIFY(object != 0);
    QAbstractListModel *model = qobject_cast<QAbstractListModel*>(object);
    QVERIFY(model != 0);

    QCOMPARE(model->rowCount(), 1);
    QCOMPARE(model->property("count").toInt(), 1);

    QCOMPARE(get(model, 0, "displayName").toString(), QString("CoolAccount"));
    QCOMPARE(get(model, 0, "providerName").toString(),
             QString("Cool provider"));
    QCOMPARE(get(model, 0, "serviceName").toString(), QString("Cool Mail"));

    /* Enable the cool share service, and verify that it appears in the model */
    QSignalSpy countChanged(model, SIGNAL(countChanged()));
    QSignalSpy rowsInserted(model,
                            SIGNAL(rowsInserted(const QModelIndex&,int,int)));
    account1->selectService(coolShare);
    account1->setEnabled(true);
    account1->syncAndBlock();
    QTest::qWait(50);

    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(rowsInserted.count(), 1);
    QCOMPARE(countChanged.count(), 1);
    rowsInserted.clear();

    /* Disable the cool mail service, and verify that it gets removed */
    QSignalSpy rowsRemoved(model,
                           SIGNAL(rowsRemoved(const QModelIndex&,int,int)));
    account1->selectService(coolMail);
    account1->setEnabled(false);
    account1->syncAndBlock();
    QTest::qWait(50);

    QCOMPARE(model->rowCount(), 1);
    QCOMPARE(rowsInserted.count(), 0);
    QCOMPARE(rowsRemoved.count(), 1);
    rowsRemoved.clear();

    /* Create a second account */
    Account *account2 = manager->createAccount("bad");
    QVERIFY(account2 != 0);

    account2->setEnabled(false);
    account2->setDisplayName("BadAccount");
    account2->selectService(badMail);
    account2->setEnabled(true);
    account2->selectService(badShare);
    account2->setEnabled(true);
    account2->syncAndBlock();
    QTest::qWait(50);

    /* It's disabled, so nothing should have changed */
    QCOMPARE(model->rowCount(), 1);
    QCOMPARE(rowsInserted.count(), 0);
    QCOMPARE(rowsRemoved.count(), 0);

    /* Enable it */
    account2->selectService();
    account2->setEnabled(true);
    account2->syncAndBlock();
    QTest::qWait(50);

    QCOMPARE(model->rowCount(), 3);
    QCOMPARE(rowsInserted.count(), 2);
    QCOMPARE(rowsRemoved.count(), 0);
    rowsInserted.clear();

    /* Include disabled */
    model->setProperty("includeDisabled", true);
    QTest::qWait(50);

    QCOMPARE(model->rowCount(), 4);
    /* The model is being reset: all rows are deleted and then re-added */
    QCOMPARE(rowsInserted.count(), 1);
    QCOMPARE(rowsRemoved.count(), 1);
    rowsInserted.clear();
    rowsRemoved.clear();

    QCOMPARE(get(model, 0, "enabled").toBool(), true);
    QCOMPARE(get(model, 1, "enabled").toBool(), true);
    QCOMPARE(get(model, 2, "enabled").toBool(), false);
    QCOMPARE(get(model, 3, "enabled").toBool(), true);

    /* Enable cool mail, and check for the dataChanged signal */
    QSignalSpy dataChanged(model,
                   SIGNAL(dataChanged(const QModelIndex&,const QModelIndex&)));
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->syncAndBlock();
    QTest::qWait(50);

    QCOMPARE(dataChanged.count(), 1);
    QModelIndex index = qvariant_cast<QModelIndex>(dataChanged.at(0).at(0));
    QCOMPARE(index.row(), 2);
    QCOMPARE(rowsInserted.count(), 0);
    QCOMPARE(rowsRemoved.count(), 0);
    dataChanged.clear();
    QCOMPARE(get(model, 2, "enabled").toBool(), true);

    /* Delete the first account */
    account1->remove();
    account1->syncAndBlock();
    QTest::qWait(50);

    QCOMPARE(model->rowCount(), 2);
    QCOMPARE(rowsInserted.count(), 0);
    /* We expect one single signal carrying two rows */
    QCOMPARE(rowsRemoved.count(), 1);
    QCOMPARE(rowsRemoved.at(0).at(1).toInt(), 2);
    QCOMPARE(rowsRemoved.at(0).at(2).toInt(), 3);
    rowsRemoved.clear();

    /* Create a third account */
    Account *account3 = manager->createAccount("bad");
    QVERIFY(account3 != 0);

    account3->setEnabled(true);
    account3->setDisplayName("Second BadAccount");
    account3->selectService(badMail);
    account3->setEnabled(true);
    account3->selectService(badShare);
    account3->setEnabled(false);
    account3->syncAndBlock();
    QTest::qWait(50);

    QCOMPARE(model->rowCount(), 4);
    /* We expect one single signal carrying two rows */
    QCOMPARE(rowsInserted.count(), 1);
    QCOMPARE(rowsInserted.at(0).at(1).toInt(), 2);
    QCOMPARE(rowsInserted.at(0).at(2).toInt(), 3);
    QCOMPARE(rowsRemoved.count(), 0);
    rowsInserted.clear();

    delete manager;
    delete object;
}

void PluginTest::testModelDisplayName()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service coolShare = manager->service("coolshare");
    Service badMail = manager->service("badmail");
    Service badShare = manager->service("badshare");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->selectService(coolShare);
    account1->setEnabled(false);
    account1->syncAndBlock();

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountServiceModel {\n"
                      "  includeDisabled: true\n"
                      "}",
                      QUrl());
    QObject *object = component.create();
    QVERIFY(object != 0);
    QAbstractListModel *model = qobject_cast<QAbstractListModel*>(object);
    QVERIFY(model != 0);

    QCOMPARE(model->property("count").toInt(), 2);

    /* Create a second account */
    Account *account2 = manager->createAccount("bad");
    QVERIFY(account2 != 0);

    account2->setEnabled(false);
    account2->setDisplayName("BadAccount");
    account2->selectService(badMail);
    account2->setEnabled(true);
    account2->selectService(badShare);
    account2->setEnabled(false);
    account2->syncAndBlock();

    QSignalSpy countChanged(model, SIGNAL(countChanged()));
    countChanged.wait();

    QCOMPARE(model->property("count").toInt(), 4);

    QCOMPARE(get(model, 0, "displayName").toString(), QString("BadAccount"));
    QCOMPARE(get(model, 1, "displayName").toString(), QString("BadAccount"));
    QCOMPARE(get(model, 2, "displayName").toString(), QString("CoolAccount"));
    QCOMPARE(get(model, 3, "displayName").toString(), QString("CoolAccount"));

    /* Change the displayName, and verify that the dataChanged() signal is
     * emitted */
    QSignalSpy dataChanged(model,
                   SIGNAL(dataChanged(const QModelIndex&,const QModelIndex&)));
    account1->setDisplayName("ColdAccount");
    account1->syncAndBlock();
    dataChanged.wait();

    /* This is actually an implementation detail: instead of a single signal
     * carrying the index range in its parameters, we currently get N separate
     * signals. */
    QCOMPARE(dataChanged.count(), 2);
    QModelIndex index = qvariant_cast<QModelIndex>(dataChanged.at(0).at(0));
    QCOMPARE(index.row(), 2);
    index = qvariant_cast<QModelIndex>(dataChanged.at(1).at(0));
    QCOMPARE(index.row(), 3);

    QCOMPARE(get(model, 0, "displayName").toString(), QString("BadAccount"));
    QCOMPARE(get(model, 1, "displayName").toString(), QString("BadAccount"));
    QCOMPARE(get(model, 2, "displayName").toString(), QString("ColdAccount"));
    QCOMPARE(get(model, 3, "displayName").toString(), QString("ColdAccount"));

    delete manager;
    delete object;
}

void PluginTest::testProviderModel()
{
    /* Create some accounts */
    Manager *manager = new Manager(this);
    ProviderList providers = manager->providerList();

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "ProviderModel {}",
                      QUrl());
    QObject *object = component.create();
    QVERIFY(object != 0);
    QAbstractListModel *model = qobject_cast<QAbstractListModel*>(object);
    QVERIFY(model != 0);

    QCOMPARE(model->rowCount(), providers.count());
    QCOMPARE(model->property("count").toInt(), providers.count());
    QCOMPARE(model->property("applicationId").toString(), QString());

    for (int i = 0; i < providers.count(); i++) {
        QCOMPARE(get(model, i, "displayName").toString(), providers[i].displayName());
        QCOMPARE(get(model, i, "providerId").toString(), providers[i].name());
        QCOMPARE(get(model, i, "iconName").toString(), providers[i].iconName());
        QCOMPARE(get(model, i, "isSingleAccount").toBool(),
                 providers[i].isSingleAccount());
        QCOMPARE(get(model, i, "translations").toString(),
                 providers[i].trCatalog());
    }

    QCOMPARE(get(model, 100, "iconName"), QVariant());

    QVariant value;
    QVERIFY(QMetaObject::invokeMethod(model, "get",
                                      Q_RETURN_ARG(QVariant, value),
                                      Q_ARG(int, 1),
                                      Q_ARG(QString, "providerId")));
    QCOMPARE(value.toString(), providers[1].name());

    delete manager;
    delete object;
}

void PluginTest::testProviderModelWithApplication()
{
    /* Create some accounts */
    Manager *manager = new Manager(this);
    ProviderList providers = manager->providerList();

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "ProviderModel {\n"
                      "  applicationId: \"mailer\"\n"
                      "}",
                      QUrl());
    QObject *object = component.create();
    QVERIFY(object != 0);
    QAbstractListModel *model = qobject_cast<QAbstractListModel*>(object);
    QVERIFY(model != 0);

    QCOMPARE(model->rowCount(), providers.count());
    QCOMPARE(model->property("count").toInt(), providers.count());
    QCOMPARE(model->property("applicationId").toString(), QString("mailer"));

    /* Now set an application which supports only "coolservice" and verify that
     * only the "cool" provider is there */
    QSignalSpy countSignal(model, SIGNAL(countChanged()));
    model->setProperty("applicationId", QString("coolpublisher"));
    QCOMPARE(model->property("applicationId").toString(), QString("coolpublisher"));
    QCOMPARE(countSignal.count(), 1);
    QCOMPARE(model->property("count").toInt(), 1);
    /* Do it twice, just to improve branch coverage */
    model->setProperty("applicationId", QString("coolpublisher"));

    QCOMPARE(get(model, 0, "providerId").toString(), QString("cool"));

    delete manager;
    delete object;
}

void PluginTest::testAccountService()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service coolShare = manager->service("coolshare");
    Service badMail = manager->service("badmail");
    Service badShare = manager->service("badshare");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->selectService(coolShare);
    account1->setEnabled(false);
    account1->syncAndBlock();

    AccountService *accountService1 = new AccountService(account1, coolMail);
    QVERIFY(accountService1 != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService1", accountService1);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService { objectHandle: accountService1 }",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QCOMPARE(qmlObject->property("objectHandle").value<AccountService*>(),
             accountService1);
    QCOMPARE(qmlObject->property("enabled").toBool(), true);
    QCOMPARE(qmlObject->property("serviceEnabled").toBool(), true);
    QCOMPARE(qmlObject->property("displayName").toString(),
             QString("CoolAccount"));
    QCOMPARE(qmlObject->property("accountId").toUInt(), account1->id());

    QVariantMap provider = qmlObject->property("provider").toMap();
    QVERIFY(!provider.isEmpty());
    QCOMPARE(provider["id"].toString(), QString("cool"));
    QCOMPARE(provider["displayName"].toString(), QString("Cool provider"));
    QCOMPARE(provider["iconName"].toString(), QString("general_myprovider"));
    QCOMPARE(provider["isSingleAccount"].toBool(), true);
    QCOMPARE(provider["translations"].toString(), QString("somewhere"));

    QVariantMap service = qmlObject->property("service").toMap();
    QVERIFY(!service.isEmpty());
    QCOMPARE(service["id"].toString(), QString("coolmail"));
    QCOMPARE(service["displayName"].toString(), QString("Cool Mail"));
    QCOMPARE(service["iconName"].toString(), QString("general_myservice"));
    QCOMPARE(service["serviceTypeId"].toString(), QString("e-mail"));
    QCOMPARE(service["translations"].toString(), QString("here"));

    QVariantMap settings = qmlObject->property("settings").toMap();
    QVERIFY(!settings.isEmpty());
    QCOMPARE(settings["color"].toString(), QString("green"));
    QCOMPARE(settings["auto-explode-after"].toUInt(), uint(10));
    QCOMPARE(settings.count(), 2);

    QVariantMap authData = qmlObject->property("authData").toMap();
    QVERIFY(!authData.isEmpty());
    QCOMPARE(authData["method"].toString(), QString("oauth2"));
    QCOMPARE(authData["mechanism"].toString(), QString("user_agent"));
    QVariantMap parameters = authData["parameters"].toMap();
    QVERIFY(!parameters.isEmpty());
    QCOMPARE(parameters["host"].toString(), QString("coolmail.ex"));

    /* Delete the account service, and check that the QML object survives */
    delete accountService1;

    QCOMPARE(qmlObject->property("objectHandle").value<AccountService*>(),
             (AccountService*)0);
    QCOMPARE(qmlObject->property("enabled").toBool(), false);
    QCOMPARE(qmlObject->property("serviceEnabled").toBool(), false);
    QCOMPARE(qmlObject->property("displayName").toString(), QString());
    QCOMPARE(qmlObject->property("accountId").toUInt(), uint(0));

    provider = qmlObject->property("provider").toMap();
    QVERIFY(provider.isEmpty());

    service = qmlObject->property("service").toMap();
    QVERIFY(service.isEmpty());

    settings = qmlObject->property("settings").toMap();
    QVERIFY(settings.isEmpty());

    authData = qmlObject->property("authData").toMap();
    QVERIFY(authData.isEmpty());

    QVariantMap newSettings;
    newSettings.insert("color", QString("red"));
    bool ok;
    ok = QMetaObject::invokeMethod(qmlObject, "updateSettings",
                                   Q_ARG(QVariantMap, newSettings));
    QVERIFY(ok);
    ok = QMetaObject::invokeMethod(qmlObject, "updateServiceEnabled",
                                   Q_ARG(bool, true));
    QVERIFY(ok);

    delete manager;
    delete qmlObject;
}

void PluginTest::testAccountServiceUpdate()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Account *account = manager->createAccount("cool");
    QVERIFY(account != 0);

    account->setEnabled(true);
    account->setDisplayName("CoolAccount");
    account->selectService(coolMail);
    account->setEnabled(true);
    account->syncAndBlock();

    AccountService *accountService = new AccountService(account, coolMail);
    QVERIFY(accountService != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService", accountService);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService { objectHandle: accountService }",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QCOMPARE(qmlObject->property("objectHandle").value<AccountService*>(),
             accountService);
    QCOMPARE(qmlObject->property("autoSync").toBool(), true);
    /* Set it to the same value, just to increase coverage */
    QVERIFY(qmlObject->setProperty("autoSync", true));
    QCOMPARE(qmlObject->property("autoSync").toBool(), true);

    QVariantMap settings = qmlObject->property("settings").toMap();
    QVERIFY(!settings.isEmpty());
    QCOMPARE(settings["color"].toString(), QString("green"));
    QCOMPARE(settings["auto-explode-after"].toUInt(), uint(10));
    QCOMPARE(settings.count(), 2);

    QSignalSpy settingsChanged(qmlObject, SIGNAL(settingsChanged()));

    /* Update a couple of settings */
    QVariantMap newSettings;
    newSettings.insert("color", QString("red"));
    newSettings.insert("verified", true);
    QMetaObject::invokeMethod(qmlObject, "updateSettings",
                              Q_ARG(QVariantMap, newSettings));
    QTest::qWait(50);

    QCOMPARE(settingsChanged.count(), 1);
    settingsChanged.clear();
    settings = qmlObject->property("settings").toMap();
    QCOMPARE(settings["color"].toString(), QString("red"));
    QCOMPARE(settings["auto-explode-after"].toUInt(), uint(10));
    QCOMPARE(settings["verified"].toBool(), true);
    QCOMPARE(settings.count(), 3);

    /* Disable the service */
    QSignalSpy enabledChanged(qmlObject, SIGNAL(enabledChanged()));
    QMetaObject::invokeMethod(qmlObject, "updateServiceEnabled",
                              Q_ARG(bool, false));
    QTest::qWait(50);
    QCOMPARE(enabledChanged.count(), 1);
    enabledChanged.clear();
    QCOMPARE(qmlObject->property("enabled").toBool(), false);
    QCOMPARE(settingsChanged.count(), 1);
    settingsChanged.clear();
    QCOMPARE(qmlObject->property("serviceEnabled").toBool(), false);

    /* Disable autoSync, and change something else */
    qmlObject->setProperty("autoSync", false);
    QCOMPARE(qmlObject->property("autoSync").toBool(), false);

    newSettings.clear();
    newSettings.insert("verified", false);
    newSettings.insert("color", QVariant());
    QMetaObject::invokeMethod(qmlObject, "updateSettings",
                              Q_ARG(QVariantMap, newSettings));
    QTest::qWait(50);

    /* Nothing should have been changed yet */
    QCOMPARE(settingsChanged.count(), 0);
    settings = qmlObject->property("settings").toMap();
    QCOMPARE(settings["verified"].toBool(), true);

    /* Manually store the settings */
    account->sync();
    QTest::qWait(50);

    QCOMPARE(settingsChanged.count(), 1);
    settingsChanged.clear();
    settings = qmlObject->property("settings").toMap();
    QCOMPARE(settings["verified"].toBool(), false);
    QCOMPARE(settings["color"].toString(), QString("green"));

    delete accountService;
    delete manager;
    delete qmlObject;
}

void PluginTest::testAuthentication_data()
{
    QTest::addColumn<QString>("params");
    QTest::addColumn<QVariantMap>("expectedReply");

    QVariantMap reply;

    reply.insert("test", QString("OK"));
    reply.insert("host", QString("coolmail.ex"));
    QTest::newRow("success with params") <<
        "{ \"test\": \"OK\" }" <<
        reply;
    reply.clear();

    reply.insert("host", QString("coolmail.ex"));
    QTest::newRow("success without params") <<
        "" <<
        reply;
    reply.clear();
}

void PluginTest::testAuthentication()
{
    QFETCH(QString, params);
    QFETCH(QVariantMap, expectedReply);

    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service coolShare = manager->service("coolshare");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->selectService(coolShare);
    account1->setEnabled(false);
    account1->syncAndBlock();

    AccountService *accountService1 = new AccountService(account1, coolMail);
    QVERIFY(accountService1 != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService1", accountService1);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService {\n"
                      "  objectHandle: accountService1\n"
                      "  function go() {\n"
                      "    authenticate(" + params.toUtf8() + ")\n"
                      "  }\n"
                      "}",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QSignalSpy authenticated(qmlObject,
                             SIGNAL(authenticated(const QVariantMap &)));
    QSignalSpy authenticationError(qmlObject,
        SIGNAL(authenticationError(const QVariantMap &)));

    QMetaObject::invokeMethod(qmlObject, "go");

    QTRY_COMPARE(authenticated.count(), 1);
    QCOMPARE(authenticationError.count(), 0);
    QVariantMap reply = authenticated.at(0).at(0).toMap();
    QVERIFY(mapIsSubset(expectedReply, reply));

    delete accountService1;
    delete manager;
    delete qmlObject;
}

void PluginTest::testAuthenticationErrors_data()
{
    QTest::addColumn<QString>("params");
    QTest::addColumn<QString>("codeName");
    QTest::addColumn<QString>("expectedMessage");

    QTest::newRow("Signon::UserCanceled") <<
        "{ \"errorCode\": 311, \"errorMessage\": \"Failed!\" }" <<
        "UserCanceledError" << "Failed!";

    QTest::newRow("Signon::InvalidQuery") <<
        "{ \"errorCode\": 103, \"errorMessage\": \"Weird\" }" <<
        "NoAccountError" << "Weird";

    QTest::newRow("Signon::PermissionDenied") <<
        "{ \"errorCode\": 4, \"errorMessage\": \"Failed!\" }" <<
        "PermissionDeniedError" << "Failed!";

    QTest::newRow("Signon::NoConnection") <<
        "{ \"errorCode\": 307, \"errorMessage\": \"Failed!\" }" <<
        "NetworkError" << "Failed!";
}

void PluginTest::testAuthenticationErrors()
{
    QFETCH(QString, params);
    QFETCH(QString, codeName);
    QFETCH(QString, expectedMessage);

    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service coolShare = manager->service("coolshare");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->selectService(coolShare);
    account1->setEnabled(false);
    account1->syncAndBlock();

    AccountService *accountService1 = new AccountService(account1, coolMail);
    QVERIFY(accountService1 != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService1", accountService1);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService {\n"
                      "  objectHandle: accountService1\n"
                      "  function go() {\n"
                      "    authenticate(" + params.toUtf8() + ")\n"
                      "  }\n"
                      "}",
                      QUrl());
    QObject *qmlObject = component.create();
    qDebug() << component.errors();
    QVERIFY(qmlObject != 0);

    QSignalSpy authenticationError(qmlObject,
        SIGNAL(authenticationError(const QVariantMap &)));

    QMetaObject::invokeMethod(qmlObject, "go");

    QTRY_COMPARE(authenticationError.count(), 1);

    QVariantMap reply = authenticationError.at(0).at(0).toMap();
    int code = reply.value("code").toInt();
    QString message = reply.value("message").toString();

    QCOMPARE(message, expectedMessage);
    const QMetaObject *mo = qmlObject->metaObject();
    const QMetaEnum errorEnum =
        mo->enumerator(mo->indexOfEnumerator("ErrorCode"));
    QCOMPARE(code, errorEnum.keyToValue(codeName.toUtf8().constData()));

    delete accountService1;
    delete manager;
    delete qmlObject;
}

void PluginTest::testAuthenticationDeleted()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Service coolShare = manager->service("coolshare");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->selectService(coolShare);
    account1->setEnabled(false);
    account1->syncAndBlock();

    AccountService *accountService1 = new AccountService(account1, coolMail);
    QVERIFY(accountService1 != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService1", accountService1);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService { objectHandle: accountService1 }",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QSignalSpy authenticated(qmlObject,
                             SIGNAL(authenticated(const QVariantMap &)));
    QSignalSpy authenticationError(qmlObject,
        SIGNAL(authenticationError(const QVariantMap &)));

    QVariantMap sessionData;
    QVariantMap error;

    /* Delete the account service, and check that the QML object survives */
    delete accountService1;

    QCOMPARE(qmlObject->property("objectHandle").value<AccountService*>(),
             (AccountService*)0);

    /* Authenticate now: we should get an error */
    sessionData.clear();
    sessionData.insert("test", QString("OK"));
    QMetaObject::invokeMethod(qmlObject, "authenticate",
                              Q_ARG(QVariantMap, sessionData));
    QTest::qWait(50);

    QCOMPARE(authenticationError.count(), 1);
    QCOMPARE(authenticated.count(), 0);
    error = authenticationError.at(0).at(0).toMap();
    QVERIFY(!error.isEmpty());
    QCOMPARE(error["message"].toString(), QString("Invalid AccountService"));
    authenticationError.clear();

    delete manager;
    delete qmlObject;
}

void PluginTest::testAuthenticationCancel()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->setEnabled(true);
    account1->setDisplayName("CoolAccount");
    account1->selectService(coolMail);
    account1->setEnabled(true);
    account1->syncAndBlock();

    AccountService *accountService1 = new AccountService(account1, coolMail);
    QVERIFY(accountService1 != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService1", accountService1);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService { objectHandle: accountService1 }",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QSignalSpy authenticated(qmlObject,
                             SIGNAL(authenticated(const QVariantMap &)));
    QSignalSpy authenticationError(qmlObject,
        SIGNAL(authenticationError(const QVariantMap &)));

    /* First, check that calling cancelAuthentication() on an idle object
     * doesn't do anything. */
    bool ok = QMetaObject::invokeMethod(qmlObject, "cancelAuthentication");
    QVERIFY(ok);

    QTest::qWait(50);
    QCOMPARE(authenticated.count(), 0);
    QCOMPARE(authenticationError.count(), 0);

    /* Now, try canceling a session. */
    QVariantMap sessionData;
    sessionData.insert("test", QString("OK"));
    QMetaObject::invokeMethod(qmlObject, "authenticate",
                              Q_ARG(QVariantMap, sessionData));
    QTest::qWait(2);
    QCOMPARE(authenticated.count(), 0);
    QCOMPARE(authenticationError.count(), 0);

    ok = QMetaObject::invokeMethod(qmlObject, "cancelAuthentication");
    QVERIFY(ok);

    QTest::qWait(50);
    QCOMPARE(authenticated.count(), 0);
    QCOMPARE(authenticationError.count(), 1);
    QVariantMap error = authenticationError.at(0).at(0).toMap();
    QVERIFY(!error.isEmpty());
    const QMetaObject *mo = qmlObject->metaObject();
    const QMetaEnum errorEnum =
        mo->enumerator(mo->indexOfEnumerator("ErrorCode"));
    QCOMPARE(error["code"].toInt(), errorEnum.keyToValue("UserCanceledError"));
    authenticationError.clear();

    delete accountService1;
    delete manager;
    delete qmlObject;
}

void PluginTest::testAuthenticationWithCredentials()
{
    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Account *account = manager->createAccount("cool");
    QVERIFY(account != 0);

    AccountService *accountService = new AccountService(account, coolMail);
    QVERIFY(accountService != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService", accountService);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService {\n"
                      " id: account\n"
                      " autoSync: false\n"
                      " objectHandle: accountService\n"
                      " credentials: Credentials {\n"
                      "  objectName: \"creds\"\n"
                      "  userName: \"Happy user\"\n"
                      "  caption: account.provider.displayName\n"
                      " }\n"
                      "}",
                      QUrl());
    QObject *qmlAccount = component.create();
    QVERIFY(qmlAccount != 0);

    QSignalSpy authenticated(qmlAccount,
                             SIGNAL(authenticated(const QVariantMap &)));
    QSignalSpy authenticationError(qmlAccount,
        SIGNAL(authenticationError(const QVariantMap &)));

    QObject *qmlCredentials = qmlAccount->findChild<QObject*>("creds");
    QVERIFY(qmlCredentials != 0);

    /* Store the credentials */
    QSignalSpy synced(qmlCredentials, SIGNAL(synced()));
    bool ok;
    ok = QMetaObject::invokeMethod(qmlCredentials, "sync");
    QVERIFY(ok);

    /* Wait for the operation to finish, and verify it succeeded */
    QTest::qWait(100);
    QCOMPARE(synced.count(), 1);
    synced.clear();
    uint credentialsId = qmlCredentials->property("credentialsId").toUInt();
    QVERIFY(credentialsId != 0);

    QVariantMap sessionData;
    sessionData.insert("test", QString("OK"));
    QMetaObject::invokeMethod(qmlAccount, "authenticate",
                              Q_ARG(QVariantMap, sessionData));
    QTest::qWait(50);

    QCOMPARE(authenticationError.count(), 0);
    QCOMPARE(authenticated.count(), 1);
    QVariantMap reply = authenticated.at(0).at(0).toMap();
    QVERIFY(!reply.isEmpty());
    QCOMPARE(reply["test"].toString(), QString("OK"));
    QCOMPARE(reply["host"].toString(), QString("coolmail.ex"));
    /* Check that the newly created credentials were used */
    QCOMPARE(reply["credentialsId"].toUInt(), credentialsId);
    authenticated.clear();

    delete manager;
    delete qmlAccount;
}

void PluginTest::testManagerCreate()
{
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "Account { objectHandle: Manager.createAccount(\"cool\") }",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QVariantMap provider = qmlObject->property("provider").toMap();
    QVERIFY(!provider.isEmpty());
    QCOMPARE(provider["id"].toString(), QString("cool"));
    QCOMPARE(provider["displayName"].toString(), QString("Cool provider"));
    QCOMPARE(provider["iconName"].toString(), QString("general_myprovider"));

    delete qmlObject;
}

void PluginTest::testManagerLoad()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Account *account1 = manager->createAccount("cool");
    QVERIFY(account1 != 0);

    account1->syncAndBlock();
    QVERIFY(account1->id() != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("account1id", uint(account1->id()));
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "Account { objectHandle: Manager.loadAccount(account1id) }",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QCOMPARE(qmlObject->property("accountId").toUInt(), account1->id());

    QVariantMap provider = qmlObject->property("provider").toMap();
    QVERIFY(!provider.isEmpty());
    QCOMPARE(provider["id"].toString(), QString("cool"));
    QCOMPARE(provider["displayName"].toString(), QString("Cool provider"));
    QCOMPARE(provider["iconName"].toString(), QString("general_myprovider"));

    delete manager;
    delete qmlObject;
}

void PluginTest::testAccountInvalid()
{
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "Account {}",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QVERIFY(qmlObject->property("objectHandle").value<QObject*>() == 0);
    QCOMPARE(qmlObject->property("enabled").toBool(), false);
    QCOMPARE(qmlObject->property("displayName").toString(), QString());
    QCOMPARE(qmlObject->property("accountId").toUInt(), uint(0));
    QVariantMap provider = qmlObject->property("provider").toMap();
    QVERIFY(provider.isEmpty());

    qmlObject->setProperty("objectHandle", QVariant::fromValue<QObject*>(0));
    QVERIFY(qmlObject->property("objectHandle").value<QObject*>() == 0);

    bool ok;
    ok = QMetaObject::invokeMethod(qmlObject, "updateDisplayName",
                                   Q_ARG(QString, "dummy"));
    QVERIFY(ok);
    ok = QMetaObject::invokeMethod(qmlObject, "updateEnabled",
                                   Q_ARG(bool, "true"));
    QVERIFY(ok);
    ok = QMetaObject::invokeMethod(qmlObject, "sync");
    QVERIFY(ok);
    ok = QMetaObject::invokeMethod(qmlObject, "remove");
    QVERIFY(ok);

    delete qmlObject;
}

void PluginTest::testAccount()
{
    clearDb();

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "Account { objectHandle: Manager.createAccount(\"cool\") }",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QObject *objectHandle =
        qmlObject->property("objectHandle").value<QObject*>();
    Account *account = qobject_cast<Account*>(objectHandle);
    QVERIFY(account != 0);
    QVERIFY(account->id() == 0);

    QVariantMap provider = qmlObject->property("provider").toMap();
    QVERIFY(!provider.isEmpty());
    QCOMPARE(provider["id"].toString(), QString("cool"));

    bool ok;
    ok = QMetaObject::invokeMethod(qmlObject, "updateDisplayName",
                                   Q_ARG(QString, "new name"));
    QVERIFY(ok);
    ok = QMetaObject::invokeMethod(qmlObject, "updateEnabled",
                                   Q_ARG(bool, "true"));
    QVERIFY(ok);
    ok = QMetaObject::invokeMethod(qmlObject, "sync");
    QVERIFY(ok);

    QTest::qWait(50);

    /* Check that the changes have been recorded */
    QVERIFY(account->id() != 0);
    AccountId accountId = account->id();
    QCOMPARE(qmlObject->property("accountId").toUInt(), uint(account->id()));
    QCOMPARE(qmlObject->property("displayName").toString(), QString("new name"));
    QCOMPARE(qmlObject->property("enabled").toBool(), true);

    objectHandle =
        qmlObject->property("accountServiceHandle").value<QObject*>();
    AccountService *accountService =
        qobject_cast<AccountService*>(objectHandle);
    QVERIFY(accountService != 0);

    /* Set the same account instance on the account; just to improve coverage
     * of branches. */
    ok = qmlObject->setProperty("objectHandle",
                                QVariant::fromValue<QObject*>(account));
    QVERIFY(ok);

    /* Delete the account */
    ok = QMetaObject::invokeMethod(qmlObject, "remove");
    QVERIFY(ok);

    QTest::qWait(50);

    /* Check that the account has effectively been removed */
    Manager *manager = new Manager(this);
    Account *account1 = manager->account(accountId);
    QVERIFY(account1 == 0);

    delete qmlObject;
}

void PluginTest::testCredentials()
{
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "Credentials {"
                      " userName: \"Smart User\"\n"
                      " secret: \"Valuable password\"\n"
                      " storeSecret: true\n"
                      " caption: \"Service One\"\n"
                      " acl: [ \"Me\", \"You\" ]\n"
                      " methods: {\n"
                      "  \"oauth\": [ \"one\", \"two\" ],"
                      "  \"sasl\": [ \"plain\" ]"
                      " }\n"
                      "}",
                      QUrl());
    QObject *qmlObject = component.create();
    QVERIFY(qmlObject != 0);

    QCOMPARE(qmlObject->property("userName").toString(),
             QString("Smart User"));
    QCOMPARE(qmlObject->property("secret").toString(),
             QString("Valuable password"));
    QCOMPARE(qmlObject->property("storeSecret").toBool(), true);
    QCOMPARE(qmlObject->property("caption").toString(),
             QString("Service One"));
    QStringList acl;
    acl << "Me" << "You";
    QCOMPARE(qmlObject->property("acl").toStringList(), acl);
    QVariantMap methods;
    methods.insert("oauth", QStringList() << "one" << "two");
    methods.insert("sasl", QStringList() << "plain");
    QCOMPARE(qmlObject->property("methods").toMap(), methods);
    QCOMPARE(qmlObject->property("credentialsId").toUInt(), uint(0));

    /* Set a few fields to the same values, just to increase coverage of
     * branches */
    qmlObject->setProperty("credentialsId", uint(0));
    qmlObject->setProperty("userName", "Smart User");
    qmlObject->setProperty("secret", "Valuable password");
    qmlObject->setProperty("storeSecret", true);
    qmlObject->setProperty("caption", "Service One");
    qmlObject->setProperty("methods", methods);
    qmlObject->setProperty("acl", acl);

    /* Remove the credentials; this won't do anything now */
    bool ok;
    ok = QMetaObject::invokeMethod(qmlObject, "remove");
    QVERIFY(ok);

    /* Store the credentials */
    QSignalSpy synced(qmlObject, SIGNAL(synced()));
    QSignalSpy credentialsIdChanged(qmlObject,
                                    SIGNAL(credentialsIdChanged()));
    ok = QMetaObject::invokeMethod(qmlObject, "sync");
    QVERIFY(ok);

    QTest::qWait(100);
    QCOMPARE(synced.count(), 1);
    synced.clear();
    QCOMPARE(credentialsIdChanged.count(), 1);
    credentialsIdChanged.clear();
    uint credentialsId = qmlObject->property("credentialsId").toUInt();
    QVERIFY(credentialsId != 0);

    engine.rootContext()->setContextProperty("credsId", credentialsId);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "Credentials { credentialsId: credsId }",
                      QUrl());
    QObject *qmlObject2 = component.create();
    QVERIFY(qmlObject2 != 0);

    QCOMPARE(qmlObject2->property("credentialsId").toUInt(), credentialsId);

    /* After some time, we should get the synced() signal and all fields should
     * be loaded at that point */
    QSignalSpy synced2(qmlObject2, SIGNAL(synced()));

    QTest::qWait(100);
    QCOMPARE(synced2.count(), 1);
    synced2.clear();
    QCOMPARE(qmlObject2->property("userName").toString(),
             QString("Smart User"));

    /* Set the credentialsId to 0, everything should continue to work */
    qmlObject2->setProperty("credentialsId", uint(0));
    QTest::qWait(100);
    QCOMPARE(qmlObject2->property("userName").toString(),
             QString("Smart User"));

    /* test removal of the credentials */
    QSignalSpy removed(qmlObject, SIGNAL(removed()));
    ok = QMetaObject::invokeMethod(qmlObject, "remove");
    QVERIFY(ok);

    QTest::qWait(100);
    QCOMPARE(removed.count(), 1);
    removed.clear();

    delete qmlObject2;
    delete qmlObject;
}

void PluginTest::testAccountCredentialsRemoval_data()
{
    QTest::addColumn<bool>("removeCredentials");
    QTest::addColumn<QString>("expectedUserName");
    QTest::newRow("With credentials removal") << true << QString();
    QTest::newRow("Without credentials removal") << false << QString("Happy user");
}

void PluginTest::testAccountCredentialsRemoval()
{
    QFETCH(bool, removeCredentials);
    QFETCH(QString, expectedUserName);

    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Account *account = manager->createAccount("cool");
    QVERIFY(account != 0);

    account->setEnabled(true);
    account->setDisplayName("CoolAccount");
    account->selectService(coolMail);
    account->setEnabled(true);
    account->syncAndBlock();

    quint32 accountId = account->id();
    QVERIFY(accountId != 0);

    AccountService *globalService = new AccountService(account, Service());
    QVERIFY(globalService != 0);
    AccountService *mailService = new AccountService(account, coolMail);
    QVERIFY(mailService != 0);

    QList<AccountService*> services;
    services.append(globalService);
    services.append(mailService);

    QQmlEngine engine;
    Q_FOREACH (AccountService *accountService, services) {
        engine.rootContext()->setContextProperty("accountService", accountService);
        QQmlComponent component(&engine);
        component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                          "AccountService {\n"
                          " id: account\n"
                          " objectHandle: accountService\n"
                          " credentials: Credentials {\n"
                          "  objectName: \"creds\"\n"
                          "  userName: \"Happy user\"\n"
                          "  caption: account.provider.displayName\n"
                          " }\n"
                          "}",
                          QUrl());
        QObject *qmlAccount = component.create();
        QVERIFY(qmlAccount != 0);

        QObject *qmlCredentials = qmlAccount->findChild<QObject*>("creds");
        QVERIFY(qmlCredentials != 0);

        /* Store the credentials */
        bool ok;
        ok = QMetaObject::invokeMethod(qmlCredentials, "sync");
        QVERIFY(ok);
        QTest::qWait(100);
    }

    /* And check that the credentialsId have now been written to the account*/
    uint globalCredentialsId = globalService->value("CredentialsId").toUInt();
    QVERIFY(globalCredentialsId != 0);
    uint mailCredentialsId = mailService->value("CredentialsId").toUInt();
    QVERIFY(mailCredentialsId != 0);
    QVERIFY(mailCredentialsId != globalCredentialsId);

    delete globalService;
    delete mailService;
    delete manager;

    QQmlComponent accountComponent(&engine);
    engine.rootContext()->setContextProperty("aid", accountId);
    accountComponent.setData("import Ubuntu.OnlineAccounts 0.1\n"
                             "Account {\n"
                             "  objectHandle: Manager.loadAccount(aid)\n"
                             "  function removeAccount1() {\n"
                             "    remove(Account.RemoveAccountOnly)\n"
                             "  }\n"
                             "  function removeAccount2() {\n"
                             "    remove(Account.RemoveCredentials)\n"
                             "  }\n"
                             "}",
                             QUrl());
    QObject *qmlAccount = accountComponent.create();
    QVERIFY(qmlAccount != 0);

    /* test removal of the credentials */
    QSignalSpy removed(qmlAccount, SIGNAL(removed()));
    const char *removeFunction = removeCredentials ?
        "removeAccount2" : "removeAccount1";
    bool ok = QMetaObject::invokeMethod(qmlAccount, removeFunction);
    QVERIFY(ok);

    QTest::qWait(200);
    QCOMPARE(removed.count(), 1);
    removed.clear();

    delete qmlAccount;

    /* Verify that the credentials have actually been removed if
     * removeCredentials was true, or retained if it was false. */
    QList<uint> credentials;
    credentials.append(globalCredentialsId);
    credentials.append(mailCredentialsId);

    Q_FOREACH (uint credentialsId, credentials) {
        engine.rootContext()->setContextProperty("credsId", credentialsId);
        QQmlComponent component(&engine);
        component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                          "Credentials { credentialsId: credsId }",
                          QUrl());
        QObject *qmlCredentials = component.create();
        QVERIFY(qmlCredentials != 0);

        QTest::qWait(100);
        QCOMPARE(qmlCredentials->property("userName").toString(), expectedUserName);
    }
}

void PluginTest::testAccountServiceCredentials()
{
    clearDb();

    /* Create one account */
    Manager *manager = new Manager(this);
    Service coolMail = manager->service("coolmail");
    Account *account = manager->createAccount("cool");
    QVERIFY(account != 0);

    account->setEnabled(true);
    account->setDisplayName("CoolAccount");
    account->selectService(coolMail);
    account->setEnabled(true);
    account->syncAndBlock();

    AccountService *accountService = new AccountService(account, coolMail);
    QVERIFY(accountService != 0);

    QQmlEngine engine;
    engine.rootContext()->setContextProperty("accountService", accountService);
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "AccountService {\n"
                      " id: account\n"
                      " objectHandle: accountService\n"
                      " credentials: Credentials {\n"
                      "  objectName: \"creds\"\n"
                      "  userName: \"Happy user\"\n"
                      "  caption: account.provider.displayName\n"
                      " }\n"
                      "}",
                      QUrl());
    QObject *qmlAccount = component.create();
    QVERIFY(qmlAccount != 0);

    QObject *qmlCredentials = qmlAccount->findChild<QObject*>("creds");
    QVERIFY(qmlCredentials != 0);

    /* Sanity check */
    QCOMPARE(qmlAccount->property("credentials").value<QObject*>(),
             qmlCredentials);
    QCOMPARE(qmlCredentials->property("userName").toString(),
             QString("Happy user"));
    QCOMPARE(qmlCredentials->property("caption").toString(),
             QString("Cool provider"));

    /* Store the credentials */
    QSignalSpy synced(qmlCredentials, SIGNAL(synced()));
    bool ok;
    ok = QMetaObject::invokeMethod(qmlCredentials, "sync");
    QVERIFY(ok);

    /* Wait for the operation to finish, and verify it succeeded */
    QTest::qWait(100);
    QCOMPARE(synced.count(), 1);
    synced.clear();
    uint credentialsId = qmlCredentials->property("credentialsId").toUInt();
    QVERIFY(credentialsId != 0);

    /* Verify that autoSync is true (it should always be true by default */
    QCOMPARE(qmlAccount->property("autoSync").toBool(), true);

    /* And check that the credentialsId have now been written to the account*/
    QVariantMap authData = qmlAccount->property("authData").toMap();
    QVERIFY(!authData.isEmpty());
    QCOMPARE(authData["credentialsId"].toUInt(), credentialsId);

    /* Just to increase coverage */
    qmlAccount->setProperty("credentials",
                            QVariant::fromValue<QObject*>(qmlCredentials));
    qmlAccount->setProperty("credentials", QVariant::fromValue<QObject*>(0));
    QVERIFY(qmlAccount->property("credentials").value<QObject*>() == 0);

    delete qmlAccount;
    delete accountService;
}

void PluginTest::testApplicationModel()
{
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData("import Ubuntu.OnlineAccounts 0.1\n"
                      "ApplicationModel {}",
                      QUrl());
    QObject *qmlModel = component.create();
    QVERIFY(qmlModel != 0);
    QAbstractListModel *model = qobject_cast<QAbstractListModel*>(qmlModel);
    QVERIFY(model != 0);

    QCOMPARE(model->rowCount(), 0);
    /* Retrieve a couple of invalid indexes */
    QVERIFY(!get(model, 0, "applicationId").isValid());
    QVERIFY(!get(model, -1, "applicationId").isValid());

    /* Set a valid service on the model */
    qmlModel->setProperty("service", QString("badmail"));
    QCOMPARE(model->property("service").toString(), QString("badmail"));

    QCOMPARE(model->rowCount(), 1);
    QCOMPARE(model->property("count").toInt(), 1);

    QCOMPARE(get(model, 0, "applicationId").toString(), QString("mailer"));
    QCOMPARE(get(model, 0, "displayName").toString(), QString("Easy Mailer"));
    QCOMPARE(get(model, 0, "iconName").toString(), QString("mailer-icon"));
    QCOMPARE(get(model, 0, "serviceUsage").toString(),
             QString("Mailer can retrieve your e-mails"));


    QVariant value;
    QVERIFY(QMetaObject::invokeMethod(model, "get",
                                      Q_RETURN_ARG(QVariant, value),
                                      Q_ARG(int, 0),
                                      Q_ARG(QString, "applicationId")));
    QCOMPARE(value.toString(), QString("mailer"));

    /* Get an Application from the model */
    QObject *application = get(model, 0, "application").value<QObject*>();
    QCOMPARE(application->metaObject()->className(),
             "OnlineAccounts::Application");

    /* Reset the model to an invalid service */
    qmlModel->setProperty("service", QString());
    QCOMPARE(model->rowCount(), 0);

    delete qmlModel;
}

QTEST_MAIN(PluginTest);
#include "tst_plugin.moc"
