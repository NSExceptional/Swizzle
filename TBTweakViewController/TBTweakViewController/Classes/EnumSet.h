//
//  EnumSet.h
//  TBTweakViewController
//
//  Created by Tanner on 3/20/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnumSet : NSMutableIndexSet

+ (instancetype)set;

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx;

@end
