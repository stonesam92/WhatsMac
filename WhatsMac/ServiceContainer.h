//
//  ServiceContainer.h
//  ChitChat
//
//  Created by Daniele Orrù on 31/05/15.
//

#import <Foundation/Foundation.h>

@class SettingsStore;

/**
 * Use the ServiceContainer to do Dependency Injection
 */
@interface ServiceContainer : NSObject

@property (nonatomic, strong, readonly) SettingsStore *settingsStore;

@end
