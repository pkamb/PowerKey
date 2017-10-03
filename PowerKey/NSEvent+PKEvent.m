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

- (NSString *)eventTypeString {
    switch (self.type) {
        case NSEventTypeSystemDefined: return @"NSEventTypeSystemDefined";
        default: return [NSString stringWithFormat:@"%@", @(self.type)];
    }
}

- (NSString *)eventSubtypeString {
    switch ((short)self.subtype) {
        case NX_SUBTYPE_POWER_KEY: return @"NX_SUBTYPE_POWER_KEY"; // `NSPowerOffEventType` from `NSEventSubtype`?
        case NX_SUBTYPE_EJECT_KEY: return @"NX_SUBTYPE_EJECT_KEY";
        case NX_SUBTYPE_AUX_CONTROL_BUTTONS: return @"NX_SUBTYPE_AUX_CONTROL_BUTTONS";
        case NX_SUBTYPE_MENU: return @"NX_SUBTYPE_MENU";
        case NX_SUBTYPE_ACCESSIBILITY: return @"NX_SUBTYPE_ACCESSIBILITY";
        default: return [NSString stringWithFormat:@"%@", @(self.subtype)];
    }
}

- (NSDictionary *)debugInformation {
    NSUInteger modifierKeys = self.modifierFlags & NSDeviceIndependentModifierFlagsMask;
    
    NSString *specialKeyCodeCodeString = nil;
    if (self.specialKeyCode == NX_POWER_KEY) {
        specialKeyCodeCodeString = @"NX_POWER_KEY";
    } else if (self.specialKeyCode == NX_KEYTYPE_EJECT) {
        specialKeyCodeCodeString = @"NX_KEYTYPE_EJECT";
    } else {
        specialKeyCodeCodeString = [NSString stringWithFormat:@"%@", @(self.specialKeyCode)];
    }
    
    NSDictionary *debugInformation = @{
                                       @"type": self.eventTypeString,
                                       @"subtype": self.eventSubtypeString,
                                       @"specialKeyCode": specialKeyCodeCodeString,
                                       @"keyState": (self.keyState == 0) ? @"KeyUp" : @"KeyDown",
                                       @"keyRepeat": @(self.keyRepeat),
                                       @"modifierKeys": @(modifierKeys),
                                       };
    
    return debugInformation;
}


@end
