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
    
    NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:@"Delete ⌦" action:NULL keyEquivalent:@"⌦"];
    delete.tag = kVK_ForwardDelete;
    delete.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:delete];
    
    NSMenuItem *deadKey = [[NSMenuItem alloc] initWithTitle:@"No Action" action:NULL keyEquivalent:@""];
    deadKey.tag = 0xDEAD;
    deadKey.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:deadKey];
    
    NSMenuItem *backspace = [[NSMenuItem alloc] initWithTitle:@"Delete (backspace)" action:NULL keyEquivalent:@"⌫"];
    backspace.tag = kVK_Delete;
    backspace.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:backspace];
    
    NSMenuItem *pageUp = [[NSMenuItem alloc] initWithTitle:@"Page Up" action:NULL keyEquivalent:@"⇞"];
    pageUp.tag = kVK_PageUp;
    pageUp.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:pageUp];
    
    NSMenuItem *pageDown = [[NSMenuItem alloc] initWithTitle:@"Page Down" action:NULL keyEquivalent:@"⇟"];
    pageDown.tag = kVK_PageDown;
    pageDown.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:pageDown];
    
    NSMenuItem *home = [[NSMenuItem alloc] initWithTitle:@"Home" action:NULL keyEquivalent:@"↖︎"];
    home.tag = kVK_Home;
    home.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:home];
    
    NSMenuItem *end = [[NSMenuItem alloc] initWithTitle:@"End" action:NULL keyEquivalent:@"↘︎"];
    end.tag = kVK_End;
    end.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:end];
    
    NSMenuItem *escape = [[NSMenuItem alloc] initWithTitle:@"Escape" action:NULL keyEquivalent:@"⎋"];
    escape.tag = kVK_Escape;
    escape.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:escape];
    
    NSMenuItem *tab = [[NSMenuItem alloc] initWithTitle:@"Tab" action:NULL keyEquivalent:@"⇥"];
    tab.tag = kVK_Tab;
    tab.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:tab];
    
    NSMenuItem *returnKey = [[NSMenuItem alloc] initWithTitle:@"Return" action:NULL keyEquivalent:@"↩"];
    returnKey.tag = kVK_Return;
    returnKey.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:returnKey];
    
    NSMenuItem *f13 = [[NSMenuItem alloc] initWithTitle:@"F13" action:NULL keyEquivalent:@""];
    f13.tag = kVK_F13;
    f13.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:f13];
    
    return powerKeyReplacements;
}

- (IBAction)openProjectOnGithub:(id)sender
{
    system("open https://github.com/pkamb/powerkey");
}

- (IBAction)openMavericksFixExplanation:(id)sender
{
    system("open https://github.com/pkamb/PowerKey#additional-steps-for-os-x-109-mavericks");
}

@end
