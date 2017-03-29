//
//  TBRuntimeController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBKeyPath.h"


@interface TBRuntimeController : NSObject

/// @return An array of strings if the key path only evaluates
///         to a class or bundle; otherwise, an array of MKMethods.
+ (NSArray *)dataForKeyPath:(TBKeyPath *)keyPath;

+ (NSString *)shortBundleNameForClass:(NSString *)name;

+ (NSArray *)allBundleNames;

@end
