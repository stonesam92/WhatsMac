#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSString *notificationCount;

- (void)setActiveConversationAtIndex:(NSString*)index;

@end

