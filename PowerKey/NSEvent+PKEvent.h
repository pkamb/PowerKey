//
//  NSEvent+PKEvent.h
//  PowerKey
//
//  Created by Peter Kamb on 10/2/17.
//  Copyright © 2017 Peter Kamb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSEvent (PKEvent)

- (int)specialKeyCode;
- (int)keyFlags;
- (int)keyState;
- (int)keyRepeat;

- (NSDictionary *)debugInformation;

@end
