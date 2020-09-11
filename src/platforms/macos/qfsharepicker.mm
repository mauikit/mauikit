#import "qfsharepicker.h"
#include <QtCore>

/**
brief The private methods and properties of QfSharePicker class. *
author Andrew Shapovalov*/
interface QfSharePicker () <NSSharingServicePickerDelegate, NSSharingServiceDelegate>
/** Sharing service picker.*/

property (nonatomic, retain) NSSharingServicePicker* picker;

/** Block of code to select item.*/
property (nonatomic, copy) QfSharePickerItemClicked onItemClicked;

(instancetype)initWithView:(NSView)view frame:(NSRect)frame datasArray:(NSArray*)datas

  onItemClicked:(QfSharePickerItemClicked)
{

self = [super init];
if(self)
{
self.onItemClicked = block;
self.picker = [[NSSharingServicePicker alloc] initWithItems: datas];
self.picker.delegate = self;
[self.picker showRelativeToRect:frame ofView:view preferredEdge:NSMinXEdge];
}
return self;
}


(void)sharingServicePicker:(NSSharingServicePicker )sharingServicePicker didChooseSharingService:(NSSharingService)service {

if(self.picker == sharingServicePicker)
{
if(self.onItemClicked)
{
self.onItemClicked(service);
}
}
}

(id <NSSharingServiceDelegate>)sharingServicePicker:(NSSharingServicePicker )sharingServicePicker delegateForSharingService:(NSSharingService)sharingService {

Q_UNUSED(sharingService);
if(self.picker == sharingServicePicker)
{
}
return self;
}

(void)sharingService:(NSSharingService )sharingService willShareItems:(NSArray)items {

Q_UNUSED(sharingService);
Q_UNUSED(items);
//Some code here
}

(void)sharingService:(NSSharingService )sharingService didFailToShareItems:(NSArray)items error:(NSError )error {

Q_UNUSED(sharingService);
Q_UNUSED(items);
Q_UNUSED(error);
//Some code here
}

(void)sharingService:(NSSharingService)sharingService didShareItems:(NSArray )items {

Q_UNUSED(sharingService);
Q_UNUSED(items);
//Some code here
}

(void)dealloc {

[super dealloc];
[self.picker autorelease];
[self.onItemClicked release];
self.onItemClicked = nil;
}

