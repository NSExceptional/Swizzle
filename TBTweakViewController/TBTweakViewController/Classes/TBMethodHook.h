//
//  TBMethodHook.h
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "MirrorKit/MirrorKit.h"
#import "TBValue.h"


NSInvocation * _Nonnull TBInvocationFromArguments(NSMethodSignature * _Nonnull signature, NSArray<TBValue*> * _Nonnull args);
BOOL TBCanHookMethodReturnType(MKMethod * _Nonnull method);
BOOL TBCanHookAllArgumentTypes(MKMethod * _Nonnull method);

NS_ASSUME_NONNULL_BEGIN
@interface TBMethodHook : NSObject <NSCoding>

+ (instancetype)target:(Class)cls action:(SEL)selector isClassMethod:(BOOL)classMethod;

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

/// May leave nil to use original return value.
/// `hookedArguments` and `chirpString` are set to nil when this property is set.
@property (nonatomic, nullable, copy) TBValue *hookedReturnValue;
/// Each argument must be present to hook any arguments.
/// `hookedReturnValue` and `chirpString` are set to nil when this property is set.
@property (nonatomic, nullable, copy) NSArray<TBValue*> *hookedArguments;

/// `hookedReturnValue` and `hookedArguments` are set to nil when this property is set.
/// @discussion You can set this property to an empty string to make the method
/// not do anything.
@property (nonatomic, nullable, copy) NSString *chirpString;

/// Block takes the new implementation and an error indicating why the implementation may be null.
- (void)getImplementation:(void(^)(IMP _Nullable implementation,  NSError * _Nullable error))implementationHandler;

@end
NS_ASSUME_NONNULL_END


#define ObjectToProperType(thing, returnType) switch (returnType) {\
