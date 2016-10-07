//
//  MirrorKit-Constants.h
//  MirrorKit
//
//  Created by Tanner on 7/1/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Property attributes
extern NSString * const MKPropertyAttributeKeyTypeEncoding;
extern NSString * const MKPropertyAttributeKeyBackingIVarName;
extern NSString * const MKPropertyAttributeKeyCopy;
extern NSString * const MKPropertyAttributeKeyCustomGetter;
extern NSString * const MKPropertyAttributeKeyCustomSetter;
extern NSString * const MKPropertyAttributeKeyDynamic;
extern NSString * const MKPropertyAttributeKeyGarbageCollectible;
extern NSString * const MKPropertyAttributeKeyNonAtomic;
extern NSString * const MKPropertyAttributeKeyOldTypeEncoding;
extern NSString * const MKPropertyAttributeKeyReadOnly;
extern NSString * const MKPropertyAttributeKeyRetain;
extern NSString * const MKPropertyAttributeKeyWeak;

typedef NS_ENUM(NSUInteger, MKPropertyAttribute)
{
    MKPropertyAttributeTypeEncoding       = 'T',
    MKPropertyAttributeBackingIVarName    = 'V',
    MKPropertyAttributeCopy               = 'C',
    MKPropertyAttributeCustomGetter       = 'G',
    MKPropertyAttributeCustomSetter       = 'S',
    MKPropertyAttributeDynamic            = 'D',
    MKPropertyAttributeGarbageCollectible = 'P',
    MKPropertyAttributeNonAtomic          = 'N',
    MKPropertyAttributeOldTypeEncoding    = 't',
    MKPropertyAttributeReadOnly           = 'R',
    MKPropertyAttributeRetain             = '&',
    MKPropertyAttributeWeak               = 'W'
};

typedef NS_ENUM(NSUInteger, MKTypeEncoding)
{
    MKTypeEncodingUnknown          = '?',
    MKTypeEncodingChar             = 'c',
    MKTypeEncodingInt              = 'i',
    MKTypeEncodingShort            = 's',
    MKTypeEncodingLong             = 'l',
    MKTypeEncodingLongLong         = 'q',
    MKTypeEncodingUnsignedChar     = 'C',
    MKTypeEncodingUnsignedInt      = 'I',
    MKTypeEncodingUnsignedShort    = 'S',
    MKTypeEncodingUnsignedLong     = 'L',
    MKTypeEncodingUnsignedLongLong = 'Q',
    MKTypeEncodingFloat            = 'f',
    MKTypeEncodingDouble           = 'd',
    MKTypeEncodingCBool            = 'B',
    MKTypeEncodingVoid             = 'v',
    MKTypeEncodingCString          = '*',
    MKTypeEncodingObjcObject       = '@',
    MKTypeEncodingObjcClass        = '#',
    MKTypeEncodingSelector         = ':',
    MKTypeEncodingArray            = '[',
    MKTypeEncodingStruct           = '{',
    MKTypeEncodingUnion            = '(',
    MKTypeEncodingBitField         = 'b',
    MKTypeEncodingPointer          = '^'
};