//
//  MKProperty.h
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MirrorKit-Constants.h"
@import ObjectiveC;
@class MKPropertyAttributes, MKSimpleMethod;


#pragma mark - MKProperty -
@interface MKProperty : NSObject

+ (instancetype)property:(objc_property_t)property;
/// Constructs a new property with the given name and attributes.
/// @discussion Consider using \c propertyWithName:attributes:
+ (instancetype)propertyWithName:(NSString *)name attributesString:(NSString *)attributesString;
/// Constructs a new property with the given name and attributes.
+ (instancetype)propertyWithName:(NSString *)name attributes:(MKPropertyAttributes *)attributes;

/// \c 0 if the instance was created via \c +propertyWithName:attributes.
@property (nonatomic, readonly) objc_property_t      objc_property;

/// The name of the property.
@property (nonatomic, readonly) NSString             *name;
/// The type of the property.
@property (nonatomic, readonly) MKTypeEncoding       type;
/// The property's attributes.
@property (nonatomic, readonly) MKPropertyAttributes *attributes;

/// Safe to use regardless of how the \c MKProperty instance was initialized.
- (objc_property_attribute_t *)copyAttributesList:(unsigned int *)attributesCount;

#pragma mark Convenience getters and setters
/// @return A getter for the property with the given implementation.
/// @discussion Consider using the \c MKPropertyGetter macros.
- (MKSimpleMethod *)getterWithImplementation:(IMP)implementation;
/// @return A setter for the property with the given implementation.
/// @discussion Consider using the \c MKPropertySetter macros.
- (MKSimpleMethod *)setterWithImplementation:(IMP)implementation;

#pragma mark MKMethod property getter / setter macros
// Easier than using the above methods yourself in most cases

/// Takes an \c MKProperty and a type (ie \c NSUInteger or \c id) and uses the \c MKProperty's \c attribute's \c backingIVarName to get the IVar.
#define MKPropertyGetter(MKProperty, type) [MKProperty getterWithImplementation:imp_implementationWithBlock(^(id self) { \
    return *(type *)[self getIVarAddressByName:MKProperty.attributes.backingIVar]; \
})];
/// Takes an \c MKProperty and a type (ie \c NSUInteger or \c id) and uses the \c MKProperty's \c attribute's \c backingIVarName to set the IVar.
#define MKPropertySetter(MKProperty, type) [MKProperty setterWithImplementation:imp_implementationWithBlock(^(id self, type value) { \
    [self setIVarByName:MKProperty.attributes.backingIVar value:&value size:sizeof(type)]; \
})];
/// Takes an \c MKProperty and a type (ie \c NSUInteger or \c id) and an IVar name string to get the IVar.
#define MKPropertyGetterWithIVar(MKProperty, ivarName, type) [MKProperty getterWithImplementation:imp_implementationWithBlock(^(id self) { \
    return *(type *)[self getIVarAddressByName:ivarName]; \
})];
/// Takes an \c MKProperty and a type (ie \c NSUInteger or \c id) and an IVar name string to set the IVar.
#define MKPropertySetterWithIVar(MKProperty, ivarName, type) [MKProperty setterWithImplementation:imp_implementationWithBlock(^(id self, type value) { \
    [self setIVarByName:ivarName value:&value size:sizeof(type)]; \
})];

@end
