//
//  PKPowerKeyEventListener.m
//  PowerKey
//
//  Created by Peter Kamb on 8/15/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import "PKPowerKeyEventListener.h"
#include <Carbon/Carbon.h>
#include <IOKit/hidsystem/ev_keymap.h>
#import "PKAppDelegate.h"

id refToSelf;
CFMachPortRef eventTap;

@implementation PKPowerKeyEventListener

+ (PKPowerKeyEventListener *)sharedEventListener
{
	static PKPowerKeyEventListener *sharedEventListener = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedEventListener = [[PKPowerKeyEventListener alloc] init];
	});
	return sharedEventListener;
}

- (id)init
{
    self = [super init];
    if (self) {
        refToSelf = self;
        CGKeyCode replacementKeycode = [[[NSUserDefaults standardUserDefaults] objectForKey:kPowerKeyReplacementKeycodeKey] integerValue];
        self.powerKeyReplacementKeyCode = replacementKeycode ?: kVK_ForwardDelete;
    }
    return self;
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
}

CGEventRef copyEventTapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    switch (type) {
        case kCGEventTapDisabledByTimeout:
            // Re-enable the event tap if it times out.
            CGEventTapEnable(eventTap, true);
            break;
            
        case NSSystemDefined:
            event = [refToSelf newPowerKeyEventOrUnmodifiedSystemDefinedEvent:event];
            break;
            
        default:
            break;
    }
    
    return event;
}

- (CGEventRef)newPowerKeyEventOrUnmodifiedSystemDefinedEvent:(CGEventRef)systemEvent
{
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
        systemEvent = [self newPowerKeyReplacementEvent];
    }
    
    return systemEvent;
}

- (CGEventRef)newPowerKeyReplacementEvent
{
    CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef event = CGEventCreateKeyboardEvent(eventSource, self.powerKeyReplacementKeyCode, true);
    CFRelease(eventSource);
    return event;
}

@end
