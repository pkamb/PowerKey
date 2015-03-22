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

- (void)windowDidLoad {
    [super windowDidLoad];

    [self.powerKeySelector setMenu:[self powerKeyReplacementsMenu]];
    
    CGKeyCode replacementKeyCode = [PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode;
    NSURL *scriptURL = [PKPowerKeyEventListener sharedEventListener].scriptURL;
    
    [self selectPowerKeyReplacementKeyCode:replacementKeyCode withScriptURL:scriptURL];
}

- (IBAction)didSelectPowerKeyReplacement:(id)sender {
    NSInteger selectedKeycode = ((NSPopUpButton *)sender).selectedItem.tag;
    NSURL *selectedScriptURL = nil;

    if (selectedKeycode == kPowerKeyScriptTag) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        panel.delegate = self;
        panel.canChooseFiles = YES;
        panel.canChooseDirectories = NO;
        panel.allowsMultipleSelection = NO;
        
        NSInteger panelResult = [panel runModal];
        switch (panelResult) {
            case NSFileHandlingPanelOKButton:
                selectedScriptURL = panel.URLs.firstObject;
                break;
            case NSFileHandlingPanelCancelButton:
            default:
                // Roll back to previous selection.
                selectedKeycode = [PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode;
                selectedScriptURL = [PKPowerKeyEventListener sharedEventListener].scriptURL;
                break;
        }
    }
    
    [self selectPowerKeyReplacementKeyCode:selectedKeycode withScriptURL:selectedScriptURL];
}

- (void)selectPowerKeyReplacementKeyCode:(CGKeyCode)keyCode withScriptURL:(NSURL *)scriptURL {
    if ([self.powerKeySelector indexOfItemWithTag:keyCode] == -1) {
        keyCode = kVK_ForwardDelete;
        scriptURL = nil;
        NSAssert([self.powerKeySelector indexOfItemWithTag:keyCode] != -1, @"Could not find a default Power key replacement.");
    }
    
    [PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode = keyCode;
    [PKPowerKeyEventListener sharedEventListener].scriptURL = scriptURL;

    [[NSUserDefaults standardUserDefaults] setInteger:keyCode forKey:kPowerKeyReplacementKeycodeKey];
    if (scriptURL) {
        [[NSUserDefaults standardUserDefaults] setURL:scriptURL forKey:kPowerKeyScriptURLKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPowerKeyScriptURLKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMenuItem *scriptMenuItem = [[self.powerKeySelector menu] itemWithTag:kPowerKeyScriptTag];
    if (scriptMenuItem) {
        NSString *scriptMenuItemText = NSLocalizedString(@"Script", nil);
        if (scriptURL && scriptURL.path.length > 0) {
            scriptMenuItemText = [scriptMenuItemText stringByAppendingFormat:@" - %@", scriptURL.path];
        }
        scriptMenuItem.title = scriptMenuItemText;
    }
    
    [self.powerKeySelector selectItemWithTag:keyCode];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
    BOOL script = [[PKPowerKeyEventListener sharedEventListener] isValidScriptWithURL:url];
    BOOL appleScript = [[PKPowerKeyEventListener sharedEventListener] isValidAppleScriptWithURL:url];
    
    return script || appleScript;
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
        
    // Select one of the following Power key replacements.
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Delete" keyCode:kVK_ForwardDelete keyEquivalent:@"⌦"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"No Action" keyCode:kPowerKeyDeadKeyTag keyEquivalent:@""]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Delete (backspace)" keyCode:kVK_Delete keyEquivalent:@"⌫"]];
    
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Page Up" keyCode:kVK_PageUp keyEquivalent:@"⇞"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Page Down" keyCode:kVK_PageDown keyEquivalent:@"⇟"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Home" keyCode:kVK_Home keyEquivalent:@"↖︎"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"End" keyCode:kVK_End keyEquivalent:@"↘︎"]];
    
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Help" keyCode:kVK_Help keyEquivalent:@""]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Clear" keyCode:kVK_ANSI_KeypadClear keyEquivalent:@""]];

    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Escape" keyCode:kVK_Escape keyEquivalent:@"⎋"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Tab" keyCode:kVK_Tab keyEquivalent:@"⇥"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Return" keyCode:kVK_Return keyEquivalent:@"↩"]];
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"F13" keyCode:kVK_F13 keyEquivalent:@""]];
    
    [powerKeyReplacements addItem:[self powerKeyReplacementMenuItemWithTitle:@"Script" keyCode:kPowerKeyScriptTag keyEquivalent:@""]];
    
    return powerKeyReplacements;
}

- (IBAction)openProjectOnGithub:(id)sender {
    system("open https://github.com/pkamb/powerkey");
}

- (IBAction)openMavericksFixExplanation:(id)sender {
    system("open https://github.com/pkamb/PowerKey#additional-steps-for-os-x-109-mavericks");
}

@end
