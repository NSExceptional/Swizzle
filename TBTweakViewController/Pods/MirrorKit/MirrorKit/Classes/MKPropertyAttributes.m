//
//  MKPropertyAttributes.m
//  MirrorKit
//
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "MKPropertyAttributes.h"
#import "MirrorKit-Constants.h"
#import "NSString+Utilities.h"
#import "NSDictionary+Utilities.h"


#pragma mark - MKPropertyAttributes -

@interface MKPropertyAttributes ()

@property (nonatomic) NSString *backingIVar;
@property (nonatomic) NSString *typeEncoding;
@property (nonatomic) NSString *oldTypeEncoding;
@property (nonatomic) SEL customGetter;
@property (nonatomic) SEL customSetter;
@property (nonatomic) BOOL isReadOnly;
@property (nonatomic) BOOL isCopy;
@property (nonatomic) BOOL isRetained;
@property (nonatomic) BOOL isNonatomic;
@property (nonatomic) BOOL isDynamic;
@property (nonatomic) BOOL isWeak;
@property (nonatomic) BOOL isGarbageCollectable;

@end

@implementation MKPropertyAttributes

#pragma mark Initializers

+ (instancetype)attributesFromDictionary:(NSDictionary *)attributes {
    NSString *attrs = attributes.propertyAttributesString;
    if (!attrs) [NSException raise:NSInternalInconsistencyException format:@"Invalid property attributes dictionary: %@", attributes];
    return [self attributesFromString:attrs];
}

+ (instancetype)attributesFromString:(NSString *)attributes {
    return [[self alloc] initWithAttributesString:attributes];
}

- (id)initWithAttributesString:(NSString *)attributesString {
    NSParameterAssert(attributesString);
    
    self = [super init];
    if (self) {
        _attributesString = attributesString;
        
        NSDictionary *attributes = attributesString.propertyAttributes;
        if (!attributes) [NSException raise:NSInternalInconsistencyException format:@"Invalid property attributes string: %@", attributesString];
        
        _count                = attributes.allKeys.count;
        _typeEncoding         = attributes[MKPropertyAttributeKeyTypeEncoding];
        _backingIVar          = attributes[MKPropertyAttributeKeyBackingIVarName];
        _oldTypeEncoding      = attributes[MKPropertyAttributeKeyOldTypeEncoding];
        _customGetter         = NSSelectorFromString(attributes[MKPropertyAttributeKeyCustomGetter]);
        _customSetter         = NSSelectorFromString(attributes[MKPropertyAttributeKeyCustomSetter]);
        _isReadOnly           = [attributes[MKPropertyAttributeKeyReadOnly] boolValue];
        _isCopy               = [attributes[MKPropertyAttributeKeyCopy] boolValue];
        _isRetained           = [attributes[MKPropertyAttributeKeyRetain] boolValue];
        _isNonatomic          = [attributes[MKPropertyAttributeKeyNonAtomic] boolValue];
        _isWeak               = [attributes[MKPropertyAttributeKeyWeak] boolValue];
        _isGarbageCollectable = [attributes[MKPropertyAttributeKeyGarbageCollectible] boolValue];
    }
    
    return self;
}

#pragma mark Misc

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ ivar=%@, readonly=%d, nonatomic=%d, getter=%@, setter=%@>",
            NSStringFromClass(self.class), self.backingIVar?:@"none", self.isReadOnly, self.isNonatomic, NSStringFromSelector(self.customGetter)?:@" ", NSStringFromSelector(self.customSetter)?:@" "];
}

- (objc_property_attribute_t *)copyAttributesList:(unsigned int *)attributesCount {
    NSDictionary *attributes = self.attributesString.propertyAttributes;
    *attributesCount = (unsigned int)attributes.allKeys.count;
    objc_property_attribute_t *propertyAttributes = malloc(attributes.allKeys.count*sizeof(objc_property_attribute_t));
    
    NSUInteger i = 0;
    for (NSString *key in attributes.allKeys) {
        MKPropertyAttribute c = (MKPropertyAttribute)[key characterAtIndex:0];
        switch (c) {
            case MKPropertyAttributeTypeEncoding: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyTypeEncoding.UTF8String, self.typeEncoding.UTF8String};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeBackingIVarName: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyBackingIVarName.UTF8String, self.backingIVar.UTF8String};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeCopy: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyCopy.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeCustomGetter: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyCustomGetter.UTF8String, NSStringFromSelector(self.customGetter).UTF8String ?: ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeCustomSetter: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyCustomSetter.UTF8String, NSStringFromSelector(self.customSetter).UTF8String ?: ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeDynamic: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyDynamic.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeGarbageCollectible: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyGarbageCollectible.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeNonAtomic: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyNonAtomic.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeOldTypeEncoding: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyOldTypeEncoding.UTF8String, self.oldTypeEncoding.UTF8String ?: ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeReadOnly: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyReadOnly.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeRetain: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyRetain.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case MKPropertyAttributeWeak: {
                objc_property_attribute_t pa = {MKPropertyAttributeKeyWeak.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
        }
        i++;
    }
    
    return propertyAttributes;
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone {
    return [[MKPropertyAttributes class] attributesFromString:self.attributesString];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[MKMutablePropertyAttributes class] attributesFromString:self.attributesString];
}

@end



#pragma mark - MKMutablePropertyAttributes -

@implementation MKMutablePropertyAttributes

@dynamic backingIVar;
@dynamic typeEncoding;
@dynamic oldTypeEncoding;
@dynamic customGetter;
@dynamic customSetter;
@dynamic isReadOnly;
@dynamic isCopy;
@dynamic isRetained;
@dynamic isNonatomic;
@dynamic isDynamic;
@dynamic isWeak;
@dynamic isGarbageCollectable;

+ (instancetype)attributes {
    return [self new];
}

- (void)setTypeEncodingChar:(char)type {
    self.typeEncoding = [NSString stringWithFormat:@"%c", type];
}

- (NSString *)attributesString {
    NSMutableDictionary *attrs = [NSMutableDictionary new];
    if (self.typeEncoding)
        attrs[MKPropertyAttributeKeyTypeEncoding]    = self.typeEncoding;
    if (self.backingIVar)
        attrs[MKPropertyAttributeKeyBackingIVarName] = self.backingIVar;
    if (self.oldTypeEncoding)
        attrs[MKPropertyAttributeKeyOldTypeEncoding] = self.oldTypeEncoding;
    if (self.customGetter)
        attrs[MKPropertyAttributeKeyCustomGetter]    = NSStringFromSelector(self.customGetter);
    if (self.customSetter)
        attrs[MKPropertyAttributeKeyCustomSetter]    = NSStringFromSelector(self.customSetter);
    
    attrs[MKPropertyAttributeKeyReadOnly]           = @(self.isReadOnly);
    attrs[MKPropertyAttributeKeyCopy]               = @(self.isCopy);
    attrs[MKPropertyAttributeKeyRetain]             = @(self.isRetained);
    attrs[MKPropertyAttributeKeyNonAtomic]          = @(self.isNonatomic);
    attrs[MKPropertyAttributeKeyDynamic]            = @(self.isDynamic);
    attrs[MKPropertyAttributeKeyWeak]               = @(self.isWeak);
    attrs[MKPropertyAttributeKeyGarbageCollectible] = @(self.isGarbageCollectable);
    
    return attrs.propertyAttributesString;
}

@end