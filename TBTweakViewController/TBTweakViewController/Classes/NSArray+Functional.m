//
//  NSArray+Functional.m
//  TBTweakViewController
//
//  Created by Tanner on 3/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "NSArray+Functional.h"

#define TBIsMutableArray(me) ([[self class] isSubclassOfClass:[NSMutableArray class]])

@implementation NSArray (Functional)

void test() {
}

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

    if (bound < 2048 && !TBIsMutableArray(self)) {
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

    if (self.count < 2048 && !TBIsMutableArray(self)) {
        return array.copy;
    }

    return array;
}

- (instancetype)flatmap:(NSArray *(^)(id))block {
    NSMutableArray *array = [NSMutableArray array];
    for (id element in self) {
        NSArray *obj = block(element);
        if (obj) {
            [array addObjectsFromArray:obj];
        }
    }

    if (array.count < 2048 && !TBIsMutableArray(self)) {
        return array.copy;
    }

    return array;
}

@end
