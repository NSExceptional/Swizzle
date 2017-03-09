//
//  TBValueTypes.m
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueTypes.h"


extern NSString * TBStringFromValueOrStructType(TBValueType type, TBStructType structType) {
    switch (type) {
        case TBValueTypeStruct:
            return TBStringFromStructType(structType);
        default:
            return TBStringFromValueType(type);
    }
}

extern NSString * TBStringFromValueType(TBValueType type) {
    switch (type) {
        case TBValueTypeUnmodified: {
            return @"Unmodified";
        }
        case TBValueTypeNilValue: {
            return @"nil / NULL";
        }
        case TBValueTypeChirpValue: {
            return @"Return value of Chirp function";
        }
        case TBValueTypeClass: {
            return @"Class object";
        }
        case TBValueTypeSelector: {
            return @"Selector (SEL)";
        }
        case TBValueTypeFloat:
        case TBValueTypeDouble:
        case TBValueTypeInteger: {
            return @"Number (NSNumber, BOOL, int, float, etc)";
        }
        case TBValueTypeString: {
            return @"String (NSString, char *)";
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

extern NSString * TBStringFromStructType(TBStructType type) {
    if (TBStructTypeNotStruct & type)
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

extern BOOL TBValueTypeIsCollection(TBValueType type) {
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

extern TBStruct TBStructFromNSValue(TBStructType type, NSValue *value) {
    if (type & TBStructTypeNotStruct) {
        @throw NSInvalidArgumentException;
    }

    TBStruct structure;
    [value getValue:&structure];
    return structure;
}
