#!/bin/sh
#
# Copyright 2012 Canonical Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

QDOCCONF_FILE=accounts-qml-module.qdocconf
QDOC_BIN=/usr/lib/*/qt5/bin/qdoc

sed "s|docs/||" < $QDOCCONF_FILE > $QDOCCONF_FILE.tmp
$QDOC_BIN $QDOCCONF_FILE.tmp
rm $QDOCCONF_FILE.tmp
