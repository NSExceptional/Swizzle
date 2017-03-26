//
//  MKLazyMethod.h
//  Pods
//
//  Created by Tanner on 3/25/17.
//
//

#import "MKMethod.h"

NS_ASSUME_NONNULL_BEGIN

/// Just like \c MKMethod, except almost all of it's properties are lazily
/// initialized. Useful for performance-sensitive sections of code.
///
/// The only properties NOT lazily initialized
/// are \c objc_method, \c signature, and \c signatureString.
///
/// Only supports the given initializers.
@interface MKLazyMethod : MKMethod

#pragma mark - Initialization -
+ (nullable instancetype)methodForSelector:(SEL)selector class:(Class)cls instance:(BOOL)useInstanceMethod;
+ (nullable instancetype)methodForSelector:(SEL)selector implementedInClass:(Class)cls instance:(BOOL)useInstanceMethod;

#pragma mark - Convenience initializers
+ (nullable instancetype)instanceMethod:(SEL)selector class:(Class)cls;
+ (nullable instancetype)instanceMethod:(SEL)selector implementedInClass:(Class)cls;
+ (nullable instancetype)classMethod:(SEL)selector class:(Class)cls;
+ (nullable instancetype)classMethod:(SEL)selector implementedInClass:(Class)cls;

@end
NS_ASSUME_NONNULL_END
