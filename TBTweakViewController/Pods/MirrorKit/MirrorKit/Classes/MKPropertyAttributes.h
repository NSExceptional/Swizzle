//
//  MKPropertyAttributes.h
//  MirrorKit
//
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


#pragma mark MKPropertyAttributes

/// See \e MirrorKit-Constants.m for valid string tokens.
/// See this link on how to construct a proper attributes string:
/// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
@interface MKPropertyAttributes : NSObject <NSCopying, NSMutableCopying> {
@protected
    NSUInteger _count;
    NSString *_attributesString, *_backingIVar, *_typeEncoding, *_oldTypeEncoding;
    SEL _customGetter, _customSetter;
    BOOL _isReadOnly, _isCopy, _isRetained, _isNonatomic, _isDynamic, _isWeak, _isGarbageCollectable;
}

/// @warning Raises an exception if \e attributes is invalid or \c nil.
+ (instancetype)attributesFromString:(NSString *)attributes;
/// @warning Raises an exception if \e attributes is invalid, \c nil, or contains unsupported keys.
+ (instancetype)attributesFromDictionary:(NSDictionary *)attributes;

- (objc_property_attribute_t *)copyAttributesList:(unsigned int *)attributesCount;

/// The number of property attributes.
@property (nonatomic, readonly) NSUInteger count;
/// The string value of the property attributes.
@property (nonatomic, readonly) NSString *attributesString;

/// The name of the instance variable backing the property.
@property (nonatomic, readonly) NSString *backingIVar;
/// The type encoding of the property.
@property (nonatomic, readonly) NSString *typeEncoding;
/// The \e old type encoding of the property.
@property (nonatomic, readonly) NSString *oldTypeEncoding;
/// The property's custom getter, if any.
@property (nonatomic, readonly) SEL customGetter;
/// The property's custom setter, if any.
@property (nonatomic, readonly) SEL customSetter;

@property (nonatomic, readonly) BOOL isReadOnly;
@property (nonatomic, readonly) BOOL isCopy;
@property (nonatomic, readonly) BOOL isRetained;
@property (nonatomic, readonly) BOOL isNonatomic;
@property (nonatomic, readonly) BOOL isDynamic;
@property (nonatomic, readonly) BOOL isWeak;
@property (nonatomic, readonly) BOOL isGarbageCollectable;

@end


#pragma mark MKPropertyAttributes
@interface MKMutablePropertyAttributes : MKPropertyAttributes

/// Creates and returns an empty property attributes object.
+ (instancetype)attributes;

/// The name of the instance variable backing the property.
@property (nonatomic) NSString *backingIVar;
/// The type encoding of the property.
@property (nonatomic) NSString *typeEncoding;
/// The \e old type encoding of the property.
@property (nonatomic) NSString *oldTypeEncoding;
/// The property's custom getter, if any.
@property (nonatomic) SEL customGetter;
/// The property's custom setter, if any.
@property (nonatomic) SEL customSetter;

@property (nonatomic) BOOL isReadOnly;
@property (nonatomic) BOOL isCopy;
@property (nonatomic) BOOL isRetained;
@property (nonatomic) BOOL isNonatomic;
@property (nonatomic) BOOL isDynamic;
@property (nonatomic) BOOL isWeak;
@property (nonatomic) BOOL isGarbageCollectable;

/// A more convenient method of setting the \c typeEncoding property.
/// @discussion This will not work for complex types like structs and primitive pointers.
- (void)setTypeEncodingChar:(char)type;

@end