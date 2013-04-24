//
//  PKAppDelegate.h
//  PowerKey
//
//  Created by Peter Kamb on 4/23/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PKAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *prefsWindow;
@property (nonatomic, retain) IBOutlet NSPopUpButton *powerKeySelector;

@property (assign) int powerKeyKeyCode;

@end