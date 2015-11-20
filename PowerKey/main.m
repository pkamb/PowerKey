//
//  main.m
//  PowerKey
//
//  Created by Peter Kamb on 4/23/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PKAppDelegate.h"

int main(int argc, char *argv[])
{    
    PKAppDelegate *delegate = [[PKAppDelegate alloc] init];
    [[NSApplication sharedApplication] setDelegate:delegate];
    [NSApp run];
}
