//
//  EnumSet.m
//  TBTweakViewController
//
//  Created by Tanner on 3/20/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "EnumSet.h"

@interface EnumSet ()
@property (nonatomic, readonly) NSMutableArray<NSNumber*> *array;
@end
@implementation EnumSet

+ (instancetype)set {
    return [self indexSet];
}

- (id)init {
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
    }

    return self;
}

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.array[idx];
}

- (void)addIndex:(NSUInteger)value {
    [super addIndex:value];
    [self.array addObject:@(value)];
    [self.array sortUsingSelector:@selector(compare:)];
}

- (void)removeIndex:(NSUInteger)value {
    [super removeIndex:value];
    NSNumber *remove = @(value);
    if ([self.array containsObject:remove]) {
        [self.array removeObject:remove];
    }
}

@end
