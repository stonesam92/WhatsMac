//
//  SettingsStore.h
//  ChitChat
//
//  Created by Daniele Orrù on 31/05/15.
//

#import <Foundation/Foundation.h>

/**
 * SettingsStore is a singleton that is able to persist application setting
 */
@interface SettingsStore : NSObject

typedef NS_ENUM (NSInteger, UpdateFrequency) {
    UpdateFrequencyAtLaunch = 1,
    UpdateFrequencyDaily,
    UpdateFrequencyWeekly,
    UpdateFrequencyMontly,
    UpdateFrequencyNever,
};

@property (assign, nonatomic) BOOL notificationBadge;
@property (assign, nonatomic) BOOL desktopNotification;
@property (assign, nonatomic) UpdateFrequency updateFrequency;

+ (instancetype)sharedInstance;

@end
