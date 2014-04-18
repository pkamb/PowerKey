//
//  PKPowerKeyEventListener.h
//  PowerKey
//
//  Created by Peter Kamb on 8/15/13.
//  Copyright (c) 2013 Peter Kamb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKPowerKeyEventListener : NSObject

@property (assign) CGKeyCode powerKeyReplacementKeyCode;
@property (copy) NSString *scriptPath;

+ (PKPowerKeyEventListener *)sharedEventListener;
- (void)monitorPowerKey;

CGEventRef copyEventTapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon);

- (CGEventRef)newPowerKeyEventOrUnmodifiedSystemDefinedEvent:(CGEventRef)systemEvent;
- (CGEventRef)newPowerKeyReplacementEvent;

@end
