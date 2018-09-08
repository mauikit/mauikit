/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

#ifndef NOTIFY_H
#define NOTIFY_H

#include <QObject>
#include <QByteArray>

#include <klocalizedstring.h>
#include <knotifyconfig.h>
#include <knotification.h>

#include <QStandardPaths>
#include <QPixmap>
#include <QDebug>
#include <QMap>

class Notify : public QObject
{
    Q_OBJECT

public:
    explicit Notify(QObject *parent = nullptr);
    ~Notify();
    void notify(const QString &title, const QString &body);

private:

};

#endif // NOTIFY_H
