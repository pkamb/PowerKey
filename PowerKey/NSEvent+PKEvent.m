//
//  NSEvent+PKEvent.m
//  PowerKey
//
//  Created by Peter Kamb on 10/2/17.
//  Copyright © 2017 Peter Kamb. All rights reserved.
//

#import "NSEvent+PKEvent.h"
#include <IOKit/hidsystem/ev_keymap.h>

@implementation NSEvent (PKEvent)

// http://weblog.rogueamoeba.com/2007/09/29/
- (int)specialKeyCode { return ((self.data1 & 0xFFFF0000) >> 16); }
- (int)keyFlags {       return (self.data1 & 0x0000FFFF); }
- (int)keyState {       return (((self.keyFlags & 0xFF00) >> 8)) == 0xA; }
- (int)keyRepeat {      return (self.keyFlags & 0x1); }

- (NSDictionary *)debugInformation {
    NSUInteger modifierKeys = self.modifierFlags & NSDeviceIndependentModifierFlagsMask;
    
    NSString *eventTypeString = nil;
    if (self.type == NSEventTypeSystemDefined) {
        eventTypeString = @"NSEventTypeSystemDefined";
    } else {
        eventTypeString = [NSString stringWithFormat:@"%@", @(self.type)];
    }
    
    NSString *eventSubtypeString = nil;
    if (self.subtype == NX_SUBTYPE_POWER_KEY) {
        eventSubtypeString = @"NX_SUBTYPE_POWER_KEY";
        
        // Should this actually be `NSPowerOffEventType` from `NSEventSubtype`?
        
    } else if (self.subtype == NX_SUBTYPE_EJECT_KEY) {
        eventSubtypeString = @"NX_SUBTYPE_EJECT_KEY";
    } else if (self.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS) {
        eventSubtypeString = @"NX_SUBTYPE_AUX_CONTROL_BUTTONS";
    } else if ((short)self.subtype == NX_SUBTYPE_MENU) {
        eventSubtypeString = @"NX_SUBTYPE_MENU";
    } else if ((short)self.subtype == NX_SUBTYPE_ACCESSIBILITY) {
        eventSubtypeString = @"NX_SUBTYPE_ACCESSIBILITY";
    } else {
        eventSubtypeString = [NSString stringWithFormat:@"%@", @(self.subtype)];
    }
    
    NSString *specialKeyCodeCodeString = nil;
    if (self.specialKeyCode == NX_POWER_KEY) {
        specialKeyCodeCodeString = @"NX_POWER_KEY";
    } else if (self.specialKeyCode == NX_KEYTYPE_EJECT) {
        specialKeyCodeCodeString = @"NX_KEYTYPE_EJECT";
    } else {
        specialKeyCodeCodeString = [NSString stringWithFormat:@"%@", @(self.specialKeyCode)];
    }
    
    NSDictionary *debugInformation = @{
                                       @"type": eventTypeString,
                                       @"subtype": eventSubtypeString,
                                       @"specialKeyCode": specialKeyCodeCodeString,
                                       @"keyState": (self.keyState == 0) ? @"KeyUp" : @"KeyDown",
                                       @"keyRepeat": @(self.keyRepeat),
                                       @"modifierKeys": @(modifierKeys),
                                       };
    
    return debugInformation;
}


@end
