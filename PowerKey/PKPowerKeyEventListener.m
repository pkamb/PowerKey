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
    CGEventMask eventTypeMask = NSSystemDefined;

    /*
     The power key sends events of type NSSystemDefined.
     We'd idealy monitor *only* NSSystemDefined events.
     But there are various bugs with certain other applications if we do.
     Therefore, we need to grab other events as well.
    */
    
    for (NSEventType type = NSLeftMouseDown; type < NSEventTypeGesture; ++type) {
        switch (type) {
            case NSKeyDown:
            case NSKeyUp:
            case NSEventTypeRotate:
            case NSEventTypeBeginGesture:
            case NSEventTypeEndGesture:
                break;
            default:
                eventTypeMask |= NSEventMaskFromType(type);
        }
    }
    
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventTypeMask, copyEventTapCallBack, NULL);
    
    if (!eventTap) {
        exit(YES);
    }
    
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    
    CGEventTapEnable(eventTap, true);
    
    CFRelease(runLoopSource);
}

CGEventRef copyEventTapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    switch (type) {
        case kCGEventTapDisabledByTimeout:
            CGEventTapEnable(eventTap, true);
            break;
        case NSSystemDefined:
            event = [refToSelf newPowerKeyEventOrUnmodifiedSystemDefinedEvent:event];
            break;
    }
    return event;
}

- (CGEventRef)newPowerKeyEventOrUnmodifiedSystemDefinedEvent:(CGEventRef)systemEvent
{
    NSEvent *event = [NSEvent eventWithCGEvent:systemEvent];
    
    // Early exit for common NSSystemDefined mouse events
    if (event.subtype == NX_SUBTYPE_AUX_MOUSE_BUTTONS) {
        return systemEvent;
    }
    
    // http://weblog.rogueamoeba.com/2007/09/29/
    int keyCode = ((event.data1 & 0xFFFF0000) >> 16);
    int keyFlags = (event.data1 & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    int keyRepeat = (keyFlags & 0x1);
    NSUInteger modifierKeys = event.modifierFlags & NSDeviceIndependentModifierFlagsMask;
#ifdef DEBUG
    NSLog(@"EVENT: type:%lu subtype:%i, eventData:%li, keyCode:%i, keyFlags:%i, keyState:%i, keyRepeat:%i, modifierKeys:%lu", event.type , event.subtype, (long)event.data1, keyCode, keyFlags, keyState, keyRepeat, modifierKeys);
#endif
    
    /*
     * Pressing the Power key generates 3 NSSystemDefined keyboard events.
     * A single NX_SUBTYPE_POWER_KEY event, and up/down versions of the NX_POWER_KEY event.
     *
     * PowerKey.app replaces the NX_SUBTYPE_POWER_KEY with a key event of the user's choosing.
     * Unfortunately, the NX_POWER_KEY event cannot be replaced or killed.
     *
     * The NX_POWER_KEY event is no-op in OS X 10.8, but triggers an immediate sleep in 10.9.
     */
    
    /*
     * NX_SUBTYPE_POWER_KEY event
     * ============
     * Can be killed or replaced by a new event.
     *
     * 10.8: triggers the [Restart | Sleep | Cancel | Shut Down] dialog
     * 10.9:
     *  - no modifiers: no-op
     *  - ctrl modifier: triggers the dialog
     */
    if (event.type == NSSystemDefined &&
        event.subtype == NX_SUBTYPE_POWER_KEY &&
        !(modifierKeys & NSFunctionKeyMask))
    {
        // Replace event with user's prefered key.
        systemEvent = [self newPowerKeyReplacementEvent];
    }
    
    /*
     * NX_POWER_KEY event
     * ============
     * Cannot be killed or replaced by a new event.
     *
     * 10.8: no-op
     * 10.9: triggers immediate Sleep function
     */
    if (event.type == NSSystemDefined &&
        event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS &&
        keyCode == NX_POWER_KEY &&
        !(modifierKeys & NSFunctionKeyMask))
    {
        switch (keyState) {
            case 1:
                // key down
                break;
            case 0:
                // key up
                break;
        }
        
        // Attempt (but fail) to kill the event
        systemEvent = nullEvent;
    }
    
    return systemEvent;
}

- (CGEventRef)newPowerKeyReplacementEvent
{
    CGEventRef event;
    if (self.powerKeyReplacementKeyCode == kPowerKeyDeadKeyTag) {
        event = nullEvent;
    } else if (self.powerKeyReplacementKeyCode == kPowerKeyLaunchpadTag) {
        [[NSWorkspace sharedWorkspace] launchApplication:@"Launchpad.app"];
        event = nullEvent;
    } else {
        CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
        event = CGEventCreateKeyboardEvent(eventSource, self.powerKeyReplacementKeyCode, true);
        CFRelease(eventSource);
    }
    
    return event;
}

@end
