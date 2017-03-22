//
//  TBValue.h
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBValueTypes.h"

NS_ASSUME_NONNULL_BEGIN


/// @brief Class to specifiy the state of the return type
/// or an argument to a hooked method.
///
/// @discussion Use `+value:type:` to override with a value.
/// +null is for convenience, `value:nil` works too.
/// Use `+orig` or `+new` to leave a value unmodified.
@interface TBValue : NSObject <NSCoding, NSCopying> {
    @public
    TBStruct _structValue;
}

/// @brief Represents the value not be modified. Works for all types.
+ (instancetype)orig;
/// @brief Represents the value be converted to the type's null equivalent.
/// @discussion Works for all types. The `overriden` property will be YES
+ (instancetype)null;

/// @brief Represents a value "overridden" with a specific type.
/// @param value The value to use. This parameter can be accessed later via the `value` property.
/// @param type The type of the provided value, not necessarily that of the thing being overridden.
///             An object type may of course use any of the object values in `TBValueType`.
///             Provide an `NSNumber` or `NSValue` instance types along with
///             `TBValueTypeNumber` to represent any primitive type, except complex structs.
///             This parameter can be accessed later via the `type` property.
+ (instancetype)value:(id)value type:(TBValueType)type;

/// @brief Represents a value "overridden" with a specific type.
/// @param value The struct value to use. This parameter can be accessed later via the `value` property.
/// @param type The type of the struct contained in the provided value.
///             This parameter can be accessed later via the `type` property.
+ (instancetype)value:(NSValue *)value structType:(TBStructType)structType;

/// Provides safe default `TBValue` instances
/// for various `TBValueType` values, excluding `TBValueTypeStruct`.
+ (instancetype)defaultForValueType:(TBValueType)type;

+ (instancetype)defaultForAgumentAtIndex:(NSUInteger)idx ofMethodWith:(NSMethodSignature *)signature;

+ (instancetype)defaultValueForTypeEncoding:(const char *)encoding;

/// Only `NO` if you use +new or +orig to initialize
@property (nonatomic, readonly) BOOL overriden;
@property (nonatomic, readonly) BOOL notOverridden;
@property (nonatomic, readonly) id<NSObject, NSCoding> value;
@property (nonatomic, readonly) TBValueType type;
@property (nonatomic, readonly) TBStructType structType;

/// The `value` property is parsed into this struct. Internal use mostly.
@property (nonatomic, readonly) TBStruct structValue;

@end

static inline void TBValueMemcpyIfOverride(TBValue *value, void *dest, ssize_t byteCount) {
    if (value.overriden) {
        memcpy(dest, &value->_structValue, byteCount);
    }
}

NS_ASSUME_NONNULL_END
