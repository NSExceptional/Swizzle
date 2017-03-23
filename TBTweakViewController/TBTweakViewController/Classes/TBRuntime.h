//
//  TBRuntime.h
//  TBTweakViewController
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBKeyPath.h"
@class MKMethod;


/// Accepts runtime queries given a token.
@interface TBRuntime : NSObject

+ (instancetype)runtime;

- (void)loadBinaryImages;

/// @return Bundle names for the UI
- (NSMutableArray<NSString*> *)bundlesForKeyPath:(TBKeyPath *)keyPath;
/// @return Class names
- (NSMutableArray<NSString*> *)classesForKeyPath:(TBKeyPath *)keyPath;
/// @return Actual methods
- (NSMutableArray<MKMethod*> *)methodsForKeyPath:(TBKeyPath *)keyPath;

- (MKMethod *)methodForAbsoluteKeyPath:(TBKeyPath *)keyPath;

@end
