//
//  TBValue+ValueHelpers.m
//  TBTweakViewController
//
//  Created by Tanner on 10/6/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValue+ValueHelpers.h"


#define assertType(t) if (self.type != t) { [NSException raise:NSInternalInconsistencyException format:@"Type is %@, tried to access %s", TBStringFromValueType(self.type), sel_getName(_cmd)]; }

@implementation TBValue (ValueHelpers)

- (NSString *)chirpValue {
    assertType(TBValueTypeChirpValue);
    return (NSString *)self.value;
}

- (NSString *)classNameValue {
    assertType(TBValueTypeClass);
    return (NSString *)self.value;
}

- (NSString *)selectorValue {
    assertType(TBValueTypeSelector);
    return (NSString *)self.value;
}

- (NSNumber *)numberValue {
    if (self.type != TBValueTypeFloat || self.type != TBValueTypeDouble || self.type != TBValueTypeInteger) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Type is %@, tried to access %s", TBStringFromValueType(self.type), sel_getName(_cmd)];
    }
    
    return (NSNumber *)self.value;
}

- (NSString *)stringValue {
    assertType(TBValueTypeString);
    return (NSString *)self.value;
}

- (NSMutableString *)mutableStringValue {
    assertType(TBValueTypeMutableString);
    return (NSMutableString *)self.value;
}

- (NSDate *)dateValue {
    assertType(TBValueTypeDate);
    return (NSDate *)self.value;
}

- (UIColor *)colorValue {
    assertType(TBValueTypeColor);
    return (UIColor *)self.value;
}

- (NSArray *)arrayValue {
    assertType(TBValueTypeArray);
    return (NSArray *)self.value;
}

- (NSSet *)setValue {
    assertType(TBValueTypeSet);
    return (NSSet *)self.value;
}

- (NSDictionary *)dictionaryValue {
    assertType(TBValueTypeDictionary);
    return (NSDictionary *)self.value;
}

- (NSMutableArray *)mutableArrayValue {
    assertType(TBValueTypeMutableArray);
    return (NSMutableArray *)self.value;
}

- (NSMutableSet *)mutableSetValue {
    assertType(TBValueTypeMutableSet);
    return (NSMutableSet *)self.value;
}

- (NSMutableDictionary *)mutableDictionaryValue {
    assertType(TBValueTypeMutableDictionary);
    return (NSMutableDictionary *)self.value;
}

@end
