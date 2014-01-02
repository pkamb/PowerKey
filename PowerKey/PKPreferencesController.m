//
//  PKPreferencesController.m
//  PowerKey
//
//  Created by Peter Kamb on 8/16/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import "PKPreferencesController.h"
#include <Carbon/Carbon.h>
#import "PKAppDelegate.h"
#import "PKPowerKeyEventListener.h"

@implementation PKPreferencesController

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.powerKeySelector setMenu:[self powerKeyReplacementsMenu]];
    NSMenuItem *menuItem = [[self.powerKeySelector menu] itemWithTag:[PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode];
    menuItem = (menuItem) ?: [[self.powerKeySelector menu] itemWithTag:kVK_ForwardDelete];
    [self.powerKeySelector selectItem:menuItem];
}

- (IBAction)selectPowerKeyReplacement:(id)sender
{
    NSMenuItem *selectedMenuItem = ((NSPopUpButton *)sender).selectedItem;
    [PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode = selectedMenuItem.tag;
    [[NSUserDefaults standardUserDefaults] setInteger:selectedMenuItem.tag forKey:kPowerKeyReplacementKeycodeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 User can select one of the following power key replacements.
 Set the keycode of the replacement key as the NSMenuItem's tag.
 Keycodes come from 'Events.h'
*/
- (NSMenu *)powerKeyReplacementsMenu
{
    NSMenu *powerKeyReplacements = [[NSMenu alloc] initWithTitle:@"Power Key Replacements"];
    
    NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:@"Delete" action:NULL keyEquivalent:@"⌦"];
    delete.tag = kVK_ForwardDelete;
    delete.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:delete];
    
    NSMenuItem *deadkey = [[NSMenuItem alloc] initWithTitle:@"No Action" action:NULL keyEquivalent:@""];
    deadkey.tag = 0xDEAD;
    deadkey.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:deadkey];
    
    NSMenuItem *pageUp = [[NSMenuItem alloc] initWithTitle:@"Page Up" action:NULL keyEquivalent:@""];
    pageUp.tag = kVK_PageUp;
    [powerKeyReplacements addItem:pageUp];
    
    NSMenuItem *pageDown = [[NSMenuItem alloc] initWithTitle:@"Page Down" action:NULL keyEquivalent:@""];
    pageDown.tag = kVK_PageDown;
    [powerKeyReplacements addItem:pageDown];
    
    NSMenuItem *home = [[NSMenuItem alloc] initWithTitle:@"Home" action:NULL keyEquivalent:@""];
    home.tag = kVK_Home;
    [powerKeyReplacements addItem:home];
    
    NSMenuItem *end = [[NSMenuItem alloc] initWithTitle:@"End" action:NULL keyEquivalent:@""];
    end.tag = kVK_End;
    [powerKeyReplacements addItem:end];
    
    NSMenuItem *escape = [[NSMenuItem alloc] initWithTitle:@"Escape" action:NULL keyEquivalent:@""];
    escape.tag = kVK_Escape;
    [powerKeyReplacements addItem:escape];
    
    NSMenuItem *tab = [[NSMenuItem alloc] initWithTitle:@"Tab" action:NULL keyEquivalent:@""];
    tab.tag = kVK_Tab;
    [powerKeyReplacements addItem:tab];
    
    NSMenuItem *f13 = [[NSMenuItem alloc] initWithTitle:@"F13" action:NULL keyEquivalent:@""];
    f13.tag = kVK_F13;
    [powerKeyReplacements addItem:f13];
    
    return powerKeyReplacements;
}

- (IBAction)openProjectOnGithub:(id)sender
{
    system("open https://github.com/pkamb/powerkey");
}

@end
