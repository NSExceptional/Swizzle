//
//  TBMethodHook.h
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "MirrorKit/MirrorKit.h"
#import "TBValue.h"


typedef NS_OPTIONS(NSUInteger, TBHookType) {
    TBHookTypeUnspecified = 0,
    TBHookTypeChirpCode   = 1 << 0,
    TBHookTypeReturnValue = 1 << 1,
    TBHookTypeArguments   = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

NSInvocation * TBInvocationFromArguments(NSMethodSignature *signature, NSArray<TBValue*> *args);
IMP TBGetOriginalMethodIMP(id instanceOrClass, SEL sel);

/// Helper class used by TBTweak to toggle the state of a method hook.
/// Two TBMethodHooks are considered equal if their `method.objc_method`s are equal.
@interface TBMethodHook : NSObject <NSCoding>

/// @param cls The target class to hook.
/// @param selector The selector of the method to hook. Must be registered with the runtime.
/// @param classMethod `YES` if the method is a class method, `NO` for instance methods.
+ (instancetype)target:(Class)cls action:(SEL)selector isClassMethod:(BOOL)classMethod;

+ (instancetype)hook:(MKMethod *)method;

/// The type of the tweak, based on the configuration of the `hook` property.
/// The value is `TBHookTypeUnspecified` if `hook` is not configured to override anything.
@property (nonatomic, readonly) TBHookType type;

/// Describes the nature of the hook for UI purposes
@property (nonatomic, readonly) NSString *about;

@property (nonatomic, readonly) BOOL canOverrideReturnValue;
@property (nonatomic, readonly) BOOL canOverrideAllArgumentValues;

/// The target class to be hooked.
@property (nonatomic, readonly, copy) NSString *target;
/// Whether the method being hooked is a class method or not.
@property (nonatomic, readonly) BOOL isClassMethod;
/// The underlying MirrorKit method.
@property (nonatomic, readonly) MKMethod *method;
/// A reference to the original implementation of the method.
@property (nonatomic, readonly) IMP originalImplementation;

/// @brief May leave nil to use original return value.
///
/// @discussion Hooking the return value will completely replace the method implementation,
/// which means if the original method does anything other than compute and return a value,
/// that code will not be executed. In the future I will provide a mechanism to choose whether
/// or not the original method be invoked before returning a value.
///
/// @note `hookedArguments` and `chirpString` are set to nil when this property is set.
@property (nonatomic, nullable, copy) TBValue *hookedReturnValue;

/// @brief Use [TBValue orig] to leave an argument unmodified if you only wish to hook some arguments.
///
/// @discussion Each argument must be present to hook any arguments. Behavior is undefined
/// if this array has fewer arguments than the method takes. You must include `self` and `_cmd`.
///
/// @note `hookedReturnValue` and `chirpString` are set to nil when this property is set.
@property (nonatomic, nullable, copy) NSArray<TBValue*> *hookedArguments;

/// @brief The Chirp language implementation for the method.
///
/// @discussion Chirp is a simple runtime-interpreted language I'm writing to
/// allow overriding specific types or entire methods. You can set this property
/// to an empty string to make the method not do anything.
///
/// @warning I have not implemented or documented Chirp yet so the only thing you can use this
/// for is to make the method do nothing by providing an empty string.
/// @note `hookedReturnValue` and `hookedArguments` are set to nil when this property is set.
@property (nonatomic, nullable, copy) NSString *chirpString;

/// @brief Block takes the new implementation OR an error indicating why the implementation may be null if it is nil.
/// At least one parameter will not be nil.
- (void)getImplementation:(void(^)(IMP _Nullable implementation,  NSError * _Nullable error))implementationHandler;

@end
NS_ASSUME_NONNULL_END


#define ObjectToProperType(thing, returnType) switch (returnType) {\
