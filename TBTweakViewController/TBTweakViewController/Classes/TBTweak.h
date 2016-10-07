//
//  TBTweak.h
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook.h"


typedef NS_OPTIONS(NSUInteger, TBTweakType) {
    TBTweakTypeUnspecified            = 0,
    TBTweakTypeChirpCode              = 1 << 0,
    TBTweakTypeHookReturnValue        = 1 << 1,
    TBTweakTypeHookArguments          = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN
@interface TBTweak : NSObject <NSCoding>

/// @return nil if no hook was nil
+ (nullable instancetype)tweakWithHook:(nullable TBMethodHook *)hook;
+ (nullable instancetype)tweakWithTarget:(Class)target instanceMethod:(SEL)action;
+ (nullable instancetype)tweakWithTarget:(Class)target method:(SEL)action;

/// Only calls back on error.
- (void)tryEnable:(void(^)(NSError *error))failureBlock;
- (void)disable;

@property (nonatomic, readonly) BOOL         enabled;
@property (nonatomic, readonly) TBMethodHook *hook;
@property (nonatomic, readonly) TBTweakType  tweakType;

@end
NS_ASSUME_NONNULL_END
