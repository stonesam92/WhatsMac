#import "AppDelegate.h"
#import "WAMWebViewController.h"

@import WebKit;
@import Sparkle;
@import AppKit;

NSUInteger const WAMWindowToolbarHeight = 38;

@interface AppDelegate () <NSWindowDelegate, NSUserNotificationCenterDelegate>
@property (strong, nonatomic) NSWindow *window;
@property (strong, nonatomic) WAMWebViewController *webViewController;
@property (strong, nonatomic) NSString *notificationCount;
@property (strong, nonatomic) NSView* titlebarView;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak, nonatomic) NSWindow *legal;
@property (weak, nonatomic) NSWindow *faq;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSInteger windowStyleFlags = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask | NSFullSizeContentViewWindowMask;
    _notificationCount = @"";

    _window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 800, 600)
                                          styleMask:windowStyleFlags
                                            backing:NSBackingStoreBuffered
                                              defer:YES];
    _window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    _window.backgroundColor = [NSColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.0];
    _window.titleVisibility = NSWindowTitleHidden;
    _window.titlebarAppearsTransparent = YES;
    _window.releasedWhenClosed = NO;
    _window.minSize = CGSizeMake(600, 400);
    _window.delegate = self;
    _window.frameAutosaveName = @"main";
    _window.movableByWindowBackground = YES;
    _window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
    [_window center];
    
    _titlebarView = [_window standardWindowButton:NSWindowCloseButton].superview;
    [self updateWindowTitlebar];
  
    _webViewController = [[WAMWebViewController alloc] initWithNibName:nil bundle:nil];

    // NSWindow.contentViewController has undocumented side effects.
    // So NSWindow.contentView is used intead.
    _window.contentView = _webViewController.view;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNotificationCount:) name:WAMWebViewUpdateUnreadCountNotification object:_webViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postNativeNotification:) name:WAMWebViewNewMessageNotification object:_webViewController];
  
    [self createStatusItem];
  
    [_window makeKeyAndOrderFront:self];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate: self];
    
    [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
}


- (void)createStatusItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [self.statusItem.button setImage:[NSImage imageNamed:@"statusIconRead"]];
    self.statusItem.action = @selector(showAppWindow:);
}


- (void)showAppWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    [self.window makeKeyAndOrderFront:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.window makeKeyAndOrderFront:self];
    return YES;
}

- (void)windowDidResize:(NSNotification *)notification {
    [self updateWindowTitlebar];
}

- (NSWindow*)legal {
    if (!_legal) {
        _legal = [self createWindow:@"legal" title:@"Legal" URL:@"https://www.whatsapp.com/legal/"];
    }
    return _legal;
}

- (NSWindow*)faq {
    if (!_faq) {
        _faq = [self createWindow:@"faq" title:@"FAQ" URL:@"http://www.whatsapp.com/faq/web"];
    }
    return _faq;
}

- (void)setNotificationCount:(NSNotification *)notification {
    NSString* notificationCount = [notification.userInfo valueForKey:@"count"];
    if (![_notificationCount isEqualToString:notificationCount]) {
        [[NSApp dockTile] setBadgeLabel:notificationCount];
        
        NSInteger badgeCount = notificationCount.integerValue;
        
        if (badgeCount) {
            [self.statusItem.button setImage:[NSImage imageNamed:@"statusIconUnread"]];
        }
        else {
            [self.statusItem.button setImage:[NSImage imageNamed:@"statusIconRead"]];
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        }
    }
    _notificationCount = notificationCount;
}

- (void)postNativeNotification:(NSNotification *)notificaiton {
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = [notificaiton.userInfo valueForKey:@"title"];
    notification.subtitle = [notificaiton.userInfo valueForKey:@"subtitle"];
    notification.identifier = [notificaiton.userInfo valueForKey:@"tag"];
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}

#pragma mark MenuBar Actions
- (IBAction)find:(NSMenuItem*)sender {
    [self.webViewController find];
}

- (IBAction)newConversation:(NSMenuItem*)sender {
    [self.webViewController newConversation];
}

- (IBAction)reloadPage:(id)sender {
  [self.webViewController reload];
}

- (IBAction)showLegal:(id)sender {
    [self.legal makeKeyAndOrderFront:self];
}

- (IBAction)showFAQ:(id)sender {
    [self.faq makeKeyAndOrderFront:self];
}
# pragma mark NSUserNotificationCenter Delegate Methods

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
  [self.webViewController openChat:notification.identifier];
  [center removeDeliveredNotification:notification];
}

# pragma mark Utils
- (void)updateWindowTitlebar {
    const CGFloat kTitlebarHeight = WAMWindowToolbarHeight;
    const CGFloat kFullScreenButtonYOrigin = 3;
    CGRect windowFrame = _window.frame;
    BOOL fullScreen = (_window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask;
    
    // Set size of titlebar container
    NSView *titlebarContainerView = _titlebarView.superview;
    CGRect titlebarContainerFrame = titlebarContainerView.frame;
    titlebarContainerFrame.origin.y = windowFrame.size.height - kTitlebarHeight;
    titlebarContainerFrame.size.height = kTitlebarHeight;
    titlebarContainerView.frame = titlebarContainerFrame;
    
    // Set position of window buttons
    CGFloat buttonX = 12; // initial LHS margin, matching Safari 8.0 on OS X 10.10.
    NSView *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    NSView *minimizeButton = [self.window standardWindowButton:NSWindowMiniaturizeButton];
    NSView *zoomButton = [self.window standardWindowButton:NSWindowZoomButton];
    for (NSView *buttonView in @[closeButton, minimizeButton, zoomButton]){
        CGRect buttonFrame = buttonView.frame;
        
        // in fullscreen, the titlebar frame is not governed by kTitlebarHeight but rather appears to be fixed by the system.
        // thus, we set a constant Y origin for the buttons when in fullscreen.
        buttonFrame.origin.y = fullScreen ?
        kFullScreenButtonYOrigin :
        round((kTitlebarHeight - buttonFrame.size.height) / 2.0);
        
        buttonFrame.origin.x = buttonX;
        
        // spacing for next button, matching Safari 8.0 on OS X 10.10.
        buttonX += buttonFrame.size.width + 6;
        
        [buttonView setFrameOrigin:buttonFrame.origin];
    };
    
}

- (NSWindow*)createWindow:(NSString*)identifier title:(NSString*)title URL:(NSString*)url {
    NSUInteger windowStyle = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask | NSFullSizeContentViewWindowMask;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 1040, 800) styleMask:windowStyle backing:NSBackingStoreBuffered defer:YES];
    window.minSize = CGSizeMake(200, 100);
    [window center];
    window.frameAutosaveName = identifier;
    window.title = title;
    window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [webView setFrame:[window.contentView bounds]];
    webView.translatesAutoresizingMaskIntoConstraints = YES;
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    window.contentView = webView;
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:req];
    
    window.releasedWhenClosed = YES;
    CFBridgingRetain(window);
    return window;
}
@end
