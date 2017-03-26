//
//  MKProtocolBuilder.m
//  MirrorKit
//
//  Created by Tanner on 7/4/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "MKProtocolBuilder.h"
#import "MKProtocol.h"
#import "MKProperty.h"
@import ObjectiveC;

@interface MKProtocolBuilder ()
@property (nonatomic) Protocol *workingProtocol;
@property (nonatomic) NSString *name;
@end

@implementation MKProtocolBuilder

- (id)init { [NSException raise:NSInternalInconsistencyException format:@"Class instance should not be created with -init"]; return nil; }

#pragma mark Initializers
+ (instancetype)allocateProtocol:(NSString *)name {
    NSParameterAssert(name);
    return [[self alloc] initWithProtocol:objc_allocateProtocol(name.UTF8String)];
    
}

- (id)initWithProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);
    
    self = [super init];
    if (self) {
        _workingProtocol = protocol;
        _name = NSStringFromProtocol(self.workingProtocol);
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ name=%@, registered=%d>",
            NSStringFromClass(self.class), self.name, self.isRegistered];
}

#pragma mark Building

- (void)addProperty:(MKProperty *)property isRequired:(BOOL)isRequired {
    if (self.isRegistered) [NSException raise:NSInternalInconsistencyException format:@"Properties cannot be added once a protocol has been registered"];
    
    unsigned int count;
    objc_property_attribute_t *attributes = [property copyAttributesList:&count];
    protocol_addProperty(self.workingProtocol, property.name.UTF8String, attributes, count, isRequired, YES);
    free(attributes);
}

- (void)addMethod:(SEL)selector typeEncoding:(NSString *)typeEncoding isRequired:(BOOL)isRequired isInstanceMethod:(BOOL)isInstanceMethod {
    if (self.isRegistered) [NSException raise:NSInternalInconsistencyException format:@"Methods cannot be added once a protocol has been registered"];
    protocol_addMethodDescription(self.workingProtocol, selector, typeEncoding.UTF8String, isRequired, isInstanceMethod);
}

- (void)addProtocol:(Protocol *)protocol {
    if (self.isRegistered) [NSException raise:NSInternalInconsistencyException format:@"Protocols cannot be added once a protocol has been registered"];
    protocol_addProtocol(self.workingProtocol, protocol);
}

- (MKProtocol *)registerProtocol {
    if (self.isRegistered) [NSException raise:NSInternalInconsistencyException format:@"Protocol is already registered"];
    
    _isRegistered = YES;
    objc_registerProtocol(self.workingProtocol);
    return [MKProtocol protocol:self.workingProtocol];
}

@end
