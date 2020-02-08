#include "patharrowbackground.h"

#include <QPainter>
#include <QBrush>

PathArrowBackground::PathArrowBackground(QQuickItem *parent)
    : QQuickPaintedItem(parent)
    , m_color(Qt::white)
    , m_arrowWidth(16)
{
    connect(this, SIGNAL(colorChanged()), this, SLOT(update()));
    connect(this, SIGNAL(arrowWidthChanged()), this, SLOT(update()));
}

void PathArrowBackground::paint(QPainter *painter)
{
    QBrush brush(m_color);

    painter->setBrush(brush);
    painter->setPen(Qt::NoPen);
    painter->setRenderHint(QPainter::Antialiasing);

    const QPointF topLeftPoints[3] = {
        QPointF(boundingRect().left() - 1, 0),
        QPointF(boundingRect().left() + m_arrowWidth, 0),
        QPointF(boundingRect().left() + m_arrowWidth, boundingRect().top() + boundingRect().height() * 0.5)
    };

    const QPointF bottomLeftPoints[3] = {
        QPointF(boundingRect().left() - 1, boundingRect().bottom()),
        QPointF(boundingRect().left() + m_arrowWidth, boundingRect().bottom()),
        QPointF(boundingRect().left() + m_arrowWidth, boundingRect().top() + boundingRect().height() * 0.5)
    };

    const QPointF rightPoints[3] = {
        QPointF(boundingRect().right() - m_arrowWidth - 1, 0),
        QPointF(boundingRect().right(), boundingRect().top() + boundingRect().height() * 0.5),
        QPointF(boundingRect().right() - m_arrowWidth - 1, boundingRect().bottom()),
    };

    painter->drawConvexPolygon(topLeftPoints, 3);
    painter->drawConvexPolygon(bottomLeftPoints, 3);
    painter->drawConvexPolygon(rightPoints, 3);

    painter->drawRect(m_arrowWidth, 0, boundingRect().width() - m_arrowWidth * 2, boundingRect().height());
}
