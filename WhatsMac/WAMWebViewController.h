//
//  WAMWebViewController.h
//  ChitChat
//
//  Created by Anders on 28/9/2015.
//  Copyright © 2015 Sam Stone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WKWebView+Private.h"

FOUNDATION_EXPORT NSString *const WAMWebViewUpdateUnreadCountNotification;
FOUNDATION_EXPORT NSString *const WAMWebViewNewMessageNotification;

@interface WAMWebViewController : NSViewController
@property (readonly) WKWebView *webView;
- (void)find;
- (void)newConversation;
- (void)openChat:(NSString*) identifier;
- (void)setActiveConversationAtIndex:(NSString*)index;
- (void)reload;
@end
