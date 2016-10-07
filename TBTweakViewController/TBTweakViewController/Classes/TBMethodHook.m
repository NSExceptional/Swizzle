//
//  TBMethodHook.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook.h"
#import "NSScanner+ChirpParser.h"
#import "NSError+Message.h"
#import "NSInvocation+Tweaking.h"
#import <UIKit/UIGeometry.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>


#define BlockReturnSelector(sel) ({ \
id value = self.hookedReturnValue.value; \
imp_implementationWithBlock(^(id reciever) { \
return [value sel]; \
}); \
})

#define BlockReturn(foo) imp_implementationWithBlock(^(id reciever) { \
return foo; \
})

#define ExceptionAssert(condition, message) if (!(condition)) {\
[NSException raise:NSInternalInconsistencyException format: message]; \
}

BOOL TBCanHookValueOfType(const char *fullTypeEncoding) {
    MKTypeEncoding type = fullTypeEncoding[0];
    
    if (type == MKTypeEncodingVoid ||
        type == MKTypeEncodingUnknown) {
        return NO;
    }
    
    // Can only hook certain structure sizes
    if (type == MKTypeEncodingStruct ||
        type == MKTypeEncodingUnion ||
        type == MKTypeEncodingBitField) {
        
        NSUInteger returnSize;
        NSGetSizeAndAlignment(fullTypeEncoding, &returnSize, NULL);
        if (returnSize != sizeof(NSRange) &&
            returnSize != sizeof(CGPoint) &&
            returnSize != sizeof(CGRect) &&
            returnSize != sizeof(CGAffineTransform) &&
            returnSize != sizeof(UIEdgeInsets) &&
            returnSize != sizeof(CATransform3D)) {
            return NO;
        }
    }
    
    return YES;
}

BOOL TBCanHookMethodReturnType(MKMethod *method) {
    return TBCanHookValueOfType(method.signature.methodReturnType);
}

BOOL TBCanHookAllArgumentTypes(MKMethod *method) {
    for (NSInteger i = 2; i < method.numberOfArguments; i++) {
        if (!TBCanHookValueOfType([method.signature getArgumentTypeAtIndex:i])) {
            return NO;
        }
    }
    
    return method.numberOfArguments > 2;
}

@interface TBMethodHook ()
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
    
    self = [super init];
    if (self) {
        _method = method;
        _target = NSStringFromClass(cls);
        _action = NSStringFromSelector(selector);
        _isClassMethod = classMethod;
        _originalImplementation = method.implementation;
        
        _canOverrideReturnValue       = TBCanHookMethodReturnType(method);
        _canOverrideAllArgumentValues = TBCanHookAllArgumentTypes(method);
    }
    
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _target            = [decoder decodeObjectForKey:@"target"];
        _action            = [decoder decodeObjectForKey:@"action"];
        _hookedReturnValue = [decoder decodeObjectForKey:@"return"];
        _hookedArguments   = [decoder decodeObjectForKey:@"args"];
        _canOverrideReturnValue       = [decoder decodeBoolForKey:@"hookReturn"];
        _canOverrideAllArgumentValues = [decoder decodeBoolForKey:@"hookArgs"];
        _chirpString   = [decoder decodeObjectForKey:@"format"];
        _isClassMethod = [decoder decodeBoolForKey:@"classMethod"];
        
        _method = [MKMethod methodForSelector:NSSelectorFromString(_action)
                                        class:NSClassFromString(_target) instance:!_isClassMethod];
        if (!_method) {
            return nil;
        }
        
        _originalImplementation = _method.implementation;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.target forKey:@"target"];
    [coder encodeObject:self.action forKey:@"action"];
    [coder encodeObject:self.hookedReturnValue forKey:@"return"];
    [coder encodeObject:self.hookedArguments forKey:@"args"];
    [coder encodeObject:self.chirpString forKey:@"format"];
    [coder encodeBool:self.canOverrideReturnValue forKey:@"hookReturn"];
    [coder encodeBool:self.canOverrideAllArgumentValues forKey:@"hookArgs"];
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
        [self buildIMPFromReturnValueHook];
    } else if (self.hookedArguments) {
        [self buildIMPFromArgumentHooks];
    } else {
        _impError = [NSError error:[NSString stringWithFormat:@"No hooks installed for [%@ %@]", self.target, self.method.selectorString]];
    }
}

- (void)buildIMPFromReturnValueHook {
    switch (self.method.returnType) {
        case MKTypeEncodingUnknown:
        case MKTypeEncodingVoid: {
            break;
        }
        case MKTypeEncodingChar: {
            _implementation = BlockReturnSelector(charValue);
            break;
        }
        case MKTypeEncodingInt: {
            _implementation = BlockReturnSelector(intValue);
            break;
        }
        case MKTypeEncodingShort: {
            _implementation = BlockReturnSelector(shortValue);
            break;
        }
        case MKTypeEncodingLong: {
            _implementation = BlockReturnSelector(longValue);
            break;
        }
        case MKTypeEncodingLongLong: {
            _implementation = BlockReturnSelector(longLongValue);
            break;
        }
        case MKTypeEncodingUnsignedChar: {
            _implementation = BlockReturnSelector(unsignedCharValue);
            break;
        }
        case MKTypeEncodingUnsignedInt: {
            _implementation = BlockReturnSelector(unsignedIntValue);
            break;
        }
        case MKTypeEncodingUnsignedShort: {
            _implementation = BlockReturnSelector(unsignedShortValue);
            break;
        }
        case MKTypeEncodingUnsignedLong: {
            _implementation = BlockReturnSelector(unsignedLongValue);
            break;
        }
        case MKTypeEncodingUnsignedLongLong: {
            _implementation = BlockReturnSelector(unsignedLongValue);
            break;
        }
        case MKTypeEncodingFloat: {
            _implementation = BlockReturnSelector(floatValue);
            break;
        }
        case MKTypeEncodingDouble: {
            _implementation = BlockReturnSelector(doubleValue);
            break;
        }
        case MKTypeEncodingCBool: {
            _implementation = BlockReturnSelector(boolValue);
            break;
        }
        case MKTypeEncodingCString:
        case MKTypeEncodingSelector:
        case MKTypeEncodingPointer: {
            _implementation = BlockReturnSelector(pointerValue);
            break;
        }
        case MKTypeEncodingStruct:
        case MKTypeEncodingUnion:
        case MKTypeEncodingBitField:
        case MKTypeEncodingArray: {
            // Get return size of method
            NSUInteger returnSize;
            NSGetSizeAndAlignment(self.method.signature.methodReturnType, &returnSize, NULL);
            
            
            if (returnSize == sizeof(NSRange)) {
                _implementation = BlockReturnSelector(rangeValue);
            }
            
            // Skip CGVector, CGSize
            else if (returnSize == sizeof(CGPoint)) {
                _implementation = BlockReturnSelector(CGPointValue);
            }
            else if (returnSize == sizeof(CGRect)) {
                _implementation = BlockReturnSelector(CGRectValue);
            }
            else if (returnSize == sizeof(CGAffineTransform)) {
                _implementation = BlockReturnSelector(CGAffineTransformValue);
            }
            
            // Skip UIOffset
            else if (returnSize == sizeof(UIEdgeInsets)) {
                _implementation = BlockReturnSelector(UIEdgeInsetsValue);
            }
            
            else if (returnSize == sizeof(CATransform3D)) {
                _implementation = BlockReturnSelector(CATransform3DValue);
            }
            
            else {
                [NSException raise:NSInternalInconsistencyException format:@"Unsupported return type hook"];
            }
            
            break;
        }
        case MKTypeEncodingObjcObject:
        case MKTypeEncodingObjcClass: {
            _implementation = BlockReturn(self.hookedReturnValue.value);
            break;
        }
    }
}

- (void)buildIMPFromArgumentHooks {
    NSParameterAssert(self.hookedArguments);
    
    if (!self.hookedArguments.count) {
        _implementation = _originalImplementation;
        return;
    }
    
    // NSInvocation hack to invoke the desired IMP
    static void (*invokeWithIMP)(id, SEL, IMP) = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        invokeWithIMP = (void *)[NSInvocation instanceMethodForSelector:NSSelectorFromString(@"invokeUsingIMP:")];
    });
    
#pragma clang diagnostic ignored "-Wvarargs"
    
    NSArray *arguments           = self.hookedArguments;
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:self.method.signature];
    
    _implementation = imp_implementationWithBlock(^void *(id reciever, ...) {
        // Give invocation the original arguments
        va_list __args;
        va_start(__args, reciever);
        for (NSInteger i = 2; i < invocation.methodSignature.numberOfArguments; i++) {
            MKTypeEncoding type = [invocation.methodSignature getArgumentTypeAtIndex:i][0];
            switch (type) {
                case MKTypeEncodingUnknown: case MKTypeEncodingVoid: {
                    break; }
                case MKTypeEncodingChar: {
                    char tmp = va_arg(__args, char);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingInt: {
                    int tmp = va_arg(__args, int);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingShort: {
                    short tmp = va_arg(__args, short);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingLong: {
                    long tmp = va_arg(__args, long);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingLongLong: {
                    long long tmp = va_arg(__args, long long);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingUnsignedChar: {
                    unsigned char tmp = va_arg(__args, unsigned char);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingUnsignedInt: {
                    unsigned int tmp = va_arg(__args, unsigned int);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingUnsignedShort: {
                    unsigned short tmp = va_arg(__args, unsigned short);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingUnsignedLong: {
                    unsigned long tmp = va_arg(__args, unsigned long);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingUnsignedLongLong: {
                    unsigned long long tmp = va_arg(__args, unsigned long long);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingFloat: {
                    float tmp = va_arg(__args, float);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingDouble: {
                    double tmp = va_arg(__args, double);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingCBool: {
                    _Bool tmp = va_arg(__args, _Bool);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingCString: case MKTypeEncodingSelector: case MKTypeEncodingPointer: {
                    void * tmp = va_arg(__args, void *);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
                case MKTypeEncodingStruct:
                case MKTypeEncodingUnion:
                case MKTypeEncodingBitField:
                case MKTypeEncodingArray: {
                    NSUInteger returnSize;
                    NSGetSizeAndAlignment([invocation.methodSignature getArgumentTypeAtIndex: i], &returnSize, NULL);
                    
                    if (returnSize == sizeof(NSRange)) {
                        NSRange tmp = va_arg(__args, NSRange);
                        [invocation setArgument:&tmp atIndex: i];
                        break;
                    }
                    else if (returnSize == sizeof(CGPoint)) {
                        CGPoint tmp = va_arg(__args, CGPoint);
                        [invocation setArgument:&tmp atIndex: i];
                        break;
                    }
                    else if (returnSize == sizeof(CGRect)) {
                        CGRect tmp = va_arg(__args, CGRect);
                        [invocation setArgument:&tmp atIndex: i];
                        break;
                    }
                    else if (returnSize == sizeof(CGAffineTransform)) {
                        CGAffineTransform tmp = va_arg(__args, CGAffineTransform);
                        [invocation setArgument:&tmp atIndex: i];
                        break;
                    }
                    else if (returnSize == sizeof(UIEdgeInsets)) {
                        UIEdgeInsets tmp = va_arg(__args, UIEdgeInsets);
                        [invocation setArgument:&tmp atIndex: i];
                        break;
                    }
                    else if (returnSize == sizeof(CATransform3D)) {
                        CATransform3D tmp = va_arg(__args, CATransform3D);
                        [invocation setArgument:&tmp atIndex: i];
                        break;
                    }
                    else {
                        [NSException raise:NSInternalInconsistencyException format:@"Unsupported argument type hook"];
                    }
                    break;
                }
                case MKTypeEncodingObjcObject: case MKTypeEncodingObjcClass: {
                    id tmp = va_arg(__args, id);
                    [invocation setArgument:&tmp atIndex: i];
                    break;
                }
            }
        }
        
        // Replace hooked arguments
        [invocation overrideArguments:arguments];
        
        // Invoke method with original IMP and replaced parameters
        invocation.target = reciever;
        invokeWithIMP(invocation, 0, _originalImplementation);
        
        if (invocation.methodSignature.methodReturnLength) {
            void *ret = nil;
            [invocation getReturnValue:&ret];
            
            if (self.method.returnType == MKTypeEncodingObjcObject ||
                self.method.returnType == MKTypeEncodingObjcClass) {
                return ret;
            } else {
                return *(void**)ret;
            }
        } else {
            return NULL;
        }
    });
}

#pragma mark Public interface

- (IMP)implementation {
    if (!_implementation) {
        if (self.chirpString) {
            NSScanner *scanner = [NSScanner scannerWithString:self.chirpString];
            NSError *error = nil;
            [scanner scanChirp:&_implementation method:self.method error:&error];
            _impError = error;
        } else {
            _impError = nil;
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
    if ([object isKindOfClass:[TBMethodHook class]])
        return [self isEqualToHook:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToHook:(TBMethodHook *)hook {
    return (self.isClassMethod == hook.isClassMethod &&
            self.canOverrideReturnValue == hook.canOverrideReturnValue &&
            self.canOverrideAllArgumentValues == hook.canOverrideAllArgumentValues &&
            [self.target isEqualToString:hook.target] && [self.action isEqualToString:hook.action]);
    
    //            ([self.hookedReturnValue isEqual:hook.hookedReturnValue] ||
    //             (!self.hookedReturnValue && !hook.hookedReturnValue)) &&
    //            
    //            ([self.hookedArguments isEqualToArray:hook.hookedArguments] ||
    //             (!self.hookedArguments && !hook.hookedArguments)) &&
    //            
    //            ([self.chirpString isEqualToString:hook.chirpString] ||
    //             (!self.chirpString && !hook.chirpString)));
}

- (NSUInteger)hash {
    return self.target.hash ^ self.action.hash +
    (self.canOverrideReturnValue + self.canOverrideAllArgumentValues + self.isClassMethod);
}

@end
