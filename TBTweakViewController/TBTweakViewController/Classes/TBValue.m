//
//  TBValue.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValue.h"
#import <UIKit/UIColor.h>
#import "MirrorKit-Constants.h"


@implementation TBValue

#pragma mark Initialization

+ (instancetype)orig {
    static TBValue *sharedValue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedValue = [self new];
    });
    
    return sharedValue;
}

+ (instancetype)null {
    static TBValue *sharedValue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedValue = [self new];
        sharedValue->_overriden = YES;
        sharedValue->_type = TBValueTypeNilValue;
    });
    
    return sharedValue;
}

+ (instancetype)value:(id)v type:(TBValueType)t {
    if (t == TBValueTypeStruct) @throw NSInvalidArgumentException;

    TBValue *value    = [self new];
    value->_overriden = YES;
    value->_value     = v;
    value->_type      = t;

    if ([v isKindOfClass:[NSValue class]]) {
        value->_structValue = TBStructFromNSValue(TBStructTypePrimitiveValue, v);
    } else {
        value->_structValue.object = (__bridge void *)v;
    }
    
    return value;
}

+ (instancetype)value:(NSValue *)v structType:(TBStructType)structType {
    if (structType == TBStructTypeNotStruct) @throw NSInvalidArgumentException;

    TBValue *value      = [self new];
    value->_overriden   = YES;
    value->_value       = v;
    value->_type        = TBValueTypeStruct;
    value->_structType  = structType;
    value->_structValue = TBStructFromNSValue(structType, v);
    return value;
}

+ (instancetype)defaultForValueType:(TBValueType)type {
    switch (type) {
        case TBValueTypeUnmodified: {
            return [self orig];
        }
        case TBValueTypeNilValue: {
            return [self null];
        }
        case TBValueTypeChirpValue: {
            return [self value:@"" type:type];
        }
        case TBValueTypeClass: {
            return [self value:[NSObject class] type:type];
        }
        case TBValueTypeObject: {
            return [self null];
        }
        case TBValueTypeSelector: {
            return [self value:[NSValue valueWithPointer:"foo:bar:"] type:type];
        }
        case TBValueTypeFloat:
        case TBValueTypeDouble:
        case TBValueTypeInteger:
        case TBValueTypeNumber: {
            return [self value:@1 type:type];
        }
        case TBValueTypeString: {
            return [self value:@"foo" type:type];
        }
        case TBValueTypeMutableString: {
            return [self value:@"foo".mutableCopy type:type];
        }
        case TBValueTypeDate: {
            return [self value:[NSDate date] type:type];
        }
        case TBValueTypeColor: {
            return [self value:[UIColor redColor] type:type];
        }
        case TBValueTypeArray: {
            return [self value:@[] type:type];
        }
        case TBValueTypeDictionary: {
            return [self value:@{} type:type];
        }
        case TBValueTypeSet: {
            return [self value:[NSSet set] type:type];
        }
        case TBValueTypeMutableArray: {
            return [self value:[NSMutableArray array] type:type];
        }
        case TBValueTypeMutableSet: {
            return [self value:[NSMutableSet set] type:type];
        }
        case TBValueTypeMutableDictionary: {
            return [self value:[NSMutableDictionary dictionary] type:type];
        }
        case TBValueTypeStruct:
            @throw NSInvalidArgumentException;
            return nil;
    }
}

+ (instancetype)defaultValueForStruct:(const char *)encoding {
    return [self value:TBDefaultValueForStruct(encoding) structType:TBStructTypeFromTypeEncoding(encoding)];
}

+ (instancetype)defaultValueForTypeEncoding:(const char *)encoding {
    TBValueType type = TBValueTypeFromTypeEncoding(encoding);
    if (type == TBValueTypeStruct) {
        return [self defaultValueForStruct:encoding];
    } else {
        return [self defaultForValueType:type];
    }
}

+ (instancetype)defaultForAgumentAtIndex:(NSUInteger)idx ofMethodWith:(NSMethodSignature *)signature {
    return [self defaultValueForTypeEncoding:[signature getArgumentTypeAtIndex:idx]];
}

- (NSString *)description {
    if (self.overriden) {
        if (self.value) {
            return @"Overridden";
        } else {
            return @"Set to nil";
        }
    } else {
        return @"Unmodified";
    }
}

- (BOOL)notOverridden {
    return !_overriden;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _overriden = [decoder decodeBoolForKey:@"override"];
        _value     = [decoder decodeObjectForKey:@"value"];
        _type      = [decoder decodeIntegerForKey:@"type"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:_overriden forKey:@"override"];
    [coder encodeObject:_value   forKey:@"value"];
    [coder encodeInteger:_type   forKey:@"type"];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    TBValue *val    = [[self class] new];
    val->_overriden = self.overriden;
    val->_value     = self.value;
    val->_type      = self.type;
    return val;
}

#pragma mark Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TBValue class]])
        return [self isEqualToValue:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToValue:(TBValue *)value {
    return ([self.value isEqual:value.value] &&
            self.overriden == value.overriden &&
            self.type == value.type);
}

@end
