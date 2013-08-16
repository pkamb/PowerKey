//
//  PKAppDelegate.m
//  PowerKey
//
//  Created by Peter Kamb on 4/23/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import "PKAppDelegate.h"
#include <Carbon/Carbon.h>
#import "PKPowerKeyEventListener.h"

NSString *const kPowerKeyUserPrefKey = @"POWER_KEY_KEYCODE";

@implementation PKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{kPowerKeyUserPrefKey : [NSNumber numberWithInteger:kVK_ForwardDelete]}];
    
    [[PKPowerKeyEventListener sharedEventListener] monitorPowerKey];
    
    self.preferences = [[PKPreferencesController alloc] initWithWindowNibName:@"PKPreferencesController"];    
    [self.preferences showWindow:self];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.preferences.window makeKeyAndOrderFront:self];
    return NO;
}

@end
