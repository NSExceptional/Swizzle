//
//  NSObject+Debugging.m
//  TBTweakViewController
//
//  Created by Tanner on 6/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "NSObject+Debugging.h"

@implementation NSObject (Debugging)

+ (NSBundle *)__bundle__ {
    return [NSBundle bundleForClass:self];
}

+ (BOOL)isOfMainBundle {
    return [self.__bundle__.bundleIdentifier hasPrefix:[NSBundle mainBundle].bundleIdentifier];
}

@end
