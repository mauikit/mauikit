#ifndef SYNTAXHIGHLIGHTERUTIL_H
#define SYNTAXHIGHLIGHTERUTIL_H

#include <QObject>

namespace KSyntaxHighlighting {
    class Repository;
}

class SyntaxHighlighterUtil: public QObject {
  Q_OBJECT

  private:
    KSyntaxHighlighting::Repository *repo = nullptr;

  public:
    SyntaxHighlighterUtil();

  public slots:
	QStringList getLanguageNameList();
    QString getLanguageNameFromFileName(QString fileName);
};

#endif
