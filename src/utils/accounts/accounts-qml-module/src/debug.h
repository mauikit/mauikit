/*
 * Copyright (C) 2013-2015 Canonical Ltd.
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

#ifndef ONLINE_ACCOUNTS_DEBUG_H
#define ONLINE_ACCOUNTS_DEBUG_H

#include <QDebug>

#ifdef DEBUG_ENABLED
extern int accounts_qml_module_logging_level;
static inline bool debugEnabled() {
    return accounts_qml_module_logging_level >= 2;
}

static inline bool criticalsEnabled() {
    return accounts_qml_module_logging_level >= 1;
}
#define DEBUG() \
    if (debugEnabled()) qDebug()
#define BLAME() \
    if (criticalsEnabled()) qCritical()

#else // DEBUG_ENABLED
    #define DEBUG() while (0) qDebug()
    #define WARNING() while (0) qDebug()
#endif

namespace OnlineAccounts {

void setLoggingLevel(int level);

}

#endif // ONLINE_ACCOUNTS_DEBUG_H
