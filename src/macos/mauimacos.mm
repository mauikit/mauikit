#include "mauimacos.h"

#include <Cocoa/Cocoa.h>

void MAUIMacOS::removeTitlebarFromWindow(long winId)
{
 if(winId == -1)
 {
 QWindowList windows = QGuiApplication::allWindows();
 QWindow* win = windows.first();
 winId = win->winId();
 }

 NSView *nativeView = reinterpret_cast<NSView *>(winId);
 NSWindow* nativeWindow = [nativeView window];

 [nativeWindow setStyleMask:[nativeWindow styleMask] | NSFullSizeContentViewWindowMask | NSWindowTitleHidden ];
 [nativeWindow setTitlebarAppearsTransparent:YES];
 [nativeWindow setMovableByWindowBackground:YES];
}
