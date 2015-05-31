//
//  SettingsStore.m
//  ChitChat
//
//  Created by Daniele Orrù on 31/05/15.
//

#import "SettingsStore.h"

typedef NS_ENUM (NSInteger, UserDefaultKey) {
    UserDefaultKeyNotificationBadge = 1,
    UserDefaultKeyDesktopNotification,
    UserDefaultKeyUpdateFrequency,
};

@interface SettingsStore ()
    @property (nonatomic, strong) NSDictionary *keys;
@end

@implementation SettingsStore

@synthesize notificationBadge = _notificationBadge;
@synthesize desktopNotification = _desktopNotification;
@synthesize updateFrequency = _updateFrequency;

#pragma mark - Initialization

+ (void)initialize {
    // Provide some default values
    NSDictionary *appDefaults = @{
                                  [SettingsStore stringForUserDefaultKey:UserDefaultKeyNotificationBadge]: @YES,
                                  [SettingsStore stringForUserDefaultKey:UserDefaultKeyDesktopNotification]: @YES,
                                  [SettingsStore stringForUserDefaultKey:UserDefaultKeyUpdateFrequency]: @(UpdateFrequencyAtLaunch),
                                  };

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

+ (instancetype)sharedInstance {
    static SettingsStore *sharedSettingsStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettingsStore = [[self alloc] init];
    });
    return sharedSettingsStore;
}

#pragma mark - Accessors

- (BOOL)notificationBadge {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[SettingsStore stringForUserDefaultKey:UserDefaultKeyNotificationBadge]] boolValue];
}

- (void)setNotificationBadge:(BOOL)notificationBadge {
    _notificationBadge = notificationBadge;
    [[NSUserDefaults standardUserDefaults] setObject:@(notificationBadge) forKey:[SettingsStore stringForUserDefaultKey:UserDefaultKeyNotificationBadge]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)desktopNotification {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[SettingsStore stringForUserDefaultKey:UserDefaultKeyDesktopNotification]] boolValue];
}

- (void)setDesktopNotification:(BOOL)desktopNotification {
    _desktopNotification = desktopNotification;
    [[NSUserDefaults standardUserDefaults] setObject:@(desktopNotification) forKey:[SettingsStore stringForUserDefaultKey:UserDefaultKeyDesktopNotification]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UpdateFrequency)updateFrequency {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[SettingsStore stringForUserDefaultKey:UserDefaultKeyUpdateFrequency]] integerValue];
}

- (void)setUpdateFrequency:(UpdateFrequency)updateFrequency {
    _updateFrequency = updateFrequency;
    [[NSUserDefaults standardUserDefaults] setObject:@(updateFrequency) forKey:[SettingsStore stringForUserDefaultKey:UserDefaultKeyUpdateFrequency]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private Methods

+ (NSString*)stringForUserDefaultKey:(UserDefaultKey)userDefaultKey {
    NSString *result = nil;

    switch(userDefaultKey) {
        case UserDefaultKeyNotificationBadge:
            result = @"UserDefaultKeyNotificationBadge";
            break;
        case UserDefaultKeyDesktopNotification:
            result = @"UserDefaultKeyDesktopNotification";
            break;
        case UserDefaultKeyUpdateFrequency:
            result = @"UserDefaultKeyUpdateFrequency";
            break;
        default:
            NSAssert(NO, @"stringForUserDefaultKey can't find key for %ld", (long)userDefaultKey);
    }

    return result;
}

@end
