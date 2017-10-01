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
#import "PKScriptController.h"

id refToSelf;
CFMachPortRef eventTap;

@implementation PKPowerKeyEventListener

+ (PKPowerKeyEventListener *)sharedEventListener {
	static PKPowerKeyEventListener *sharedEventListener = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedEventListener = [[PKPowerKeyEventListener alloc] init];
	});
    
	return sharedEventListener;
}

- (id)init {
    if (self = [super init]) {
        refToSelf = self;
    }
    
    return self;
}

- (void)monitorPowerKey {
    CGEventMask eventTypeMask = NSEventTypeSystemDefined;

    /*
     The power key sends events of type NSEventTypeSystemDefined.
     We'd idealy monitor *only* NSEventTypeSystemDefined events.
     But there are various bugs with certain other applications if we do.
     Therefore, we need to grab other events as well.
    */
    
    for (NSEventType type = NSEventTypeLeftMouseDown; type < NSEventTypeGesture; ++type) {
        switch (type) {
            case NSEventTypeMouseMoved:
            case NSEventTypeKeyDown:
            case NSEventTypeKeyUp:
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

CGEventRef copyEventTapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if (type == kCGEventTapDisabledByTimeout) {
        CGEventTapEnable(eventTap, true);
    } else if (type == NSEventTypeSystemDefined) {
        event = [refToSelf newPowerKeyEventOrUnmodifiedSystemDefinedEvent:event];
    }
    
    return event;
}

- (CGEventRef)newPowerKeyEventOrUnmodifiedSystemDefinedEvent:(CGEventRef)systemEvent {
    NSEvent *event = [NSEvent eventWithCGEvent:systemEvent];
    
    if (event.type != NSEventTypeSystemDefined) {
        return systemEvent;
    }
    
    if (event.subtype == NX_SUBTYPE_AUX_MOUSE_BUTTONS) {
        return systemEvent;
    }
    
    // http://weblog.rogueamoeba.com/2007/09/29/
    int keyCode = ((event.data1 & 0xFFFF0000) >> 16);
    int keyFlags = (event.data1 & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    int keyRepeat = (keyFlags & 0x1);
    NSUInteger modifierKeys = event.modifierFlags & NSDeviceIndependentModifierFlagsMask;
    
    BOOL printEventInfo = NO;
    if (printEventInfo) {
        
        NSString *eventTypeString = nil;
        if (event.type == NSEventTypeSystemDefined) {
            eventTypeString = @"NSEventTypeSystemDefined";
        } else {
            eventTypeString = [NSString stringWithFormat:@"%@", @(event.type)];
        }
        
        NSString *eventSubtypeString = nil;
        if (event.subtype == NX_SUBTYPE_POWER_KEY) {
            eventSubtypeString = @"NX_SUBTYPE_POWER_KEY";
            
            // Should this actually be `NSPowerOffEventType` from `NSEventSubtype`?
            
        } else if (event.subtype == NX_SUBTYPE_EJECT_KEY) {
            eventSubtypeString = @"NX_SUBTYPE_EJECT_KEY";
        } else if (event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS) {
            eventSubtypeString = @"NX_SUBTYPE_AUX_CONTROL_BUTTONS";
        } else {
            eventSubtypeString = [NSString stringWithFormat:@"%@", @(event.subtype)];
        }
        
        NSString *keyCodeString = nil;
        if (keyCode == NX_POWER_KEY) {
            keyCodeString = @"NX_POWER_KEY";
        } else if (keyCode == NX_KEYTYPE_EJECT) {
            keyCodeString = @"NX_KEYTYPE_EJECT";
        } else {
            keyCodeString = [NSString stringWithFormat:@"%@", @(keyCode)];
        }
        
        NSString *keyStateString = (keyState == 0) ? @"KeyUp" : @"KeyDown";
        
        NSLog(@"Event: type:%@, subtype:%@, keyCode:%@, keyState:%@ keyRepeat:%@ modifierKeys:%@", eventTypeString, eventSubtypeString, keyCodeString, keyStateString, @(keyRepeat), @(modifierKeys));
    }
    
    // The Power and Eject keys each generate 3 NSEventTypeSystemDefined keyboard events.
    
    BOOL powerKeyEvent1 = (event.subtype == NX_SUBTYPE_POWER_KEY);
    BOOL powerKeyEvent2 = (keyCode == NX_POWER_KEY && event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS && keyState == 1);
    BOOL powerKeyEvent3 = (keyCode == NX_POWER_KEY && event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS && keyState == 0);
    
    BOOL ejectKeyEvent1 = (event.subtype == NX_SUBTYPE_EJECT_KEY);
    BOOL ejectKeyEvent2 = (keyCode == NX_KEYTYPE_EJECT && event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS && keyState == 1);
    BOOL ejectKeyEvent3 = (keyCode == NX_KEYTYPE_EJECT && event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS && keyState == 0);
    
    CGEventRef replacementEvent = systemEvent;
    
    if (powerKeyEvent1 || ejectKeyEvent1) {
        
        // Block first Power or Eject key event
        replacementEvent = NULL;
        
        // Input an event/action chosen by the user.
        CGKeyCode replacementKeyCode = [[NSUserDefaults standardUserDefaults] integerForKey:kPowerKeyReplacementKeycodeKey] ?: kVK_ForwardDelete;
        if (replacementKeyCode == kPowerKeyDeadKeyTag) {
            
            // no action
            
        } else if (replacementKeyCode == kPowerKeyScriptTag) {
            
            [PKScriptController runScript];
            
        } else {
            CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
            CGEventRef inputEvent = CGEventCreateKeyboardEvent(eventSource, replacementKeyCode, true);
            CGEventSetFlags(inputEvent, CGEventGetFlags(systemEvent));
            CFRelease(eventSource);
            
            // Better performance by posting the newly created event as a new keyboard event,
            // rather than attempting to return the event in place of the system keyboard event.
            CGEventPost(kCGHIDEventTap, inputEvent);
            CFRelease(inputEvent);
        }
        
    } else if (powerKeyEvent2 || powerKeyEvent3 || ejectKeyEvent2 || ejectKeyEvent3) {
        
        // Block the second and third events.
        replacementEvent = NULL;
        
    } else {
        
        // This event was not a Power or Eject key event; return the original event.
        replacementEvent = systemEvent;
    }
    
    return replacementEvent;
}

@end
