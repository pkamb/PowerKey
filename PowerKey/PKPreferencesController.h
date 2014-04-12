//
//  PKPreferencesController.h
//  PowerKey
//
//  Created by Peter Kamb on 8/16/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PKPreferencesController : NSWindowController

@property (nonatomic, retain) IBOutlet NSPopUpButton *powerKeySelector;

- (IBAction)selectPowerKeyReplacement:(id)sender;
- (NSMenu *)powerKeyReplacementsMenu;
- (IBAction)openProjectOnGithub:(id)sender;
- (IBAction)openMavericksFixExplanation:(id)sender;

@end
