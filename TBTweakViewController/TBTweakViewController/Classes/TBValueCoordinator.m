//
//  TBValueCoordinator.m
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueCoordinator.h"
#import "TBValue.h"
#import <objc/runtime.h>


@implementation TBValueCoordinator

+ (instancetype)coordinateType:(TBValueType)type {
    TBValueCoordinator *coordinator = [self new];
    coordinator->_valueType = type;
    coordinator->_container = [TBValue defaultForValueType:type];
    return coordinator;
}

- (void)setColor:(UIColor *)color {
    _container = [TBValue value:color type:TBValueTypeColor];
}

- (NSString *)string {
    if (self.container.type == TBValueTypeString) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setString:(NSString *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeString];
}

- (NSNumber *)number {
    TBValueType type = self.container.type;
    if (type == TBValueTypeInteger ||
        type == TBValueTypeFloat ||
        type == TBValueTypeDouble) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setNumber:(NSNumber *)number {
    switch (self.valueType) {
        case TBValueTypeInteger:
            self.integer = number;
            break;
        case TBValueTypeFloat:
            self.singleFloat = number;
            break;
        case TBValueTypeDouble:
            self.doubleFloat = number;
            break;
        case TBValueTypeNumber:
            self.container = [TBValue value:number type:TBValueTypeNumber];

        default:
            @throw NSInternalInconsistencyException;
    }
}

- (NSNumber *)integer {
    if (self.container.type == TBValueTypeInteger) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setInteger:(NSNumber *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeInteger];
}

- (NSNumber *)singleFloat {
    if (self.container.type == TBValueTypeFloat) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setSingleFloat:(NSNumber *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeFloat];
}

- (NSNumber *)doubleFloat {
    if (self.container.type == TBValueTypeDouble) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setDoubleFloat:(NSNumber *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeDouble];
}

- (NSString *)chirpString {
    if (self.container.type == TBValueTypeChirpValue) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setChirpString:(NSString *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeChirpValue];
}

- (id)object {
    return self.container.value;
}

- (void)setObject:(id)object {
    TBValueType type;

    if (object == [NSNull null]) {
        _container = [TBValue null];
        return;
    }

    if (object_isClass(object)) {
        type = TBValueTypeClass;
    } else if ([object isKindOfClass:[NSMutableString class]])
        type = TBValueTypeMutableString;
    else if ([object isKindOfClass:[NSString class]])
        type = TBValueTypeString;
    else if ([object isKindOfClass:[NSMutableArray class]])
        type = TBValueTypeMutableArray;
    else if ([object isKindOfClass:[NSArray class]])
        type = TBValueTypeArray;
    else if ([object isKindOfClass:[NSMutableDictionary class]])
        type = TBValueTypeMutableDictionary;
    else if ([object isKindOfClass:[NSDictionary class]])
        type = TBValueTypeDictionary;
    else if ([object isKindOfClass:[NSMutableSet class]])
        type = TBValueTypeMutableSet;
    else if ([object isKindOfClass:[NSSet class]])
        type = TBValueTypeSet;
    else if ([object isKindOfClass:[UIColor class]])
        type = TBValueTypeColor;
    else if ([object isKindOfClass:[NSDate class]])
        type = TBValueTypeDate;
    else if ([object isKindOfClass:[NSNumber class]])
        type = TBValueTypeNumber;

    else {
        type = TBValueTypeObject;
    }

    _container = [TBValue value:object type:type];
}

@end
