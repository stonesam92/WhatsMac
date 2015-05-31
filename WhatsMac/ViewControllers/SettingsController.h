//
//  SettingsController.h
//  ChitChat
//
//  Created by Daniele Orrù on 31/05/15.
//

#import <Cocoa/Cocoa.h>
@class SettingsStore;

@interface SettingsController : NSWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName settingsStore:(SettingsStore *)settingsStore;

@end
