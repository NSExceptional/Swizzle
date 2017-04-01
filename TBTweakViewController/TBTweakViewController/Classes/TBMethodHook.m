//
//  TBMethodHook.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook.h"
#import "TBMethodHook+Limitations.h"
#import "TBMethodHook+IMP.h"

#import "NSScanner+ChirpParser.h"
#import "NSError+Message.h"

@interface TBMethodHook () {
    NSUInteger _hash;
}
@property (nonatomic) BOOL delta;
@property (nonatomic, readonly) IMP implementation;
@property (nonatomic, readonly) NSError *impError;
@property (nonatomic, readonly) NSString *action;
@end

@implementation TBMethodHook
@synthesize implementation = _implementation;

#pragma mark Initialization

+ (instancetype)target:(Class)cls action:(SEL)selector isClassMethod:(BOOL)classMethod {
    return [[self alloc] initWithTarget:cls action:selector isClassMethod:classMethod];
}

- (id)initWithTarget:(Class)cls action:(SEL)selector isClassMethod:(BOOL)classMethod {
    MKMethod *method = [MKMethod methodForSelector:selector class:cls instance:!classMethod];
    if (!method) {
        return nil;
    }

    return [self initWithMethod:method];
}

+ (instancetype)hook:(MKMethod *)method {
    return [[self alloc] initWithMethod:method];
}

- (id)initWithMethod:(MKMethod *)method {
    NSParameterAssert(method);

    self = [super init];
    if (self) {
        _method = method;
        _target = NSStringFromClass(method.targetClass);
        _action = method.selectorString;
        [self examine];
    }

    return self;
}

- (void)examine {
    _isClassMethod = !_method.isInstanceMethod;
    _originalImplementation = _method.implementation;

    _canOverrideReturnValue       = [TBMethodHook canHookReturnTypeOf:_method];
    _canOverrideAllArgumentValues = [TBMethodHook canHookAllArgumentTypesOf:_method];

    _hash = (NSUInteger)_method.objc_method;

    if (self.method.implementedByTargetClass) {
        NSString *format = @"The implementation of %@ will be replaced by this hook.";
        _about = [NSString stringWithFormat:format, _method.fullName];
    } else {
        NSString *format = @"%@ does not define an implementation for %@, but "
        "inherits it from a superclass. A new implementation, %@, will be created by this hook.";
        _about = [NSString stringWithFormat:format, _method.targetClass, _method.selectorString, _method.fullName];
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _target            = [decoder decodeObjectForKey:@"target"];
        _action            = [decoder decodeObjectForKey:@"action"];
        _hookedReturnValue = [decoder decodeObjectForKey:@"return"];
        _hookedArguments   = [decoder decodeObjectForKey:@"args"];
        _chirpString       = [decoder decodeObjectForKey:@"format"];
        _isClassMethod     = [decoder decodeBoolForKey:@"classMethod"];;

        _method = [MKMethod methodForSelector:NSSelectorFromString(_action)
                                        class:NSClassFromString(_target) instance:!_isClassMethod];
        if (!_method) {
            return nil;
        }

        [self examine];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.target forKey:@"target"];
    [coder encodeObject:self.action forKey:@"action"];
    [coder encodeObject:self.hookedReturnValue forKey:@"return"];
    [coder encodeObject:self.hookedArguments forKey:@"args"];
    [coder encodeObject:self.chirpString forKey:@"format"];
    [coder encodeBool:self.isClassMethod forKey:@"classMethod"];
}

#pragma mark Private

- (void)setDelta:(BOOL)delta {
    _delta          = delta;
    _implementation = nil;
    _impError       = nil;
}

- (void)setChirpString:(NSString *)chirpString {
    _chirpString = chirpString;
    _hookedReturnValue = nil;
    _hookedArguments   = nil;
    self.delta = YES;
}

- (void)setHookedReturnValue:(TBValue *)hookedReturnValue {
    self.delta = YES;
    if (_canOverrideReturnValue) {
        _hookedReturnValue = hookedReturnValue;
    }
    
    _chirpString = nil;
    _hookedArguments   = nil;
}

- (void)setHookedArguments:(NSArray<TBValue *> *)hookedArguments {
    self.delta = YES;
    if (_canOverrideAllArgumentValues) {
        _hookedArguments = hookedArguments;
    }
    
    _chirpString = nil;
    _hookedReturnValue = nil;
}

- (void)buildIMPFromHooks {
    if (self.hookedReturnValue) {
        _implementation = [self IMPForHookedReturnType];
    } else if (self.hookedArguments) {
        _implementation = [self IMPForHookedArguments];
    } else {
        _impError = [NSError error:[NSString stringWithFormat:@"No hooks installed for [%@ %@]", self.target, self.method.selectorString]];
    }
}

- (void)buildFromChirpString {
    NSScanner *scanner = [NSScanner scannerWithString:self.chirpString];
    NSError *error = nil;
    [scanner scanChirp:&_implementation method:self.method error:&error];
    _impError = error;
}

#pragma mark Public interface

- (TBHookType)type {
    if (self.chirpString) {
        return TBHookTypeChirpCode;
    }
    if (self.hookedReturnValue) {
        return TBHookTypeReturnValue;
    }
    if (self.hookedArguments) {
        return TBHookTypeArguments;
    }

    return TBHookTypeUnspecified;
}

- (IMP)implementation {
    if (!_implementation) {
        _impError = nil;
        
        if (self.chirpString) {
            [self buildFromChirpString];
        } else {
            [self buildIMPFromHooks];
        }
    }
    
    return _implementation;
}

- (void)getImplementation:(void(^)(IMP _Nullable implementation, NSError * _Nullable error))implementationHandler {
    NSParameterAssert(self.implementation || self.impError);
    implementationHandler(self.implementation, self.impError);
}

#pragma mark Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TBMethodHook class]]) {
        return [self isEqualToHook:object];
    }
    
    return NO;
}

- (BOOL)isEqualToHook:(TBMethodHook *)hook {
    return hook->_hash == _hash;
}

- (NSUInteger)hash {
    return _hash;
}

@end
