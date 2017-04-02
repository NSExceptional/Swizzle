//
//  TBTweak.h
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook.h"


NS_ASSUME_NONNULL_BEGIN
/// A class to make toggleable "tweaks" at runtime.
/// Simply provide `TBMethodHook`s and call `tryEnable:`.
@interface TBTweak : NSObject <NSCoding>

+ (instancetype)tweakWithTitle:(NSString *)title;

/// The block only calls back (executes) if there was an error.
- (void)tryEnable:(nullable void(^)(NSError *error))failureBlock;
- (void)disable;

/// @discussion Hooks added to the tweak while it is enabled
/// will not take effect until the tweak has been toggled.
- (void)addHook:(TBMethodHook *)hook;
/// @discussion Hooks removed from the tweak while it is enabled
/// will have their hooks unset immediately.
- (void)removeHook:(TBMethodHook *)hook;

/// Whether the tweak is enabled.
@property (nonatomic, readonly) BOOL enabled;

/// All method hooks associated with the tweak.
@property (nonatomic, readonly) NSArray<TBMethodHook*> *hooks;

@property (nonatomic, readonly) NSString *title;

@end
NS_ASSUME_NONNULL_END
