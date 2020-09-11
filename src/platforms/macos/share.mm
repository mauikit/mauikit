#include "share.h"
#include <QtCore>

QString QfShareItem::stripHTMLTags(QString body)
{
 body.replace("<br>","");
 body.replace("</br>","");
 body.replace("</p>","");
 body.replace("</td>","");
 body.remove(QRegExp("<head>(.''')</head>"));
 body.remove(QRegExp("<form(.''')</form>"));
 body.remove(QRegExp( "<(.)[</sup>>]'''>"));

 return body.trimmed();
}

bool QfShareItem::eventFilter(QObject *obj, QEvent* event)
{
 if(obj == this)
 {
 if(parentItem())
 {
 return QObject::eventFilter(parentItem(), event);
 }
 }

return QObject::eventFilter(obj, event);
}

void QfShareItem::shareCurrentContent()
{
 QQuickItem* parentItem = this->parentItem();
 if(!m_shareString.isEmpty() && parentItem)
 {
 QRectF rect = parentItem->mapRectToItem(NULL, parentItem->boundingRect());
 NSView* view = reinterpret_cast<NSView *>(parentItem->window()->winId());
 NSRect frame = NSMakeRect(rect.x(), rect.y(), rect.width(), rect.height());

 m_shareString = m_shareString.replace("<style type=quot;text/cssquot;>a {color:#44a51c;text-decoration:none;}</style>", "");
 QString content = stripHTMLTags(m_shareString).trimmed();
 NSMutableArray* datas = [NSMutableArray arrayWithObject: content.toNSString()];
 if(!m_shareUrl.isEmpty())
 {
 NSURL* url = [NSURL URLWithString: m_shareUrl.toString().toNSString()];
 if(url)
 {
 [datas addObject: url];
 }
 }
 QfSharePicker* sharePicker = [[QfSharePicker alloc] initWithView:view frame:frame datasArray:datas onItemClicked:nil];
 [sharePicker autorelease];
 }
}

QfShareItem::QfShareItem(QQuickPaintedItem '''parent) :
 QQuickPaintedItem(parent)
{
 m_shareString.clear();
 m_shareUrl.clear();

 connect(this, &QQuickPaintedItem::parentChanged, [this](QQuickItem''' newParent){

 if(newParent)
 {
 newParent->setFiltersChildMouseEvents(true);
 }
 });
 this->installEventFilter(this);

setFlag(QQuickPaintedItem::ItemHasContents, true);
 setFlag(QQuickPaintedItem::ItemClipsChildrenToShape, true);
 setFlag(QQuickPaintedItem::ItemAcceptsDrops, true);
 setRenderTarget(QQuickPaintedItem::InvertedYFramebufferObject);
}

void QfShareItem::paint(QPainter *painter)
{
 try
 {
 Q_UNUSED(painter);
 }
 catch(std::exception& exception)
 {
 qDebug()<<"exception: "<<exception.what();
 }
}

void QfShareItem::shareContent(QString text, QUrl url)
{
 if(!text.isEmpty())
 {
 m_shareString = text;
 }

if(!url.isEmpty())
 {
 m_shareUrl = url;
 }

shareCurrentContent();
}
