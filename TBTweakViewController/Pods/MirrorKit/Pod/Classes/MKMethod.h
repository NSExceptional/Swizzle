//
//  MKMethod.h
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKSimpleMethod.h"
#import "MirrorKit-Constants.h"
@import ObjectiveC;

NS_ASSUME_NONNULL_BEGIN

@interface MKMethod : MKSimpleMethod

/// Defaults to instance method
+ (instancetype)method:(Method)method;
+ (instancetype)method:(Method)method isInstanceMethod:(BOOL)isInstanceMethod;

/// Constructs an \c MKMethod for the given method on the given class.
////// @return The newly constructed \c MKMethod object, or \c nil if the
/// specified class or its superclasses do not contain a method with the specified selector.
+ (instancetype)methodForSelector:(SEL)selector class:(Class)cls instance:(BOOL)useInstanceMethod;
/// Constructs an \c MKMethod for the given method on the given class, only if the given
/// class itself defines or overrides the desired method.
////// @return The newly constructed \c MKMethod object, or \c nil \e if the
/// specified class does not define or override, or if the specified class
/// or its superclasses do not contain, a method with the specified selector.
+ (instancetype)methodForSelector:(SEL)selector implementedInClass:(Class)cls instance:(BOOL)useInstanceMethod;

@property (nonatomic, readonly) Method            objc_method;
/// The implementation of the method.
////// @discussion Setting \c implementation will change the implementation of this method
/// for the entire class which implements said method. It will also not modify the selector of said method.
@property (nonatomic          ) IMP               implementation;
/// Whether the method is an instance method or not.
@property (nonatomic, readonly) BOOL              isInstanceMethod;
/// The number of arguments to the method.
@property (nonatomic, readonly) NSUInteger        numberOfArguments;
/// The \c NSMethodSignature object corresponding to the method's type encoding.
@property (nonatomic, readonly) NSMethodSignature *signature;
/// Same as \e typeEncoding but with parameter sizes up front and offsets after the types.
@property (nonatomic, readonly) NSString          *signatureString;
/// The return type of the method.
@property (nonatomic, readonly) MKTypeEncoding    returnType;

/// Like @code - (void)foo:(int)bar @endcode
@property (nonatomic, readonly) NSString *description;
/// Like @code -[Class foo:] @endcode
- (NSString *)debugNameGivenClassName:(NSString *)name;

/// Swizzles the recieving method with the given method.
- (void)swapImplementations:(MKMethod *)method;

#define MKMagicNumber 0xdeadbeef
#define MKArg(expr) MKMagicNumber,/// @encode(__typeof__(expr)), (__typeof__(expr) []){ expr }

/// Sends a message to \e target, and returns it's value, or \c nil if not applicable.
/// @discussion You may send any message with this method. Primitive return values will be wrapped
/// in instances of \c NSNumber and \c NSValue. \c void and bitfield returning methods return \c nil.
/// \c SEL return types are converted to strings using \c NSStringFromSelector.
/// @return The object returned by this method, or an instance of \c NSValue or \c NSNumber containing
/// the primitive return type, or a string for \c SEL return types.
- (id)sendMessage:(id)target, ...;
/// Used internally by \c sendMessage:target,. Pass \c NULL to the first parameter for void methods.
- (void)getReturnValue:(void *)retPtr forMessageSend:(id)target, ...;

@end


@interface MKMethod (Comparison)

- (NSComparisonResult)compare:(MKMethod *)method;

@end

NS_ASSUME_NONNULL_END
