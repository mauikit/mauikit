#include "mauimacos.h"

#include <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>

#include <QUrl>

MAUIMacOS::MAUIMacOS(QObject *parent) : AbstractPlatform(parent)
{

}

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



void MAUIMacOS::runApp(const QString &app, const QList<QUrl> &files)
{
    CFURLRef appUrl = QUrl::fromLocalFile(app).toCFURL();

    CFMutableArrayRef cfaFiles =
        CFArrayCreateMutable(kCFAllocatorDefault,
                             files.count(),
                             &kCFTypeArrayCallBacks);
    for (const QUrl &url: files) {
        CFURLRef u = url.toCFURL();
        CFArrayAppendValue(cfaFiles, u);
        CFRelease(u);
    }

    LSLaunchURLSpec inspec;
    inspec.appURL = appUrl;
    inspec.itemURLs = cfaFiles;
    inspec.asyncRefCon = NULL;
    inspec.launchFlags = kLSLaunchDefaults + kLSLaunchAndDisplayErrors;
    inspec.passThruParams = NULL;

    OSStatus ret;
    ret = LSOpenFromURLSpec(&inspec, NULL);
    CFRelease(appUrl);
}

void MAUIMacOS::shareFiles(const QList<QUrl> &urls)
{

}

void MAUIMacOS::shareText(const QString &urls)
{

}

void MAUIMacOS::openUrl(const QUrl &url)
{

}

bool MAUIMacOS::hasKeyboard()
{

}

bool MAUIMacOS::hasMouse()
{

}

void MAUIMacOS::notify(const QString &title, const QString &message, const QString &icon, const QString &imageUrl)
{

}
