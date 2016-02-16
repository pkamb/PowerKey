//
//  PKPreferencesWindowController.h
//  PowerKey
//
//  Created by Peter Kamb on 8/16/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

const NSInteger kPowerKeyDeadKeyTag;
const NSInteger kPowerKeyScriptTag;

@interface PKPreferencesWindowController : NSWindowController<NSOpenSavePanelDelegate>

@property (nonatomic, retain) IBOutlet NSPopUpButton *powerKeySelector;
@property (nonatomic, retain) IBOutlet NSTextField *versionNumberLabel;

- (IBAction)didSelectPowerKeyReplacement:(id)sender;

- (IBAction)openSupportLink:(id)sender;

- (NSURL *)applicationSupportDirectory;
- (void)copyBundleResourceToSupportDirectory:(NSString *)resource withExtension:(NSString *)extension;

@end
