//
//  PKAppDelegate.h
//  PowerKey
//
//  Created by Peter Kamb on 4/23/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PKPreferencesWindowController.h"

NSString *const kPowerKeyReplacementKeycodeKey;
NSString *const kPowerKeyShouldShowPreferencesWindowWhenLaunchedKey;

@interface PKAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) PKPreferencesWindowController *preferencesWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag;

@end