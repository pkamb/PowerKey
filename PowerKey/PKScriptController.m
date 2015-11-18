//
//  PKScriptController.m
//  PowerKey
//
//  Created by Peter Kamb on 11/17/15.
//  Copyright © 2015 Peter Kamb. All rights reserved.
//

#import "PKScriptController.h"

NSString *const kPowerKeyScriptURLKey = @"kPowerKeyScriptURLKey";

@implementation PKScriptController

+ (void)runScript {
    NSURL *scriptURL = [[NSUserDefaults standardUserDefaults] URLForKey:kPowerKeyScriptURLKey];
    
    if ([self isValidScriptWithURL:scriptURL]) {
        [self runScriptWithURL:scriptURL];
    } else if ([self isValidAppleScriptWithURL:scriptURL]) {
        [self runAppleScriptWithURL:scriptURL];
    } else {
        NSLog(@"The selected Script or AppleScript is invalid.");
    }
}

+ (BOOL)isValidScriptWithURL:(NSURL *)url {
    NSNumber *isExecutable;
    NSError *executableError;
    [url getResourceValue:&isExecutable forKey:NSURLIsExecutableKey error:&executableError];
    
    NSNumber *isDirectory; // Directories have the isExecutable flag set; ignore them.
    NSError *directoryError;
    [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&directoryError];
    
    return [isExecutable boolValue] && ![isDirectory boolValue];
}

+ (void)runScriptWithURL:(NSURL *)url {
    @try {
        [NSTask launchedTaskWithLaunchPath:url.path arguments:@[]];
    }
    @catch (NSException *exception) {
        NSLog(@"Error running script '%@'. %@: %@", url.path, exception.name, exception.reason);
    }
}

+ (BOOL)isValidAppleScriptWithURL:(NSURL *)url {
    NSDictionary *appleScriptErrors;
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&appleScriptErrors];
    
    return appleScript != nil;
}

+ (void)runAppleScriptWithURL:(NSURL *)url {
    NSDictionary *appleScriptErrors;
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&appleScriptErrors];
    
    if (appleScript) {
        NSDictionary *executionErrors;
        [appleScript executeAndReturnError:&executionErrors];
        if (appleScriptErrors) {
            NSLog(@"Error running AppleScript: %@", executionErrors);
        }
    } else {
        if (appleScriptErrors) {
            NSLog(@"Error in AppleScript file: %@", appleScriptErrors);
        }
    }
}

@end
