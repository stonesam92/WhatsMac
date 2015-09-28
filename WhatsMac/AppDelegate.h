#import <Cocoa/Cocoa.h>
#import "WAMWebViewController.h"

FOUNDATION_EXPORT NSUInteger const WAMWindowToolbarHeight;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property(readonly) WAMWebViewController* webViewController;

@end

