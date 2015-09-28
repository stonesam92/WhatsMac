//
//  WAMWebViewController.m
//  ChitChat
//
//  Created by Anders on 28/9/2015.
//  Copyright © 2015 Sam Stone. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "WAMWebViewController.h"
#import "WAMApplication.h"
#import "WKWebView+Private.h"
#import "WAMWebView.h"
#import "AppDelegate.h"
#import "NSLabel.h"

NSString *const WAMWebViewUpdateUnreadCountNotification = @"WAMWebViewUpdateUnreadCountNotification";
NSString *const WAMWebViewNewMessageNotification = @"WAMWebViewNewMessageNotification";

@interface WAMWebViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (strong, nonatomic) WKWebView* webView;
@property (strong, nonatomic) NSButton* toggleForNewConversation;
@property (strong, nonatomic) NSLabel* conversationTitle;
@property (strong, nonatomic) NSLabel* conversationSubtitle;
@property (strong, nonatomic) NSImage* conversationIcon;
@property (strong, nonatomic) NSView* conversationViewBorder;
@property (strong, nonatomic) NSView* webViewBorder;

@end

@implementation WAMWebViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  return self;
}

#pragma mark View Configuration

- (void)loadView {
  self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  [self.view setAutoresizingMask: NSViewWidthSizable |  NSViewHeightSizable];
  [self.view setWantsLayer:YES];
  
  _webView = [[WAMWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                 configuration:[self webViewConfig]];
  _webView.translatesAutoresizingMaskIntoConstraints = NO;
  [_webView setWantsLayer:YES];
  [self.view addSubview:_webView];
  
  /// Border
  _webViewBorder = [NSView new];
  _webViewBorder.translatesAutoresizingMaskIntoConstraints = NO;
  [_webViewBorder setWantsLayer:YES];
  [_webViewBorder.layer setBackgroundColor:[[NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.08] CGColor]];
  [self.view addSubview:_webViewBorder];
  
  /// New Conversation Toggle
  
  _toggleForNewConversation = [NSButton new];
  [_toggleForNewConversation setButtonType:NSToggleButton];
  [_toggleForNewConversation setImage:[NSImage imageNamed:NSImageNameAddTemplate]];
  [_toggleForNewConversation setAlternateImage:[NSImage imageNamed:NSImageNameGoLeftTemplate]];
  _toggleForNewConversation.bezelStyle = NSTexturedSquareBezelStyle;
  _toggleForNewConversation.translatesAutoresizingMaskIntoConstraints = NO;
  [_toggleForNewConversation setTarget:self];
  [_toggleForNewConversation setAction:@selector(newConversation)];
  [_toggleForNewConversation setHidden:YES];
  [self.view addSubview:_toggleForNewConversation];
  
  /// Conversation Labels
  NSView* backgroundView = [NSView new];
  backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:backgroundView];

  _conversationTitle = [NSLabel new];
  [_conversationTitle setText:@"test"];
  [_conversationTitle setFontSize:14.0];
  [_conversationTitle setHidden:YES];
  _conversationTitle.lineBreakMode = NSLineBreakByTruncatingTail;
  [_conversationTitle setContentCompressionResistancePriority:NSLayoutPriorityFittingSizeCompression forOrientation:NSLayoutConstraintOrientationHorizontal];
  
  _conversationSubtitle = [NSLabel new];
  [_conversationSubtitle setText:@"test subtitle."];
  [_conversationSubtitle setFontSize:9.0];
  [_conversationSubtitle setHidden:YES];
  _conversationSubtitle.lineBreakMode = NSLineBreakByTruncatingTail;
    [_conversationSubtitle setContentCompressionResistancePriority:NSLayoutPriorityFittingSizeCompression forOrientation:NSLayoutConstraintOrientationHorizontal];


  
  _conversationTitle.translatesAutoresizingMaskIntoConstraints = NO;
  _conversationSubtitle.translatesAutoresizingMaskIntoConstraints = NO;
  [backgroundView addSubview:_conversationTitle];
  [backgroundView addSubview:_conversationSubtitle];
  
  _conversationViewBorder = [NSView new];
  _conversationViewBorder.translatesAutoresizingMaskIntoConstraints = NO;
  [_conversationViewBorder setWantsLayer:YES];
  [_conversationViewBorder.layer setBackgroundColor:[[NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.08] CGColor]];
  [_conversationViewBorder setHidden:YES];
  [backgroundView addSubview:_conversationViewBorder];
  
  /// Constraints
  NSArray* hConstraints;
  NSArray* vConstraints;
  NSDictionary<NSString *, id>* dict;
  
  /// - Border & WebView
  dict = [NSDictionary dictionaryWithObjects:@[_webView, _webViewBorder] forKeys:@[@"webview", @"border"]];
  hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[border]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  [self.view addConstraints:hConstraints];

  hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webview]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%lu-[border(1)][webview]|", WAMWindowToolbarHeight] options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  [self.view addConstraints:hConstraints];
  [self.view addConstraints:vConstraints];
  
  /// - New Conversation Toggle
  dict = [NSDictionary dictionaryWithObjects:@[_toggleForNewConversation] forKeys:@[@"button"]];
  hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[button(42)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[button(24)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  [self.view addConstraints:hConstraints];
  [self.view addConstraints:vConstraints];
  
  /// - Conversation Details Container
  dict = [NSDictionary dictionaryWithObjects:@[backgroundView] forKeys:@[@"background"]];
  vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[background(%lu)]", WAMWindowToolbarHeight] options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  NSLayoutConstraint* hConstraint3a = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier: 0.62 constant:0];
  NSLayoutConstraint* hConstraint3b = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];

  [self.view addConstraints:vConstraints];
  [self.view addConstraint:hConstraint3a];
  [self.view addConstraint:hConstraint3b];
  
  /// - Conversation Details Border
  dict = [NSDictionary dictionaryWithObjects:@[_conversationViewBorder] forKeys:@[@"border"]];
  hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[border(1)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[border]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  [self.view addConstraints:hConstraints];
  [self.view addConstraints:vConstraints];
  
  /// - Labels for Conversation Details
  dict = [NSDictionary dictionaryWithObjects:@[_conversationTitle, _conversationSubtitle] forKeys:@[@"title", @"subtitle"]];
  hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[title]-15-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[title]-(0)-[subtitle]-2-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  [self.view addConstraints:hConstraints];
  [self.view addConstraints:vConstraints];
  
  hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[subtitle]-15-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:dict];
  [self.view addConstraints:hConstraints];

}

- (void)viewDidLoad {
    [super viewDidLoad];
  
  _webView.UIDelegate = self;
  _webView.navigationDelegate = self;
  [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

  //Whatsapp web only works with specific user agents
  _webView._customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12";
  
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://web.whatsapp.com"]];
  [_webView loadRequest:urlRequest];
}

#pragma mark External Actions
- (void)find {
  [self.webView evaluateJavaScript:@"activateSearchField();"
                                   completionHandler:nil];
}

- (void)newConversation {
  [self.webView evaluateJavaScript:@"newConversation();"
                                   completionHandler:nil];
}

- (void)openChat:(NSString*)identifier {
  [self.webView evaluateJavaScript:
   [NSString stringWithFormat:@"openChat(\"%@\")", identifier]
                 completionHandler:nil];
}

- (void)reload {
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://web.whatsapp.com"]];
  [self.webView loadRequest:urlRequest];
}

- (void)setActiveConversationAtIndex:(NSString*)index {
  [self.webView evaluateJavaScript:
   [NSString stringWithFormat:@"setActiveConversationAtIndex(%@)", index]
                 completionHandler:nil];
}

#pragma mark Internal Actions
- (void)webAppDidLoad {
  [_conversationViewBorder setHidden:NO];
  [_toggleForNewConversation setHidden:NO];
}

- (void)updateConversationDetailsWithTitle:(NSString*) title subTitle:(NSString*) subtitle {
  if( _conversationTitle.hidden ) {
    [_conversationTitle setHidden:NO];
    [_conversationSubtitle setHidden:NO];
  }
  
  _conversationTitle.text = title;
  _conversationSubtitle.text = subtitle;
}

- (void)updateConversationSubtitle:(NSString*) subtitle {
  _conversationSubtitle.text = subtitle;
}

#pragma mark Internal Utils

- (void)showFailedConnectionPage {
  NSURL *failedPageURL = [[NSBundle mainBundle] URLForResource:@"noConnection" withExtension:@"html"];
  NSURLRequest *failedPageRequest = [NSURLRequest requestWithURL:failedPageURL];
  [self.webView loadRequest:failedPageRequest];
}

- (WKWebViewConfiguration*)webViewConfig {
  WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
  WKUserContentController *contentController = [[WKUserContentController alloc] init];
  // inject js into webview
  NSURL *pathToJS = [[NSBundle mainBundle] URLForResource:@"inject" withExtension:@"js"];
  NSString *injectedJS = [NSString stringWithContentsOfURL:pathToJS encoding:NSUTF8StringEncoding error:nil];
  WKUserScript *userScript = [[WKUserScript alloc] initWithSource:injectedJS
                                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                 forMainFrameOnly:NO];
  NSURL *jqueryURL = [[NSBundle mainBundle] URLForResource:@"jquery" withExtension:@"js"];
  NSString *jquery = [NSString stringWithContentsOfURL:jqueryURL encoding:NSUTF8StringEncoding error:nil];
  WKUserScript *jqueryUserScript = [[WKUserScript alloc] initWithSource:jquery
                                                          injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
  [contentController addUserScript:jqueryUserScript];
  [contentController addUserScript:userScript];
  [contentController addScriptMessageHandler:self name:@"notification"];
  config.userContentController = contentController;
  
#if DEBUG
  [config.preferences setValue:@YES forKey:@"developerExtrasEnabled"];
#else
  WKUserScript *noRightClickJS = [[WKUserScript alloc] initWithSource:
                                  @"document.addEventListener('contextmenu',"
                                  "function(event) {"
                                  "event.preventDefault();"
                                  "});"
                                                        injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                     forMainFrameOnly:NO];
  [contentController addUserScript:noRightClickJS];
#endif
  return config;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  NSString *title = change[NSKeyValueChangeNewKey];
  if ([title isEqualToString:@"WhatsApp Web"]) {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"" forKey:@"count"];
    [[NSNotificationCenter defaultCenter] postNotificationName:WAMWebViewUpdateUnreadCountNotification object:self userInfo:userInfo];
  } else {
    NSRegularExpression* regex =
    [NSRegularExpression regularExpressionWithPattern:@"\\(([0-9]+)\\) WhatsApp Web"
                                              options:0
                                                error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:title
                                                    options:0
                                                      range:NSMakeRange(0, title.length)];
    if (match) {
      NSString* count = [title substringWithRange:[match rangeAtIndex:1]];
      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:count forKey:@"count"];
      [[NSNotificationCenter defaultCenter] postNotificationName:WAMWebViewUpdateUnreadCountNotification object:self userInfo:userInfo];
    }
  }
}

#pragma mark WKNavigationDelegate methods

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [_toggleForNewConversation setEnabled:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  NSURL *url = navigationAction.request.URL;
  
  if ([url.host hasSuffix:@"whatsapp.com"] || [url.scheme isEqualToString:@"file"]) {
    decisionHandler(WKNavigationActionPolicyAllow);
  } else if ([url.host hasSuffix:@"whatsapp.net"]) {
    decisionHandler(WKNavigationActionPolicyCancel);
    
    NSAlert *downloadMediaAlert = [[NSAlert alloc] init];
    downloadMediaAlert.messageText = @"Downloading Media";
    downloadMediaAlert.informativeText = @"To download media, please just drag and drop it from this window into Finder.";
    [downloadMediaAlert addButtonWithTitle:@"OK"];
    [downloadMediaAlert runModal];
  } else {
    decisionHandler(WKNavigationActionPolicyCancel);
    [[NSWorkspace sharedWorkspace] openURL:url];
  }
}

- (void)webView:(WKWebView*)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSLog(@"Failed navigation with error: %@", error);
  [self showFailedConnectionPage];
}

- (void)webView:(WKWebView*)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSLog(@"Failed navigation with error: %@", error);
  [self showFailedConnectionPage];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
  
  if (!navigationAction.targetFrame.isMainFrame) {
    [[NSWorkspace sharedWorkspace] openURL:navigationAction.request.URL];
  }
  
  return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = @"Uploading Media";
  alert.informativeText = message;
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
  completionHandler();
}

#pragma mark WKScriptMessageHandler delegate methods

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  NSArray *messageBody = message.body;
  NSString *messageType = messageBody[0];
  
  if( [messageType isEqualToString:@"WAMNotification"] ) {
    if ([[[self view] window] isMainWindow]) {
      return;
    }

    NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:@[messageBody[1], messageBody[2], messageBody[3]] forKeys:@[@"title", @"subtitle", @"tag"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:WAMWebViewNewMessageNotification object:self userInfo:userInfo];
    return;
  }
  
  if( [messageType isEqualToString:@"WAMConversationStatus"] ) {
    [self updateConversationSubtitle:messageBody[1]];
    return;
  }
  
  if( [messageType isEqualToString:@"WAMConversationDetails"] ) {
    [self updateConversationDetailsWithTitle:messageBody[1] subTitle:messageBody[2]];
    return;
  }

  if( [messageType isEqualToString:@"WAMWebAppLoaded"] ) {
    [self webAppDidLoad];
    return;
  }
}

@end
