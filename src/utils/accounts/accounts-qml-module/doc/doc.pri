include(../common-installs-config.pri)

QDOC = $$[QT_INSTALL_BINS]/qdoc

QMAKE_EXTRA_TARGETS += clean-docs docs-html clean-docs-html

CONFIG(ubuntu-docs) {
    docs-html.commands = \
        "$${QDOC} $${PWD}/accounts-qml-module-ubuntu.qdocconf"
} else {
    docs-html.commands = \
        "$${QDOC} $${PWD}/accounts-qml-module.qdocconf"
}

docs.files = $$PWD/html
docs.path = $${INSTALL_PREFIX}/share/accounts-qml-module/doc
docs.depends = docs-html

INSTALLS += docs

clean-docs-html.commands = \
    "rm -rf $${PWD}/html"

clean-docs.depends = clean-docs-html

