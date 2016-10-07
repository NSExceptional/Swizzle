//
//  TBValue.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValue.h"


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
        case TBValueTypeNumber: {
            return @"Number (NSNumber, BOOL, int, etc)";
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
    }
}

extern BOOL TBValueTypeIsCollection(TBValueType type) {
    switch (type) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue:
        case TBValueTypeChirpValue:
        case TBValueTypeClass:
        case TBValueTypeSelector:
        case TBValueTypeNumber:
        case TBValueTypeString:
        case TBValueTypeMutableString:
        case TBValueTypeDate:
        case TBValueTypeColor:
            return NO;
        case TBValueTypeArray:
        case TBValueTypeDictionary:
        case TBValueTypeSet:
        case TBValueTypeMutableArray:
        case TBValueTypeMutableSet:
        case TBValueTypeMutableDictionary:
            return YES;
    }
}

@implementation TBValue

#pragma mark Initialization

+ (instancetype)orig { return [self new]; }

+ (instancetype)null {
    TBValue *value = [TBValue new];
    value->_overriden = YES;
    return value;
}

+ (instancetype)value:(id)v type:(TBValueType)t {
    TBValue *value = [TBValue null];
    value->_value  = v;
    value->_type   = t;
    return value;
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
    TBValue *val    = [[self class] orig];
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
