//
//  TBValue.h
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, TBValueType)
{
    TBValueTypeUnmodified,
    TBValueTypeNilValue,
    TBValueTypeChirpValue,
    TBValueTypeClass,
    TBValueTypeSelector,
    TBValueTypeNumber,
    TBValueTypeString,
    TBValueTypeMutableString,
    TBValueTypeDate,
    TBValueTypeColor,
    TBValueTypeArray,
    TBValueTypeDictionary,
    TBValueTypeSet,
    TBValueTypeMutableArray,
    TBValueTypeMutableSet,
    TBValueTypeMutableDictionary
};


NS_ASSUME_NONNULL_BEGIN

extern NSString * TBStringFromValueType(TBValueType type);

/// Use +value: to override with a value.
/// +null is for convenience, value:nil works too.
/// Use +original or +new to leave a value unmodified.
@interface TBValue : NSObject <NSCoding, NSCopying>

+ (instancetype)orig;
+ (instancetype)null;
+ (instancetype)value:(id)value type:(TBValueType)type;

/// Only NO if you use +new
@property (nonatomic, readonly) BOOL overriden;
@property (nonatomic, readonly) id<NSObject, NSCoding> value;
@property (nonatomic, readonly) TBValueType type;

@end
NS_ASSUME_NONNULL_END
