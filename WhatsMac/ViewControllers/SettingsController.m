//
//  SettingsController.m
//  ChitChat
//
//  Created by Daniele Orrù on 31/05/15.
//

#import "SettingsController.h"
#import "SettingsStore.h"
#import "AppDelegate.h"

@import Sparkle;

@interface SettingsController ()

@property (nonatomic, strong) SettingsStore *settingsStore;
@property (weak) IBOutlet NSButton *notificationBadgeButton;
@property (weak) IBOutlet NSButton *desktopNotificationButton;
@property (weak) IBOutlet NSPopUpButton *updateFrequencyPopUpButton;
@property (weak) IBOutlet NSButton *checkUpdateButton;
@property (weak) IBOutlet NSTextField *currentVersionTextField;
@property (weak) IBOutlet NSTextField *lastCheckUpdateTextField;

@end

@implementation SettingsController

#pragma mark - Initialization

- (instancetype)initWithWindowNibName:(NSString *)windowNibName settingsStore:(SettingsStore *)settingsStore {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.settingsStore = settingsStore;
    }
    return self;
}

#pragma mark - NSWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Positionate settingsController at the center of the screen
    CGFloat x = NSWidth(self.window.screen.frame) / 2.0 - NSWidth(self.window.frame) / 2.0;
    CGFloat y = NSHeight(self.window.screen.frame) / 2.0 - NSHeight(self.window.frame) / 2.0;
    [self.window setFrame:NSMakeRect(x, y, NSWidth(self.window.frame), NSHeight(self.window.frame)) display:YES];

    // Update UI based on settingsStore values
    _notificationBadgeButton.state = _settingsStore.notificationBadge;
    _desktopNotificationButton.state = _settingsStore.desktopNotification;
    switch (_settingsStore.updateFrequency) {
        case UpdateFrequencyAtLaunch:
            _updateFrequencyPopUpButton.state = 0;
            break;
        case UpdateFrequencyDaily:
            _updateFrequencyPopUpButton.state = 1;
            break;
        case UpdateFrequencyWeekly:
            _updateFrequencyPopUpButton.state = 2;
            break;
        case UpdateFrequencyMontly:
            _updateFrequencyPopUpButton.state = 3;
            break;
        case UpdateFrequencyNever:
            _updateFrequencyPopUpButton.state = 4;
            break;
    }
    _currentVersionTextField.stringValue = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];

    [self updateLastCheckUpdateTextFieldWithDate:[[SUUpdater sharedUpdater] lastUpdateCheckDate]];
}

#pragma mark - IBAction & UIControl

- (IBAction)notificationBadgeButtonSelector:(id)sender {
    _settingsStore.notificationBadge = (_notificationBadgeButton.state == 1);
    if (_notificationBadgeButton.state == 0) {
        [[NSApp dockTile] setBadgeLabel:@""];
    }
    else {
        AppDelegate *appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [[NSApp dockTile] setBadgeLabel: appDelegate.notificationCount];
    }
}

- (IBAction)desktopNotificationButtonSelector:(id)sender {
    _settingsStore.desktopNotification = (_desktopNotificationButton.state == 1);
    if (_desktopNotificationButton.state == 0) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    }
}

- (IBAction)updateFrequencyPopUpSelector:(id)sender {
    switch (_updateFrequencyPopUpButton.state) {
        case 0:
            _settingsStore.updateFrequency = UpdateFrequencyAtLaunch;
            break;
        case 1:
            _settingsStore.updateFrequency = UpdateFrequencyDaily;
            break;
        case 2:
            _settingsStore.updateFrequency = UpdateFrequencyWeekly;
            break;
        case 3:
            _settingsStore.updateFrequency = UpdateFrequencyMontly;
            break;
        case 4:
            _settingsStore.updateFrequency = UpdateFrequencyNever;
            break;
    }
}

- (IBAction)checkUpdateButtonSelector:(id)sender {
    [[SUUpdater sharedUpdater] checkForUpdates:sender];
    [self updateLastCheckUpdateTextFieldWithDate:[NSDate date]];
}

#pragma mark - Private Methods

- (void)updateLastCheckUpdateTextFieldWithDate:(NSDate *)date {
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        _lastCheckUpdateTextField.stringValue = [dateFormatter stringFromDate:date];
    } else {
        _lastCheckUpdateTextField.stringValue = @"Never";
    }
}

@end
