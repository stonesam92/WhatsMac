#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)setActiveConversationAtIndex:(NSString*)index;
- (BOOL)shouldPropagateMouseUpEvent:(NSEvent*)theEvent;
- (BOOL)shouldPropagateMouseDraggedEvent:(NSEvent*)theEvent;

- (void)createStatusItem;
- (void)removeStatusItem;

@property (nonatomic, readonly) NSWindowController *preferencesWindowController;

@end

