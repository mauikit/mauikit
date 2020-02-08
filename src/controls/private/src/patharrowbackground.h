#ifndef PATHARROWBACKGROUND_H
#define PATHARROWBACKGROUND_H

#include <QQuickPaintedItem>

class PathArrowBackground : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QColor color MEMBER m_color NOTIFY colorChanged)
    Q_PROPERTY(int arrowWidth MEMBER m_arrowWidth NOTIFY arrowWidthChanged)

public:
    PathArrowBackground(QQuickItem *parent = 0);

Q_SIGNALS:
    void colorChanged();
    void arrowWidthChanged();

protected:
    void paint(QPainter *painter) override;

private:
    QColor m_color;
    int m_arrowWidth;
};

#endif // PATHARROWBACKGROUND_H
