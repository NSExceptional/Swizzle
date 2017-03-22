//
//  NSArray+Functional.m
//  TBTweakViewController
//
//  Created by Tanner on 3/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

+ (instancetype)of:(id)obj count:(NSUInteger)count {
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        [array addObject:obj];
    }

    if (count < 2048) {
        return array.copy;
    }

    return array;
}

+ (instancetype)upto:(NSUInteger)bound map:(id(^)(NSUInteger))block {
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger i = 0; i < bound; i++) {
        id obj = block(i);
        if (obj) {
            [array addObject:obj];
        }
    }

    if (bound < 2048) {
        return array.copy;
    }

    return array;
}

- (instancetype)map:(id(^)(id))block {
    NSMutableArray *array = [NSMutableArray array];
    for (id element in self) {
        id obj = block(element);
        if (obj) {
            [array addObject:obj];
        }
    }

    if (self.count < 2048) {
        return array.copy;
    }

    return array;
}

@end
