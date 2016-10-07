//
//  MKProperty.m
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "MKProperty.h"
#import "MKPropertyAttributes.h"
#import "MKSimpleMethod.h"
#import "NSString+Utilities.h"
#import "NSObject+Reflection.h"


@implementation MKProperty

- (id)init { [NSException raise:NSInternalInconsistencyException format:@"Class instance should not be created with -init"]; return nil; }

#pragma mark Initializers
+ (instancetype)property:(objc_property_t)property {
    return [[self alloc] initWithProperty:property];
}

+ (instancetype)propertyWithName:(NSString *)name attributesString:(NSString *)attributesString {
    return [self propertyWithName:name attributes:[MKPropertyAttributes attributesFromString:attributesString]];
}

+ (instancetype)propertyWithName:(NSString *)name attributes:(MKPropertyAttributes *)attributes {
    return [[self alloc] initWithName:name attributes:attributes];
}

- (id)initWithProperty:(objc_property_t)property {
    NSParameterAssert(property);
    
    self = [super init];
    if (self) {
        _objc_property = property;
        _attributes    = [MKPropertyAttributes attributesFromString:@(property_getAttributes(self.objc_property))];
        _name          = @(property_getName(self.objc_property));
        
        if (!_attributes) [NSException raise:NSInternalInconsistencyException format:@"Error retrieving property attributes"];
        if (!_name) [NSException raise:NSInternalInconsistencyException format:@"Error retrieving property name"];
        
        [self examine];
    }
    
    return self;
}

- (id)initWithName:(NSString *)name attributes:(MKPropertyAttributes *)attributes {
    NSParameterAssert(name); NSParameterAssert(attributes);
    
    self = [super init];
    if (self) {
        _attributes    = attributes;
        _name          = name;
        
        [self examine];
    }
    
    return self;
}

#pragma mark Misc
- (void)examine {
    _type = (MKTypeEncoding)[self.attributes.typeEncoding characterAtIndex:0];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ name=%@, >\nAttributes:\n\t%@",
            NSStringFromClass(self.class), self.name, self.attributes];
}

- (objc_property_attribute_t *)copyAttributesList:(unsigned int *)attributesCount {
    if (self.objc_property) {
        return property_copyAttributeList(self.objc_property, attributesCount);
    } else {
        return [self.attributes copyAttributesList:attributesCount];
    }
}

#pragma mark Suggested getters and setters
- (MKSimpleMethod *)getterWithImplementation:(IMP)implementation {
    NSString *types        = [NSString stringWithFormat:@"%@%s%s", self.attributes.typeEncoding, @encode(id), @encode(SEL)];
    NSString *name         = [NSString stringWithFormat:@"%@", self.name];
    MKSimpleMethod *getter = [MKSimpleMethod buildMethodNamed:name withTypes:types implementation:implementation];
    return getter;
}

- (MKSimpleMethod *)setterWithImplementation:(IMP)implementation {
    NSString *types        = [NSString stringWithFormat:@"%s%s%s%@", @encode(void), @encode(id), @encode(SEL), self.attributes.typeEncoding];
    NSString *name         = [NSString stringWithFormat:@"set%@:", self.name.capitalizedString];
    MKSimpleMethod *setter = [MKSimpleMethod buildMethodNamed:name withTypes:types implementation:implementation];
    return setter;
}

@end
