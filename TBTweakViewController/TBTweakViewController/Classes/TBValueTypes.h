//
//  TBValueTypes.h
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIGeometry.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import "MirrorKit-Constants.h"

@class TBValue, EnumSet;

typedef NS_ENUM(NSUInteger, TBValueType)
{
    TBValueTypeUnmodified,
    TBValueTypeNilValue,
    TBValueTypeChirpValue,
    TBValueTypeClass,
    TBValueTypeObject,
    TBValueTypeSelector,
    TBValueTypeFloat,
    TBValueTypeDouble,
    TBValueTypeInteger,
    TBValueTypeString,
    TBValueTypeMutableString,
    TBValueTypeDate,
    TBValueTypeColor,
    TBValueTypeArray,
    TBValueTypeSet,
    TBValueTypeDictionary,
    TBValueTypeMutableArray,
    TBValueTypeMutableSet,
    TBValueTypeMutableDictionary,
    TBValueTypeStruct
};

typedef NS_OPTIONS(NSUInteger, TBStructType)
{
    TBStructTypeNotStruct         = 1 << 0,
    TBStructTypeDualNSInteger     = 1 << 1,
    TBStructTypeQuadNSInteger     = 1 << 2,
    TBStructTypeDualCGFloat       = 1 << 3,
    TBStructTypeQuadCGFloat       = 1 << 4,

    TBStructTypeVector            = (1 << 5) & TBStructTypeDualCGFloat,
    TBStructTypePoint             = (1 << 6) & TBStructTypeDualCGFloat,
    TBStructTypeSize              = (1 << 7) & TBStructTypePoint,
    TBStructTypeRect              = (1 << 8) & TBStructTypeQuadCGFloat,
    TBStructTypeEdgeInsets        = (1 << 9) & TBStructTypeQuadCGFloat,

    TBStructTypeRange             = (1 << 10) & TBStructTypeDualNSInteger,

    TBStructTypeCGAffineTransform = 1 << 11,
    TBStructTypeCATransform3D     = 1 << 12,

    TBStructTypePrimitiveValue    = 1 << 30
};

typedef union _TBStruct {
    uint8_t  int8;
    uint16_t int16;
    uint32_t int32;
    uint64_t int64;
    float    singlePrecisionFloat;
    double   doublePrecisionFloat;
    void *   object;
    
    CGRect rect;
    CGVector vector;
    CGPoint point;
    CGSize size;
    UIEdgeInsets insets;
    NSRange range;
    CGAffineTransform transform;
    CATransform3D transform3D;
    struct {
        NSUInteger a, b, c, d;
    } quadNSInteger;
} TBStruct;

extern BOOL TBValueTypeIsCollection(TBValueType type);
extern BOOL TBCanChangeType(MKTypeEncoding encoding);

extern NSString * TBStringFromValueType(TBValueType type);
extern NSString * TBStringFromValueOrStructType(TBValueType type, TBStructType structType);
extern NSString * TBStringFromStruct(TBValue *value);

extern TBValueType TBValueTypeFromTypeEncoding(const char *encoding);
extern TBStructType TBStructTypeFromTypeEncoding(const char *encoding);
extern TBStruct TBDefaultValueForStructType(TBStructType type);
extern NSValue * TBNSValueFromStruct(TBStruct structt, TBStructType type);
extern NSValue * TBDefaultValueForStruct(const char *encoding);
extern TBStruct TBStructFromNSValue(TBStructType type, NSValue *value);

extern EnumSet * TBAllowedTypesForEncoding(MKTypeEncoding encoding);
