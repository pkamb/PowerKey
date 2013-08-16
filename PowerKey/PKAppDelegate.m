//
//  PKAppDelegate.m
//  PowerKey
//
//  Created by Peter Kamb on 4/23/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import "PKAppDelegate.h"
#include <Carbon/Carbon.h>
#include <IOKit/hidsystem/ev_keymap.h>
#import "PKPowerKeyEventListener.h"

NSString *kPowerKeyUserPrefKey = @"POWER_KEY_KEYCODE";

@implementation PKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{kPowerKeyUserPrefKey : [NSNumber numberWithInteger:kVK_ForwardDelete]}];
    
    [PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode = [[defaults objectForKey:kPowerKeyUserPrefKey] integerValue];
    [self.powerKeySelector setMenu:[self powerKeyOptions]];
    [self.powerKeySelector selectItem:[[self.powerKeySelector menu] itemWithTag:[PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode]];
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.prefsWindow makeKeyAndOrderFront:self];
    
    [[PKPowerKeyEventListener sharedEventListener] monitorPowerKey];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.prefsWindow makeKeyAndOrderFront:self];
    return NO;
}

- (IBAction)changePowerButtonFunction:(id)sender
{
    NSMenuItem *selectedMenuItem = ((NSPopUpButton *)sender).selectedItem;
    [PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode = selectedMenuItem.tag;
    [[NSUserDefaults standardUserDefaults] setInteger:selectedMenuItem.tag forKey:kPowerKeyUserPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMenu *)powerKeyOptions
{
    /*
     User can select one of the following power key replacements
     Save the keycode of the new key as the NSMenuItem's tag
     Keycodes come from 'Events.h'
     */
    
    NSMenu *powerKeyOptions = [[NSMenu alloc] initWithTitle:@"Power Key Options"];
    
    NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:@"Delete" action:NULL keyEquivalent:@""];
    delete.tag = kVK_ForwardDelete;
    delete.keyEquivalentModifierMask = 0;
    delete.keyEquivalent = @"⌦";
    [powerKeyOptions addItem:delete];
    
    NSMenuItem *pageUp = [[NSMenuItem alloc] initWithTitle:@"Page Up" action:NULL keyEquivalent:@""];
    pageUp.tag = kVK_PageUp;
    [powerKeyOptions addItem:pageUp];
    
    NSMenuItem *pageDown = [[NSMenuItem alloc] initWithTitle:@"Page Down" action:NULL keyEquivalent:@""];
    pageDown.tag = kVK_PageDown;
    [powerKeyOptions addItem:pageDown];
    
    NSMenuItem *home = [[NSMenuItem alloc] initWithTitle:@"Home" action:NULL keyEquivalent:@""];
    home.tag = kVK_Home;
    [powerKeyOptions addItem:home];
    
    NSMenuItem *end = [[NSMenuItem alloc] initWithTitle:@"End" action:NULL keyEquivalent:@""];
    end.tag = kVK_End;
    [powerKeyOptions addItem:end];
    
    NSMenuItem *escape = [[NSMenuItem alloc] initWithTitle:@"Escape" action:NULL keyEquivalent:@""];
    escape.tag = kVK_Escape;
    [powerKeyOptions addItem:escape];
    
    NSMenuItem *tab = [[NSMenuItem alloc] initWithTitle:@"Tab" action:NULL keyEquivalent:@""];
    tab.tag = kVK_Tab;
    [powerKeyOptions addItem:tab];
    
    return powerKeyOptions;
}

- (IBAction)openProjectOnGithub:(id)sender
{
    system("open https://github.com/pkamb/powerkey");
}


@end
