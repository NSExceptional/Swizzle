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
+ (NSArray<ObjectType> *)of:(ObjectType)obj count:(NSUInteger)count;
/// Map over 0..<bound
+ (NSArray<ObjectType> *)upto:(NSUInteger)bound map:(ObjectType(^)(NSUInteger))block;
/// Like Swift's map
- (instancetype)map:(id(^)(ObjectType))block;

@end
