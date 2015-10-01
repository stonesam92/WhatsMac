
#import "GeneralPreferencesViewController.h"
#import "AppDelegate.h"

@implementation GeneralPreferencesViewController{
}


- (id)init
{
    return [super initWithNibName:@"GeneralPreferencesView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (void)awakeFromNib {
    [_hideStatusBarIcon setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"hideStatusBarIcon"]];
}

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (IBAction)hideStatusBarIcon:(id)sender {
    
    AppDelegate *appDelegate=[[NSApplication sharedApplication] delegate];
    
    if ([sender state] == NSOnState ) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideStatusBarIcon"];
        [appDelegate removeStatusItem];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hideStatusBarIcon"];
        [appDelegate createStatusItem];
    }
}

@end
