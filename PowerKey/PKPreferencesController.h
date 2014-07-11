//
//  PKPreferencesController.h
//  PowerKey
//
//  Created by Peter Kamb on 8/16/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

const NSInteger kPowerKeyDeadKeyTag;
const NSInteger kPowerKeyScriptTag;
const NSInteger kPowerKeyLaunchpadTag;

@interface PKPreferencesController : NSWindowController

@property (nonatomic, retain) IBOutlet NSPopUpButton *powerKeySelector;

- (IBAction)selectPowerKeyReplacement:(id)sender;

- (NSMenuItem *)powerKeyReplacementMenuItemWithTitle:(NSString *)title keyCode:(CGKeyCode)keyCode keyEquivalent:(NSString *)keyEquivalent;
- (NSMenu *)powerKeyReplacementsMenu;

- (IBAction)openProjectOnGithub:(id)sender;
- (IBAction)openMavericksFixExplanation:(id)sender;

@end
