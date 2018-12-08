#!/bin/bash

apt-get --yes update
apt-get --yes install wget gnupg2

### Add KDENeon Repository
echo 'deb http://archive.neon.kde.org/dev/stable/ bionic main' | tee /etc/apt/sources.list.d/neon-stable.list
wget -qO - 'http://archive.neon.kde.org/public.key' | apt-key add -

### Install Dependencies
apt-get --yes update
apt-get --yes dist-upgrade
apt-get --yes install devscripts lintian build-essential automake autotools-dev equivs qt5-default qtdeclarative5-dev qtquickcontrols2-5-dev qtwebengine5-dev cmake debhelper extra-cmake-modules libkf5i18n-dev libkf5kio-dev libkf5notifications-dev libkf5solid-dev libqt5svg5-dev ninja-build qtbase5-dev qml-module-org-kde-kirigami2 qml-module-qtquick-controls2 qml-module-qtwebengine pdebuild
wget https://raw.githubusercontent.com/lnxslck/home/master/nitrux/qml-module-qmltermwidget_0.1%2Bgit20180903-1_amd64.deb -O qml-module-qmltermwidget_0.1%2Bgit20180903-1_amd64.deb
dpkg -i qml-module-qmltermwidget_0.1%2Bgit20180903-1_amd64.deb
mk-build-deps -i -t "apt-get --yes" -r

### Build Deb
mkdir source
mv ./* source/ # Hack for debuild
cd source
debuild -b -uc -us
