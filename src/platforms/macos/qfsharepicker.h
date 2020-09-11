#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import <Social/Social.h>

/**
typedef QfSharePickerItemClicked *
param sharingService Selected type of sharing.
 *
author Andrew Shapovelov*/
typedef void(QfSharePickerItemClicked)(NSSharingService* sharingService);



/**
class QfSharePicker
 *
brief Object to show share menu. *
author Andrew Shapovalov*/
interface QfSharePicker : NSObject /**
brief Create a new object.
 *
param view View on what will show share menu. *
param frame Rect to show share window.
 *
param datas Datas items to share. *
param block Block of code to select item.
 *
author Andrew Shapovalov*/
- (instancetype)initWithView:(NSView*)view frame:(NSRect)frame datasArray:(NSArray*)datas onItemClicked:(QfSharePickerItemClicked)block;

end

#ifdef __cplusplus
}
#endif
