include(../common-project-config.pri)
include($${TOP_SRC_DIR}/common-vars.pri)
include($${TOP_SRC_DIR}/common-installs-config.pri)

TARGET = tst_plugin

CONFIG += \
    debug \
    link_pkgconfig

QT += \
    core \
    qml \
    testlib

PKGCONFIG += \
    accounts-qt5

SOURCES += \
    tst_plugin.cpp

INCLUDEPATH += \
    $$TOP_SRC_DIR/src

DATA_PATH = $${TOP_SRC_DIR}/tests/data/

DEFINES += \
    TEST_DATA_DIR=\\\"$$DATA_PATH\\\"

check.commands = "LD_LIBRARY_PATH=mock:${LD_LIBRARY_PATH} xvfb-run -a dbus-test-runner -m 120 -t ./$${TARGET}"
check.depends = $${TARGET}
QMAKE_EXTRA_TARGETS += check
