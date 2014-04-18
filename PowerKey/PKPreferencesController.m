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
    [self selectPreferredMenuItem];
}

- (void)selectPreferredMenuItem
{
    NSMenuItem *item = [[self.powerKeySelector menu] itemWithTag:[PKPowerKeyEventListener sharedEventListener].powerKeyReplacementKeyCode];
    item = (item) ?: [[self.powerKeySelector menu] itemWithTag:kVK_ForwardDelete];
    [self.powerKeySelector selectItem:item];
    if (item.tag == kPowerKeyScriptTag)
        [self updateScriptMenuItem:item];
}

- (IBAction)selectPowerKeyReplacement:(id)sender
{
    NSMenuItem *selectedMenuItem = ((NSPopUpButton *)sender).selectedItem;
    NSMenuItem *scriptMenuItem = nil;
    NSString *scriptPath;

    if (selectedMenuItem.tag == kPowerKeyScriptTag) {
        scriptMenuItem = selectedMenuItem;
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        panel.delegate = self;
        panel.canChooseFiles = YES;
        NSInteger panelResult = [panel runModal];
        if (panelResult == NSFileHandlingPanelOKButton) {
            scriptPath = ((NSURL *)[panel URLs][0]).path;
        }
        else if (panelResult == NSFileHandlingPanelCancelButton) {
            // Roll back to last option
            [self selectPreferredMenuItem];
            return;
        }
    }
    else {
        scriptPath = @"";
    }
    
    PKPowerKeyEventListener *listener = [PKPowerKeyEventListener sharedEventListener];
    listener.powerKeyReplacementKeyCode = selectedMenuItem.tag;
    listener.scriptPath = scriptPath;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:selectedMenuItem.tag forKey:kPowerKeyReplacementKeycodeKey];
    [defaults setObject:scriptPath forKey:kPowerKeyScriptPathKey];
    [defaults synchronize];
    
    [self updateScriptMenuItem:scriptMenuItem];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    NSNumber *isExecutable;
    [url getResourceValue:&isExecutable forKey:NSURLIsExecutableKey error:outError];
    return [isExecutable boolValue];
}

- (void)updateScriptMenuItem:(NSMenuItem *)item
{
    if (!item)
        item = [[self.powerKeySelector menu] itemWithTag:kPowerKeyScriptTag];
    NSString *path = [PKPowerKeyEventListener sharedEventListener].scriptPath;
    NSString *baseText = NSLocalizedString(@"Script", nil);
    item.title = [path length] ? [baseText stringByAppendingFormat:@" - %@", path] : baseText;
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
    
    NSMenuItem *deadkey = [[NSMenuItem alloc] initWithTitle:@"No Action" action:NULL keyEquivalent:@""];
    deadkey.tag = kPowerKeyDeadKeyTag;
    deadkey.keyEquivalentModifierMask = 0;
    [powerKeyReplacements addItem:deadkey];
    
    NSMenuItem *backspace = [[NSMenuItem alloc] initWithTitle:@"Delete (backspace)" action:NULL keyEquivalent:@""];
    backspace.tag = kVK_Delete;
    [powerKeyReplacements addItem:backspace];
    
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
    
    NSMenuItem *script = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Script", nil) action:NULL keyEquivalent:@""];
    script.tag = kPowerKeyScriptTag;
    [powerKeyReplacements addItem:script];
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
