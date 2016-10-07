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
    CGEventMask eventTypeMask = NSSystemDefined;

    /*
     The power key sends events of type NSSystemDefined.
     We'd idealy monitor *only* NSSystemDefined events.
     But there are various bugs with certain other applications if we do.
     Therefore, we need to grab other events as well.
    */
    
    for (NSEventType type = NSLeftMouseDown; type < NSEventTypeGesture; ++type) {
        switch (type) {
            case NSMouseMoved:
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

CGEventRef copyEventTapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if (type == kCGEventTapDisabledByTimeout) {
        CGEventTapEnable(eventTap, true);
    } else if (type == NSSystemDefined) {
        event = [refToSelf newPowerKeyEventOrUnmodifiedSystemDefinedEvent:event];
    }
    
    return event;
}

- (CGEventRef)newPowerKeyEventOrUnmodifiedSystemDefinedEvent:(CGEventRef)systemEvent {
    NSEvent *event = [NSEvent eventWithCGEvent:systemEvent];
    
    if (event.type != NSSystemDefined) {
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
        if (event.type == NSSystemDefined) {
            eventTypeString = @"NSSystemDefined";
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
    
    // Pressing the power key generates 3 NSSystemDefined keyboard events.
    // Attempt to kill each power key events by returning `nullEvent`.
    // Additionally, post the user-selected key replacement as a new event.
    
    // Power Key Event #1
    if (event.subtype == NX_SUBTYPE_POWER_KEY) {
        systemEvent = [self newPowerKeyReplacement:CGEventGetFlags(systemEvent)];
    }
    
    if (keyCode == NX_POWER_KEY && event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS) {
        
        // Power Key Event #2
        BOOL keyDown = (keyState == 1);
        if (keyDown) {
            systemEvent = nullEvent;
        }
        
        // Power Key Event #3
        BOOL keyUp = (keyState == 0);
        if (keyUp) {
            systemEvent = nullEvent;
        }
    }
    
    // Pressing the eject key generates 3 NSSystemDefined keyboard events.
    // Attempt to kill each eject key events by returning `nullEvent`.
    // Additionally, post the user-selected key replacement as a new event.
    
    // Eject Key Event #1
    if (event.subtype == NX_SUBTYPE_EJECT_KEY) {
        systemEvent = [self newPowerKeyReplacement:CGEventGetFlags(systemEvent)];
    }
    
    if (keyCode == NX_KEYTYPE_EJECT && event.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS) {
        
        // Eject Key Event #2
        BOOL keyDown = (keyState == 1);
        if (keyDown) {
            systemEvent = nullEvent;
        }
        
        // Eject Key Event #3
        BOOL keyUp = (keyState == 0);
        if (keyUp) {
            systemEvent = nullEvent;
        }
    }
    
    return systemEvent;
}

- (CGEventRef)newPowerKeyReplacement:(CGEventFlags)modifierFlags {
    
    CGEventRef event;
    
    CGKeyCode keyCode = [[NSUserDefaults standardUserDefaults] integerForKey:kPowerKeyReplacementKeycodeKey] ?: kVK_ForwardDelete;
    
    if (keyCode == kPowerKeyDeadKeyTag) {
        // do nothing
        event = nullEvent;
    } else if (keyCode == kPowerKeyScriptTag) {
        [PKScriptController runScript];
        
        event = nullEvent;
    } else {
        CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
        event = CGEventCreateKeyboardEvent(eventSource, keyCode, true);
        CGEventSetFlags(event, modifierFlags);
        CFRelease(eventSource);
    }
    
    return event;
}

@end
