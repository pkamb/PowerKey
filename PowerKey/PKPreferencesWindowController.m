//
//  PKPreferencesWindowController.m
//  PowerKey
//
//  Created by Peter Kamb on 8/16/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import "PKPreferencesWindowController.h"
#include <Carbon/Carbon.h>
#import "PKAppDelegate.h"
#import "PKPowerKeyEventListener.h"
#import "PKScriptController.h"

const NSInteger kPowerKeyDeadKeyTag = 0xDEAD;
const NSInteger kPowerKeyScriptTag = 0xC0DE;

@interface PKPreferencesWindowController ()

@property (nonatomic, retain) IBOutlet NSPopUpButton *powerKeySelector;
@property (nonatomic, retain) IBOutlet NSTextField *versionNumberLabel;

- (IBAction)runInBackground:(id)sender;
- (IBAction)openSupportLink:(id)sender;

- (IBAction)didSelectPowerKeyReplacement:(id)sender;

@end

@implementation PKPreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString *versionNumber = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    self.versionNumberLabel.stringValue = [NSString stringWithFormat:@"version %@", versionNumber];
    
    [self copyBundleResourceToSupportDirectory:@"helloPowerKey" withExtension:@"sh"];
    [self copyBundleResourceToSupportDirectory:@"helloPowerKeyAppleScript" withExtension:@"scpt"];

    [self.powerKeySelector setMenu:[self powerKeyReplacementsMenu]];
    
    CGKeyCode replacementKeyCode = [[NSUserDefaults standardUserDefaults] integerForKey:kPowerKeyReplacementKeycodeKey];
    NSURL *scriptURL = [[NSUserDefaults standardUserDefaults] URLForKey:kPowerKeyScriptURLKey];
    
    [self selectPowerKeyReplacementKeyCode:replacementKeyCode withScriptURL:scriptURL];
}

- (IBAction)runInBackground:(id)sender {
    [self.window orderOut:sender];
    
    [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyAccessory];
}

- (IBAction)openSupportLink:(id)sender {
    system("open https://github.com/pkamb/powerkey#frequently-asked-questions");
}

- (NSArray *)powerKeyReplacements {
    NSArray *replacements =  @[@[@"Delete", @(kVK_ForwardDelete)],
                               @[@"No Action", @(kPowerKeyDeadKeyTag)],
                               @[@"Delete (backspace)", @(kVK_Delete)],
                               @[@"Page Up", @(kVK_PageUp)],
                               @[@"Page Down", @(kVK_PageDown)],
                               @[@"Home", @(kVK_Home)],
                               @[@"End", @(kVK_End)],
                               @[@"Help", @(kVK_Help)],
                               @[@"Clear", @(kVK_ANSI_KeypadClear)],
                               @[@"Escape", @(kVK_Escape)],
                               @[@"Tab", @(kVK_Tab)],
                               @[@"Return", @(kVK_Return)],
                               @[@"Enter", @(kVK_ANSI_KeypadEnter)],
                               @[@"F13", @(kVK_F13)],
                               @[@"Script", @(kPowerKeyScriptTag)],
                               ];
    
    return replacements;
}

- (NSMenu *)powerKeyReplacementsMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Power Key Replacements"];
    
    NSArray *replacements = [self powerKeyReplacements];
    for (NSArray *replacement in replacements) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:replacement[0] action:NULL keyEquivalent:@""];
        menuItem.tag = [replacement[1] integerValue];
        menuItem.keyEquivalentModifierMask = 0;
        
        [menu addItem:menuItem];
    }
    
    return menu;
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
        [panel setDirectoryURL:[self applicationSupportDirectory]];
        
        NSInteger panelResult = [panel runModal];
        switch (panelResult) {
            case NSFileHandlingPanelOKButton:
                selectedScriptURL = panel.URLs.firstObject;
                break;
            case NSFileHandlingPanelCancelButton:
            default:
                // Roll back to previous selection.
                selectedKeycode = [[NSUserDefaults standardUserDefaults] integerForKey:kPowerKeyReplacementKeycodeKey];
                selectedScriptURL = [[NSUserDefaults standardUserDefaults] URLForKey:kPowerKeyScriptURLKey];
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
    
    [[NSUserDefaults standardUserDefaults] setInteger:keyCode forKey:kPowerKeyReplacementKeycodeKey];
    
    if (scriptURL) {
        [[NSUserDefaults standardUserDefaults] setURL:scriptURL forKey:kPowerKeyScriptURLKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPowerKeyScriptURLKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMenuItem *scriptMenuItem = [[self.powerKeySelector menu] itemWithTag:kPowerKeyScriptTag];
    if (scriptMenuItem) {
        NSString *scriptMenuItemText = NSLocalizedString(@"Script", @"Script menu item title.");
        if (scriptURL && scriptURL.path.length > 0) {
            scriptMenuItemText = [scriptMenuItemText stringByAppendingFormat:@" - %@", scriptURL.path.lastPathComponent];
        }
        scriptMenuItem.title = scriptMenuItemText;
    }
    
    [self.powerKeySelector selectItemWithTag:keyCode];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
    BOOL script = [PKScriptController isValidScriptWithURL:url];
    BOOL appleScript = [PKScriptController isValidAppleScriptWithURL:url];
    
    return script || appleScript;
}

- (NSURL *)applicationSupportDirectory {
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *applicationSupport = [[urls firstObject] URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier] isDirectory:YES];
    
    // Create support directory, if it does not exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupport.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:applicationSupport withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return applicationSupport;
}

- (void)copyBundleResourceToSupportDirectory:(NSString *)resource withExtension:(NSString *)extension {
    NSURL *applicationSupportDirectory = [self applicationSupportDirectory];
    
    NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:resource withExtension:extension];
    NSURL *destinationURL = [applicationSupportDirectory URLByAppendingPathComponent:sourceURL.lastPathComponent];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path]) {
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtURL:sourceURL toURL:destinationURL error:&error];
        if (error) {
            NSLog(@"Error copying bundle resource to Application Support directory: %@", error);
        }
    }
}

@end
