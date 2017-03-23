//
//  NSScanner+debug.m
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "NSScanner+debug.h"

@implementation NSScanner (debug)

- (NSString *)remaining {
    return [self.string substringFromIndex:self.scanLocation];
}

- (NSString *)scanned {
    return [self.string substringToIndex:self.scanLocation];
}

@end
