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
#import "OpenAtLogin.h"

NSString *const kPowerKeyReplacementKeycodeKey = @"kPowerKeyReplacementKeycodeKey";
NSString *const kPowerKeyShouldShowPreferencesWindowWhenLaunchedKey = @"kPowerKeyShouldShowPreferencesWindowWhenLaunchedKey";

@implementation PKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDictionary *defaultPrefs = @{kPowerKeyReplacementKeycodeKey: @(kVK_ForwardDelete),
                                   kPowerKeyShouldShowPreferencesWindowWhenLaunchedKey: @YES,
                                   };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
    
    [[PKPowerKeyEventListener sharedEventListener] monitorPowerKey];
    
    self.preferencesWindowController = [[PKPreferencesWindowController alloc] initWithWindowNibName:@"PKPreferencesWindowController"];
    
    BOOL shouldShowPrefs = [[NSUserDefaults standardUserDefaults] boolForKey:kPowerKeyShouldShowPreferencesWindowWhenLaunchedKey];
    if (shouldShowPrefs || ![OpenAtLogin loginItemExists]) {
        [self.preferencesWindowController showWindow:self];
        [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    [self.preferencesWindowController showWindow:self];
    [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setBool:[self.preferencesWindowController.window isVisible] forKey:kPowerKeyShouldShowPreferencesWindowWhenLaunchedKey];
}

@end
