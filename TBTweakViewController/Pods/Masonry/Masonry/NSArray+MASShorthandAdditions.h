//
//  NSArray+MASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+MASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas__' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface NSArray (MASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(SWZConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(SWZConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(SWZConstraintMaker *make))block;

@end

@implementation NSArray (MASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(SWZConstraintMaker *))block {
    return [self mas__makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(SWZConstraintMaker *))block {
    return [self mas__updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(SWZConstraintMaker *))block {
    return [self mas__remakeConstraints:block];
}

@end

#endif
