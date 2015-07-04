//
//  ServiceContainer.m
//  ChitChat
//
//  Created by Daniele Orrù on 31/05/15.
//

#import "ServiceContainer.h"
#import "SettingsStore.h"

@interface ServiceContainer ()

@property (nonatomic, strong, readwrite) SettingsStore *settingsStore;

@end

@implementation ServiceContainer

- (SettingsStore *)settingsStore
{
    if (!_settingsStore) {
        _settingsStore = [SettingsStore sharedInstance];
    }
    return _settingsStore;
}

@end
