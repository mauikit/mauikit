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

#ifndef MOCK_SIGNON_H
#define MOCK_SIGNON_H

#include <QObject>
#include <QPointer>
#include <QTimer>
#include <QVariantMap>

namespace SignOn {

class AuthSession;
typedef QPointer<AuthSession> AuthSessionP;

class Error
{
public:
    enum ErrorType {
        Unknown = 1,               /**< Catch-all for errors not distinguished
                                        by another code. */
        InternalServer = 2,        /**< Signon Daemon internal error. */
        InternalCommunication = 3, /**< Communication with Signon Daemon
                                     error. */
        PermissionDenied = 4,      /**< The operation cannot be performed due to
                                        insufficient client permissions. */
        EncryptionFailure,         /**< Failure during data
                                     encryption/decryption. */
        AuthServiceErr = 100,           /* Placeholder to rearrange enumeration
                                         - AuthService specific */
        MethodNotKnown,            /**< The method with this name is not
                                     found. */
        ServiceNotAvailable,       /**< The service is temporarily
                                     unavailable. */
        InvalidQuery,              /**< Parameters for the query are invalid. */
        IdentityErr = 200,              /* Placeholder to rearrange enumeration
                                         - Identity specific */
        MethodNotAvailable,        /**< The requested method is not available. */
        IdentityNotFound,          /**< The identity matching this Identity
                                     object was not found on the service. */
        StoreFailed,               /**< Storing credentials failed. */
        RemoveFailed,              /**< Removing credentials failed. */
        SignOutFailed,             /**< SignOut failed. */
        IdentityOperationCanceled, /**< Identity operation was canceled by
                                     user. */
        CredentialsNotAvailable,   /**< Query failed. */
        ReferenceNotFound,         /**< Trying to remove nonexistent
                                     reference. */
        AuthSessionErr = 300,      /* Placeholder to rearrange enumeration
                                     - AuthSession/AuthPluginInterface
                                     specific */
        MechanismNotAvailable,     /**< The requested mechanism is not
                                     available. */
        MissingData,               /**< The SessionData object does not contain
                                        necessary information. */
        InvalidCredentials,        /**< The supplied credentials are invalid for
                                        the mechanism implementation. */
        NotAuthorized,             /**< Authorization failed. */
        WrongState,                /**< An operation method has been called in
                                        a wrong state. */
        OperationNotSupported,     /**< The operation is not supported by the
                                        mechanism implementation. */
        NoConnection,              /**< No Network connetion. */
        Network,                   /**< Network connetion failed. */
        Ssl,                       /**< Ssl connection failed. */
        Runtime,                   /**< Casting SessionData into subclass
                                     failed */
        SessionCanceled,           /**< Challenge was cancelled. */
        TimedOut,                  /**< Challenge was timed out. */
        UserInteraction,           /**< User interaction dialog failed */
        OperationFailed,           /**< Temporary failure in authentication. */
        EncryptionFailed,          /**< @deprecated Failure during data
                                     encryption/decryption. */
        TOSNotAccepted,            /**< User declined Terms of Service. */
        ForgotPassword,            /**< User requested reset password
                                     sequence. */
        MethodOrMechanismNotAllowed, /**< Method or mechanism not allowed for
                                       this identity. */
        IncorrectDate,             /**< Date time incorrect on device. */
        UserErr = 400                   /* Placeholder to rearrange enumeration
                                         - User space specific */
    };

    Error() : m_type((int)Unknown), m_message(QString()) {}
    Error(const Error &src) :
        m_type(src.type()), m_message(src.message()) {}
    Error(int type, const QString &message = QString()):
        m_type(type), m_message(message) {}
    Error &operator=(const Error &src)
        { m_type = src.type(); m_message = src.message(); return *this; }

    virtual ~Error() {}

    void setType(int type) { m_type = type; }
    void setMessage(const QString &message) { m_message = message; }
    int type() const { return m_type; }
    QString message() const { return m_message; }

private:
    int m_type;
    QString m_message;
};

class SessionData
{
public:
    SessionData(const QVariantMap &data = QVariantMap()) { m_data = data; }
    SessionData(const SessionData &other) { m_data = other.m_data; }
    SessionData &operator=(const SessionData &other) {
        m_data = other.m_data;
        return *this;
    }

    QVariantMap toMap() const { return m_data; }

protected:
    QVariantMap m_data;
};

typedef QString MethodName;
typedef QStringList MechanismsList;
class IdentityInfoImpl;
class IdentityInfo
{
public:
    enum CredentialsType {
        Other = 0,
        Application = 1 << 0,
        Web = 1 << 1,
        Network = 1 << 2
    };
public:
    IdentityInfo();
    IdentityInfo(const IdentityInfo &other);
    IdentityInfo &operator=(const IdentityInfo &other);
    ~IdentityInfo();

    void setId(const quint32 id);
    quint32 id() const;

    void setSecret(const QString &secret, const bool storeSecret = true);
    QString secret() const;

    bool isStoringSecret() const;
    void setStoreSecret(const bool storeSecret);

    void setUserName(const QString &userName);
    const QString userName() const;

    void setCaption(const QString &caption);
    const QString caption() const;

    void setRealms(const QStringList &realms);
    QStringList realms() const;

    void setOwner(const QString &ownerToken);
    QString owner() const;

    void setAccessControlList(const QStringList &accessControlList);
    QStringList accessControlList() const;

    void setMethod(const MethodName &method,
                   const MechanismsList &mechanismsList);
    void removeMethod(const MethodName &method);

    void setType(CredentialsType type);
    CredentialsType type() const;

    QList<MethodName> methods() const;
    MechanismsList mechanisms(const MethodName &method) const;

private:
    class IdentityInfoImpl *impl;
};

class Identity: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Identity)

protected:
    Identity(const quint32 id = 0, QObject *parent = 0);

public:
    static Identity *newIdentity(const IdentityInfo &info = IdentityInfo(),
                                 QObject *parent = 0);
    static Identity *existingIdentity(const quint32 id, QObject *parent = 0);
    virtual ~Identity();

    AuthSessionP createSession(const QString &methodName);
    void storeCredentials(const IdentityInfo &info = IdentityInfo());
    void remove();
    void queryInfo();

Q_SIGNALS:
    void error(const SignOn::Error &err);
    void credentialsStored(const quint32 id);
    void info(const SignOn::IdentityInfo &info);
    void removed();

private Q_SLOTS:
    void emitCredentialsStored();
    void emitInfo();
    void emitRemoved();

private:
    static quint32 lastId;
    quint32 m_id;
    IdentityInfo m_info;
    QTimer m_storeTimer;
    QTimer m_infoTimer;
    QTimer m_removeTimer;
};

class AuthSession: public QObject
{
    Q_OBJECT

    friend class Identity;
protected:
    AuthSession(quint32 id, const QString &methodName, QObject *parent = 0);
    ~AuthSession();

public:
    void process(const SessionData &sessionData,
                 const QString &mechanism = QString());
    void cancel();

Q_SIGNALS:
    void error(const SignOn::Error &err);
    void response(const SignOn::SessionData &sessionData);

private Q_SLOTS:
    void respond();

private:
    quint32 m_id;
    QString m_method;
    QString m_mechanism;
    QVariantMap m_sessionData;
    QTimer responseTimer;
};

}; // namespace

Q_DECLARE_METATYPE(SignOn::Error)
Q_DECLARE_METATYPE(SignOn::IdentityInfo)
Q_DECLARE_METATYPE(SignOn::SessionData)

#endif // MOCK_SIGNON_H
