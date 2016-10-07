//
//  MKProtocol.h
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MirrorKit-Constants.h"

#pragma mark - MKProtocol -
@interface MKProtocol : NSObject

/// Every protocol registered with the runtime.
+ (NSArray<MKProtocol*> *)allProtocols;
+ (instancetype)protocol:(Protocol *)protocol;

/// The underlying protocol data structure.
@property (nonatomic, readonly) Protocol *objc_protocol;

/// The name of the protocol.
@property (nonatomic, readonly) NSString *name;
/// The properties in the protocol, if any.
@property (nonatomic, readonly) NSArray  *properties;
/// The required methods of the protocol, if any, as \c MKMethodDescription objects. This includes property getters and setters.
@property (nonatomic, readonly) NSArray  *requiredMethods;
/// The optional methods of the protocol, if any, as \c MKMethodDescription objects. This includes property getters and setters.
@property (nonatomic, readonly) NSArray  *optionalMethods;
/// All protocols that this protocol conforms to, as \c MKProtocol objects.
@property (nonatomic, readonly) NSArray  *protocols;

/// Not to be confused with \c -conformsToProtocol:, which refers to the current \c MKProtocol instance and not the underlying Protocol object.
- (BOOL)conformsTo:(Protocol *)protocol;

@end


#pragma mark - Method descriptions -
@interface MKMethodDescription : NSObject

+ (instancetype)description:(struct objc_method_description)methodDescription;

/// The underlying method description data structure.
@property (nonatomic, readonly) struct objc_method_description objc_description;
/// The method's selector.
@property (nonatomic, readonly) SEL selector;
/// The method's type encoding.
@property (nonatomic, readonly) NSString *typeEncoding;
/// The method's return type.
@property (nonatomic, readonly) MKTypeEncoding returnType;
@end