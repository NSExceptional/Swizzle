//
//  TBSettings.m
//  TBTweakViewController
//
//  Created by Tanner on 10/6/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBSettings.h"

#define DEFAULTS [NSUserDefaults standardUserDefaults]
NSString * const kLoadTweaksAtLaunch = @"com.pantsthief.swizzle.LoadTweaksAtLaunch";

@implementation TBSettings

+ (void)initialize {
    if (self == [self class]) {
        [DEFAULTS registerDefaults:@{kLoadTweaksAtLaunch: @YES}];
    }
}

static BOOL _expertMode = NO;
+ (BOOL)expertMode {
    return _expertMode;
}

+ (BOOL)chirpEnabled {
    return NO;
}

+ (BOOL)loadTweaksAtLaunch {
    return [DEFAULTS boolForKey:kLoadTweaksAtLaunch];
}

@end
