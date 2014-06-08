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

const NSInteger kPowerKeyDeadKeyTag = 0xDEAD;
const NSInteger kPowerKeyScriptTag = 0xC0DE;

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
 Convenience method for creating a power key replacement option for the menu.
 Keycode is stored as the NSMenuItem's `tag` and come from 'Events.h'
*/
- (NSMenuItem *)powerKeyReplacementMenuItemWithTitle:(NSString *)title keyCode:(CGKeyCode)keyCode keyEquivalent:(NSString *)keyEquivalent {
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:keyEquivalent];
    menuItem.tag = keyCode;
    menuItem.keyEquivalentModifierMask = 0;
    
    return menuItem;
}

- (NSMenu *)powerKeyReplacementsMenu {
    NSMenu *powerKeyReplacements = [[NSMenu alloc] initWithTitle:@"Power Key Replacements"];
    
    // User can select one of the following power key replacements.
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Delete" keyCode:kVK_ForwardDelete keyEquivalent:@"⌦"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"No Action" keyCode:kPowerKeyDeadKeyTag keyEquivalent:@""]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Delete (backspace)" keyCode:kVK_Delete keyEquivalent:@"⌫"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Page Up" keyCode:kVK_PageUp keyEquivalent:@"⇞"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Page Down" keyCode:kVK_PageDown keyEquivalent:@"⇟"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Home" keyCode:kVK_Home keyEquivalent:@"↖︎"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"End" keyCode:kVK_End keyEquivalent:@"↘︎"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Escape" keyCode:kVK_Escape keyEquivalent:@"⎋"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Tab" keyCode:kVK_Tab keyEquivalent:@"⇥"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Return" keyCode:kVK_Return keyEquivalent:@"↩"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"F13" keyCode:kVK_F13 keyEquivalent:@""]];
    
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
