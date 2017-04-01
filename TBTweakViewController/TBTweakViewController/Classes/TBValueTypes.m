//
//  TBValueTypes.m
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueTypes.h"
#import "TBValue.h"
#import "EnumSet.h"


BOOL TBValueTypeIsCollection(TBValueType type) {
    switch (type) {
        case TBValueTypeArray:
        case TBValueTypeDictionary:
        case TBValueTypeSet:
        case TBValueTypeMutableArray:
        case TBValueTypeMutableSet:
        case TBValueTypeMutableDictionary:
            return YES;
        default:
            return NO;
    }
}

BOOL TBCanChangeType(MKTypeEncoding encoding) {
    switch (encoding) {
        case MKTypeEncodingObjcObject:
        case MKTypeEncodingObjcClass:
        case MKTypeEncodingSelector:
        case MKTypeEncodingCString:
        case MKTypeEncodingPointer:
            return YES;
        default:
            return NO;
    }

}

NSString * TBStringFromValueType(TBValueType type) {
    switch (type) {
        case TBValueTypeUnmodified: {
            return @"Unmodified";
        }
        case TBValueTypeNilValue: {
            return @"nil / null";
        }
        case TBValueTypeChirpValue: {
            return @"Return value of Chirp function";
        }
        case TBValueTypeClass: {
            return @"Class object";
        }
        case TBValueTypeObject: {
            return @"Any object";
        }
        case TBValueTypeSelector: {
            return @"Selector (SEL)";
        }
        case TBValueTypeFloat: {
            return @"Float";
        }
        case TBValueTypeDouble: {
            return @"Double";
        }
        case TBValueTypeInteger: {
            return @"Integer";
        }
        case TBValueTypeNumber: {
            return @"NSNumber";
        }
        case TBValueTypeString: {
            return @"NSString (or char *)";
        }
        case TBValueTypeMutableString: {
            return @"NSMutableString";
        }
        case TBValueTypeDate: {
            return @"NSDate";
        }
        case TBValueTypeColor: {
            return @"UIColor";
        }
        case TBValueTypeArray: {
            return @"NSArray";
        }
        case TBValueTypeDictionary: {
            return @"NSDictionary";
        }
        case TBValueTypeSet: {
            return @"NSSet";
        }
        case TBValueTypeMutableArray: {
            return @"NSMutableArray";
        }
        case TBValueTypeMutableSet: {
            return @"NSMutableSet";
        }
        case TBValueTypeMutableDictionary: {
            return @"NSMutableDictionary";
        }
        case TBValueTypeStruct: {
            return @"struct";
        }
    }
}

NSString * TBStringFromStructType(TBStructType type) {
    if (type & TBStructTypeNotStruct)
        return @"not a struct";
    if (type & TBStructTypeVector)
        return @"CGVector";
    if (type & TBStructTypePoint)
        return @"CGPoint";
    if (type & TBStructTypeSize)
        return @"CGSize";
    if (type & TBStructTypeRect)
        return @"CGRect";
    if (type & TBStructTypeEdgeInsets)
        return @"UIEdgeInsets";
    if (type & TBStructTypeRange)
        return @"NSRange";
    if (type & TBStructTypeCGAffineTransform)
        return @"CGAffineTransform";
    if (type & TBStructTypeCATransform3D)
        return @"CATransform3D";

    if (type & TBStructTypeDualNSInteger)
        return @"struct {NSInteger, NSInteger}";
    if (type & TBStructTypeQuadNSInteger)
        return @"struct {NSInteger, NSInteger, NSInteger, NSInteger}";
    if (type & TBStructTypeDualCGFloat)
        return @"struct {CGFloat, CGFloat}";
    if (type & TBStructTypeQuadCGFloat)
        return @"struct {CGFloat, CGFloat, CGFloat, CGFloat}";

    @throw NSInvalidArgumentException;
}

NSString * TBStringFromValueOrStructType(TBValueType type, TBStructType structType) {
    switch (type) {
        case TBValueTypeStruct:
            return TBStringFromStructType(structType);
        default:
            return TBStringFromValueType(type);
    }
}

NSString * TBStringFromStruct(TBValue *value) {
    TBStructType type = value.structType;
    
    if (type & TBStructTypeNotStruct)
        return @"not a struct";
    if (type & TBStructTypeVector)
        return NSStringFromCGVector(value.structValue.vector);
    if (type & TBStructTypePoint)
        return NSStringFromCGPoint(value.structValue.point);
    if (type & TBStructTypeSize)
        return NSStringFromCGSize(value.structValue.size);
    if (type & TBStructTypeRect)
        return NSStringFromCGRect(value.structValue.rect);
    if (type & TBStructTypeEdgeInsets)
        return NSStringFromUIEdgeInsets(value.structValue.insets);
    if (type & TBStructTypeRange)
        return NSStringFromRange(value.structValue.range);
    if (type & TBStructTypeCGAffineTransform)
        return NSStringFromCGAffineTransform(value.structValue.transform);
    if (type & TBStructTypeCATransform3D)
        return @"Lol no";

    @throw NSInvalidArgumentException;
}


TBValueType TBValueTypeFromTypeEncoding(const char *encoding) {
    MKTypeEncoding type = encoding[0];
    switch (type) {
        case MKTypeEncodingUnknown:
            return TBValueTypeNilValue;

        case MKTypeEncodingChar:
        case MKTypeEncodingInt:
        case MKTypeEncodingShort:
        case MKTypeEncodingLong:
        case MKTypeEncodingLongLong:
        case MKTypeEncodingUnsignedChar:
        case MKTypeEncodingUnsignedInt:
        case MKTypeEncodingUnsignedShort:
        case MKTypeEncodingUnsignedLong:
        case MKTypeEncodingUnsignedLongLong:
        case MKTypeEncodingCBool:
        case MKTypeEncodingPointer:
            return TBValueTypeInteger;

        case MKTypeEncodingFloat:
            return TBValueTypeFloat;
        case MKTypeEncodingDouble:
            return TBValueTypeDouble;

        case MKTypeEncodingSelector:
            return TBValueTypeSelector;
        case MKTypeEncodingCString:
            return TBValueTypeString;
        case MKTypeEncodingObjcObject:
            return TBValueTypeObject;
        case MKTypeEncodingObjcClass:
            return TBValueTypeClass;

        case MKTypeEncodingVoid:
            return TBValueTypeNilValue;

        case MKTypeEncodingArray:
        case MKTypeEncodingStruct:
        case MKTypeEncodingUnion:
        case MKTypeEncodingBitField:
            return TBValueTypeStruct;
    }
}

TBStructType TBStructTypeFromTypeEncoding(const char *encoding) {
    NSString *signature = @(encoding);

    if ([signature hasPrefix:@"{CG"] ||
        [signature hasPrefix:@"{NS"] ||
        [signature hasPrefix:@"{UI"] ||
        [signature hasPrefix:@"{CA"]) {
        if ([signature hasPrefix:@"{CGVector="]) {
            return TBStructTypeVector;
        }
        if ([signature hasPrefix:@"{CGPoint="] || [signature hasPrefix:@"{NSPoint="]) {
            return TBStructTypePoint;
        }
        if ([signature hasPrefix:@"{CGSize="] || [signature hasPrefix:@"{NSSize="]) {
            return TBStructTypeSize;
        }
        if ([signature hasPrefix:@"{CGRect="] || [signature hasPrefix:@"{NSRect="]) {
            return TBStructTypeRect;
        }
        if ([signature hasPrefix:@"{UIEdgeInsets="] || [signature hasPrefix:@"{NSEdgeInsets="]) {
            return TBStructTypeEdgeInsets;
        }
        if ([signature hasPrefix:@"{NSRange="]) {
            return TBStructTypeRange;
        }
        if ([signature hasPrefix:@"{CGAffineTransform="]) {
            return TBStructTypeCGAffineTransform;
        }
        if ([signature hasPrefix:@"{CATransform3D="]) {
            return TBStructTypeCATransform3D;
        }
    }

    NSUInteger size;
    NSGetSizeAndAlignment(encoding, &size, NULL);

    if (size == sizeof(struct {NSInteger a, b;})) {
        return TBStructTypeDualNSInteger;
    }
    else if (size == sizeof(struct {NSInteger a, b, c, d;})) {
        return TBStructTypeQuadNSInteger;
    }
    else if (size == sizeof(struct {CGFloat a, b;})) {
        return TBStructTypeDualCGFloat;
    }
    else if (size == sizeof(struct {CGFloat a, b, c, d;})) {
        return TBStructTypeQuadCGFloat;
    }

    return TBStructTypePrimitiveValue;
}

TBStruct TBDefaultValueForStructType(TBStructType type) {
    TBStruct t;

    // Floating point values must be explicitly initialized to zero
    if (type & TBStructTypeDualCGFloat ||
        type & TBStructTypeQuadCGFloat) {
        t.rect = CGRectZero;
    } else {
        memset(&t.quadNSInteger, 0, sizeof(t.quadNSInteger));
    }

    return t;
}

// TODO remove?
NSValue * TBNSValueFromStruct(TBStruct structt, TBStructType type) {
    if (type & TBStructTypeDualNSInteger) {
        return [NSValue valueWithRange:structt.range];
    }
    if (type & TBStructTypeQuadNSInteger) {
        return [NSValue value:&structt.quadNSInteger withObjCType:@encode(struct {NSInteger a, b, c, d;})];
    }
    if (type & TBStructTypeDualCGFloat) {
        return [NSValue valueWithCGPoint:structt.point];
    }
    if (type & TBStructTypeQuadCGFloat) {
        return [NSValue valueWithCGRect:structt.rect];
    }

    return nil;
}

NSValue * TBDefaultValueForStruct(const char *encoding) {
    TBStruct s = TBDefaultValueForStructType(TBStructTypeFromTypeEncoding(encoding));
    return [NSValue value:&s withObjCType:encoding];
}

TBStruct TBStructFromNSValue(TBStructType type, NSValue *value) {
    if (type & TBStructTypeNotStruct) {
        @throw NSInvalidArgumentException;
    }

    TBStruct structure;
    [value getValue:&structure];
    return structure;
}

EnumSet * TBAllowedTypesForEncoding(MKTypeEncoding encoding) {
    EnumSet *allowed = [EnumSet set];
    switch (encoding) {
        case MKTypeEncodingUnknown: {
            break;
        }
        case MKTypeEncodingChar:
        case MKTypeEncodingInt:
        case MKTypeEncodingShort:
        case MKTypeEncodingLong:
        case MKTypeEncodingLongLong:
        case MKTypeEncodingUnsignedChar:
        case MKTypeEncodingUnsignedInt:
        case MKTypeEncodingUnsignedShort:
        case MKTypeEncodingUnsignedLong:
        case MKTypeEncodingUnsignedLongLong:
        case MKTypeEncodingPointer:
        case MKTypeEncodingFloat:
        case MKTypeEncodingDouble:
        case MKTypeEncodingCBool: {
            [allowed addIndex:TBValueTypeInteger];
            [allowed addIndex:TBValueTypeFloat];
            [allowed addIndex:TBValueTypeDouble];
            break;
        }
        case MKTypeEncodingVoid: {
            break;
        }
        case MKTypeEncodingSelector:
        case MKTypeEncodingCString: {
            [allowed addIndex:TBValueTypeNilValue];
            [allowed addIndex:TBValueTypeString];
            break;
        }
        case MKTypeEncodingObjcObject: {
            [allowed addIndex:TBValueTypeNilValue];
            // [allowed addIndex:TBValueTypeChirpValue];
            [allowed addIndex:TBValueTypeClass];
            [allowed addIndex:TBValueTypeDate];
            [allowed addIndex:TBValueTypeNumber];
            [allowed addIndex:TBValueTypeString];
            [allowed addIndex:TBValueTypeArray];
            [allowed addIndex:TBValueTypeDictionary];
            [allowed addIndex:TBValueTypeSet];
            [allowed addIndex:TBValueTypeMutableString];
            [allowed addIndex:TBValueTypeMutableArray];
            [allowed addIndex:TBValueTypeMutableDictionary];
            [allowed addIndex:TBValueTypeMutableSet];
            break;
        }
        case MKTypeEncodingObjcClass: {
            [allowed addIndex:TBValueTypeClass];
            [allowed addIndex:TBValueTypeNilValue];
            break;
        }
        case MKTypeEncodingArray:
        case MKTypeEncodingStruct:
        case MKTypeEncodingUnion:
        case MKTypeEncodingBitField: {
            // We will never show the type picker for structs
            // [self.allowedValueTypes addIndex:TBValueTypeUnmodified];
            break;
        }
    }

    return allowed;
}
