//
//  NSArray+Functional.h
//  TBTweakViewController
//
//  Created by Tanner on 3/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (Functional)

/// Repeated value array
+ (instancetype)of:(ObjectType)obj count:(NSUInteger)count;
/// Map over 0..<bound
+ (instancetype)upto:(NSUInteger)bound map:(ObjectType(^)(NSUInteger i))block;
/// Like Swift's map
- (instancetype)map:(id(^)(ObjectType obj))block;

/// Adds all elements into a single array
- (instancetype)flatmap:(NSArray *(^)(ObjectType obj))block;

@end
