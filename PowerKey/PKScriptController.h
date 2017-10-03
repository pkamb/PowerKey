//
//  PKScriptController.h
//  PowerKey
//
//  Created by Peter Kamb on 11/17/15.
//  Copyright © 2015 Peter Kamb. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const kPowerKeyScriptURLKey;

@interface PKScriptController : NSObject

+ (void)runScript;

+ (BOOL)isValidScriptWithURL:(NSURL *)url;
+ (BOOL)isValidAppleScriptWithURL:(NSURL *)url;

@end
