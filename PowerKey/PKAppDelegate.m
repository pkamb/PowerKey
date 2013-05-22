//
//  PKAppDelegate.m
//  PowerKey
//
//  Created by Peter Kamb on 4/23/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import "PKAppDelegate.h"
#include <Carbon/Carbon.h>
#include <IOKit/hidsystem/ev_keymap.h>

@implementation PKAppDelegate

id refToSelf;
CFMachPortRef eventTap;

NSString *kPowerKeyUserPrefKey = @"POWER_KEY_KEYCODE";

- (id)init
{
    self = [super init];
    if (self) {
        refToSelf = self;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.powerKeySelector setMenu:[self powerKeyOptions]];
    
    //User's saved power key function
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:kVK_ForwardDelete] forKey:kPowerKeyUserPrefKey]];
    self.powerKeyKeyCode = [[defaults objectForKey:kPowerKeyUserPrefKey] integerValue];
    [self.powerKeySelector selectItem:[[self.powerKeySelector menu] itemWithTag:self.powerKeyKeyCode]];
    
    //Show window on launch
    [NSApp activateIgnoringOtherApps:YES];
    [self.prefsWindow makeKeyAndOrderFront:self];
    
    [self monitorPowerKey];
}

- (NSMenu *)powerKeyOptions
{
    /*
     User can select one of the following power key replacements
     Save the keycode of the new key as the NSMenuItem's tag
     Keycodes come from 'Events.h'
     */
    
    NSMenu *powerKeyOptions = [[NSMenu alloc] initWithTitle:@"Power Key Options"];
    
    NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:@"Delete" action:NULL keyEquivalent:@""];
    delete.tag = kVK_ForwardDelete;
    delete.keyEquivalentModifierMask = 0;
    delete.keyEquivalent = @"⌦";
    [powerKeyOptions addItem:delete];
    
    NSMenuItem *pageUp = [[NSMenuItem alloc] initWithTitle:@"Page Up" action:NULL keyEquivalent:@""];
    pageUp.tag = kVK_PageUp;
    [powerKeyOptions addItem:pageUp];
    
    NSMenuItem *pageDown = [[NSMenuItem alloc] initWithTitle:@"Page Down" action:NULL keyEquivalent:@""];
    pageDown.tag = kVK_PageDown;
    [powerKeyOptions addItem:pageDown];
    
    NSMenuItem *home = [[NSMenuItem alloc] initWithTitle:@"Home" action:NULL keyEquivalent:@""];
    home.tag = kVK_Home;
    [powerKeyOptions addItem:home];
    
    NSMenuItem *end = [[NSMenuItem alloc] initWithTitle:@"End" action:NULL keyEquivalent:@""];
    end.tag = kVK_End;
    [powerKeyOptions addItem:end];
    
    NSMenuItem *escape = [[NSMenuItem alloc] initWithTitle:@"Escape" action:NULL keyEquivalent:@""];
    escape.tag = kVK_Escape;
    [powerKeyOptions addItem:escape];
    
    NSMenuItem *tab = [[NSMenuItem alloc] initWithTitle:@"Tab" action:NULL keyEquivalent:@""];
    tab.tag = kVK_Tab;
    [powerKeyOptions addItem:tab];
    
    return powerKeyOptions;
}

- (void)monitorPowerKey
{
    CFRunLoopSourceRef runLoopSource;
    
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, copyEventTapCallBack, NULL);
    
    if (!eventTap) {
        exit(YES);
    }
    
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    
    CGEventTapEnable(eventTap, true);
    
    CFRelease(runLoopSource);
    CFRelease(eventTap);
}

CGEventRef copyEventTapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{        
    switch (type) {
        case kCGEventTapDisabledByTimeout:
            // Re-enable the event tap if it times out.
            CGEventTapEnable(eventTap, true);
            break;
            
        case NSSystemDefined:
            // NSSystemDefined events that are not the Power Key will be returned unmodified.
            event = [refToSelf newPowerKeyEventOrUnmodifiedEvent:event];
            break;
            
        default:
            break;
    }
    
    return event;
}

- (CGEventRef)newPowerKeyEventOrUnmodifiedEvent:(CGEventRef)systemEvent {
    
    NSEvent *event = [NSEvent eventWithCGEvent:systemEvent];
    
    NSEventType type = [event type];
    int subtype = [event subtype];
    NSInteger eventData1 = [event data1];
    NSUInteger modifierKeys = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
    
    //http://weblog.rogueamoeba.com/2007/09/29/
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    int keyRepeat = (keyFlags & 0x1);

    //NSLog(@"EVENT: type:%lu subtype:%i, eventData:%li, keyCode:%i, keyFlags:%i, keyState:%i, keyRepeat:%i",type , subtype, (long)eventData1, keyCode, keyFlags, keyState, keyRepeat);
    
    /*
    Pressing the power key generates two events. These are *not* up/down versions of the same event.
    The power key does not behave like a standard key, nor like other system hotkeys (Play, Pause, Volume, etc.), which *do* have distinct up/down events.
    The first power event seems to prompt the system to show the [Restart/Sleep/ShutDown] message.
    The second power event (keyCode == NX_POWER_KEY), by itself, does not seem to prompt any system response.
    When modifier keys are held, the NX_POWER_KEY event is often not sent. Fn + Power, especially, can cause unintended results if prevented. Not recommended.
    This app only modifies the power key events when *no* modifier keys are held; the events and system proceed normally when any modifier keys are held.
    IMPORTANT: Even if these events are prevented, the system WILL still turn off when the power key is held down for a few seconds!
    */
            
    //First Power key event
    if (type == NSSystemDefined &&
        subtype == 1 &&
        eventData1 == 0 &&
        keyCode == 0 &&
        keyFlags == 0 &&
        keyState == 0 &&
        keyRepeat == 0 &&
        modifierKeys == 0)
    {
        //Kill the event, thereby blocking the system [Restart/Sleep/ShutDown] message.
        systemEvent = CGEventCreate(NULL);
    }
    
    //Second Power key event
    if (type == NSSystemDefined &&
        subtype == 8 &&
        eventData1 == 395776 &&
        keyCode == NX_POWER_KEY &&
        keyFlags == 2560 &&
        keyState == 1 &&
        keyRepeat == 0 &&
        modifierKeys == 0)
    {
        //Send a new replacement keystroke instead.
        systemEvent = [self newPowerKeyEvent];
    }
    
    return systemEvent;
}

- (CGEventRef)newPowerKeyEvent
{
    //Replace the power key with a simulated keystroke
    CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef event = CGEventCreateKeyboardEvent(eventSource, self.powerKeyKeyCode, true);
    CFRelease(eventSource);
    
    return event;
}

- (IBAction)changePowerButtonFunction:(id)sender
{
    NSMenuItem *selectedMenuItem = ((NSPopUpButton *)sender).selectedItem;
    self.powerKeyKeyCode = selectedMenuItem.tag;
    
    //Save user's power key function
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:selectedMenuItem.tag forKey:kPowerKeyUserPrefKey];
    [defaults synchronize];
}

- (IBAction)openProjectOnGithub:(id)sender
{
    system("open https://github.com/pkamb/powerkey");
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    //Always show the initial window when app is "reopened"
    [self.prefsWindow makeKeyAndOrderFront:self];
    
    return NO;
}

@end
