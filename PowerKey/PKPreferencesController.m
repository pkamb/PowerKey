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
 User can select one of the following power key replacements
 Save the keycode of the replacement key as the NSMenuItem's tag
 Keycodes come from 'Events.h'
*/
- (NSMenu *)powerKeyReplacementsMenu
{
    NSMenu *powerKeyOptions = [[NSMenu alloc] initWithTitle:@"Power Key Replacements"];
    
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
