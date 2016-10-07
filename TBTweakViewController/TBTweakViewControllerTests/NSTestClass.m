//
//  NSTestClass.m
//  TBTweakViewController
//
//  Created by Tanner on 8/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSTestClass.h"

#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSTestClass

- (id)init {
    _conditon = YES;
    return self;
}

- (void)doNothingMethod {
    
}

- (id)multiple:(id)arg1 param:(BOOL)arg2 method:(char)arg3 {
    return arg1 && arg2 && arg3 ? arg1 : nil;
}

+ (NSInteger)classLength {
    return 10;
}

@end
