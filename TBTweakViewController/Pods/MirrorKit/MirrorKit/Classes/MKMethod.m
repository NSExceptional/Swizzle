//
//  MKMethod.m
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "MKMethod.h"
#import "MKMirror.h"


@interface MKMethod () {
    NSString *__description;
}
@end

@implementation MKMethod
@dynamic implementation;

#pragma mark Broken

+ (instancetype)buildMethodNamed:(NSString *)name withTypes:(NSString *)typeEncoding implementation:(IMP)implementation {
    [NSException raise:NSInternalInconsistencyException format:@"Class instance should not be created with +buildMethodNamed:withTypes:implementation"]; return nil;
}

- (id)init { [NSException raise:NSInternalInconsistencyException format:@"Class instance should not be created with -init"]; return nil; }

#pragma mark Initialization

+ (nullable instancetype)method:(Method)method class:(Class)cls {
    return [[self alloc] initWithMethod:method class:cls isInstanceMethod:YES];
}

+ (nullable instancetype)method:(Method)method class:(Class)cls isInstanceMethod:(BOOL)isInstanceMethod {
    return [[self alloc] initWithMethod:method class:cls isInstanceMethod:isInstanceMethod];
}

+ (instancetype)methodForSelector:(SEL)selector class:(Class)cls instance:(BOOL)instance {
    Method m = instance ? class_getInstanceMethod(cls, selector) : class_getClassMethod(cls, selector);
    if (m == NULL) return nil;
    
    return [self method:m class:cls isInstanceMethod:instance];
}

+ (instancetype)methodForSelector:(SEL)selector implementedInClass:(Class)cls instance:(BOOL)instance {
    if (![cls superclass]) { return [self methodForSelector:selector class:cls instance:instance]; }
    
    BOOL unique;
    if (instance) {
        unique = [[cls class] instanceMethodForSelector:selector] != [[cls superclass] instanceMethodForSelector:selector];
    } else {
        unique = [[cls class] methodForSelector:selector] != [[cls superclass] methodForSelector:selector];
    }
    
    if (unique) {
        return [self methodForSelector:selector class:cls instance:instance];
    }
    
    return nil;
}

+ (nullable instancetype)instanceMethod:(SEL)selector class:(Class)cls {
    return [self methodForSelector:selector class:cls instance:YES];
}

+ (nullable instancetype)instanceMethod:(SEL)selector implementedInClass:(Class)cls {
    return [self methodForSelector:selector implementedInClass:cls instance:YES];
}

+ (nullable instancetype)classMethod:(SEL)selector class:(Class)cls {
    return [self methodForSelector:selector class:cls instance:NO];
}

+ (nullable instancetype)classMethod:(SEL)selector implementedInClass:(Class)cls {
    return [self methodForSelector:selector implementedInClass:cls instance:NO];
}

/// All initializers call into this method
- (id)initWithMethod:(Method)method class:(Class)cls isInstanceMethod:(BOOL)isInstanceMethod {
    NSParameterAssert(method);
    
    self = [super init];
    if (self) {
        _objc_method      = method;
        _targetClass      = cls;
        _isInstanceMethod = isInstanceMethod;
        @try {
            _implementedByTargetClass = [self isImplementedInClass:_targetClass];
            _signatureString = @(method_getTypeEncoding(method));
            _signature = [NSMethodSignature signatureWithObjCTypes:_signatureString.UTF8String];
            [self examine];
        } @catch (id exception) {
            return nil;
        } 
    }
    
    return self;
}

#pragma mark Deprecated

+ (instancetype)method:(Method)method {
    return [[self alloc] initWithMethod:method class:nil isInstanceMethod:YES];
}

+ (instancetype)method:(Method)method isInstanceMethod:(BOOL)isInstanceMethod {
    return [[self alloc] initWithMethod:method class:nil isInstanceMethod:isInstanceMethod];
}

#pragma mark Descriptions

- (NSString *)description {
    if (!__description) {
        __description = [MKMethod prettyNameForMethod:self.objc_method isClassMethod:!_isInstanceMethod];
    }
    
    return __description;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ selector=%@, signature=%@>",
            NSStringFromClass(self.class), self.selectorString, self.signatureString];
}

- (NSString *)debugNameGivenClassName:(NSString *)name {
    NSMutableString *string = [NSMutableString stringWithString:_isInstanceMethod ? @"-[" : @"+["];
    [string appendString:name];
    [string appendString:@" "];
    [string appendString:self.selectorString];
    [string appendString:@"]"];
    return string;
}

#pragma mark Private

+ (NSString *)prettyNameForMethod:(Method)method isClassMethod:(BOOL)isClassMethod {
    NSString *selectorName = NSStringFromSelector(method_getName(method));
    NSString *methodTypeString = isClassMethod ? @"+" : @"-";
    NSString *readableReturnType = ({
        char *returnType = method_copyReturnType(method);
        NSString *ret = [self readableTypeForEncoding:@(returnType)];
        free(returnType);
        ret;
    });
    
    NSString *prettyName = [NSString stringWithFormat:@"%@ (%@)", methodTypeString, readableReturnType];
    NSArray *components = [self prettyArgumentComponentsForMethod:method];
    if (components.count) {
        prettyName = [prettyName stringByAppendingString:[components componentsJoinedByString:@" "]];
    } else {
        prettyName = [prettyName stringByAppendingString:selectorName];
    }
    
    return prettyName;
}

+ (NSArray *)prettyArgumentComponentsForMethod:(Method)method {
    NSMutableArray *components = [NSMutableArray array];
    
    NSString *selectorName = NSStringFromSelector(method_getName(method));
    NSArray *selectorComponents = [selectorName componentsSeparatedByString:@":"];
    unsigned int numberOfArguments = method_getNumberOfArguments(method);
    
    for (unsigned int argIndex = 2; argIndex < numberOfArguments; argIndex++) {
        char *argType = method_copyArgumentType(method, argIndex);
        NSString *readableArgType = [self readableTypeForEncoding:@(argType)];
        free(argType);
        NSString *prettyComponent = [NSString stringWithFormat:@"%@:(%@) ", [selectorComponents objectAtIndex:argIndex - 2], readableArgType];
        [components addObject:prettyComponent];
    }
    
    return components;
}

+ (NSString *)readableTypeForEncoding:(NSString *)encodingString {
    if (!encodingString) {
        return nil;
    }
    
    // See https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    // class-dump has a much nicer and much more complete implementation for this task, but it is distributed under GPLv2 :/
    // See https://github.com/nygard/class-dump/blob/master/Source/CDType.m
    // Warning: this method uses multiple middle returns and macros to cut down on boilerplate.
    // The use of macros here was inspired by https://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
    const char *encodingCString = [encodingString UTF8String];
    
    // Objects
    if (encodingCString[0] == '@') {
        NSMutableString *class = [encodingString substringFromIndex:1].mutableCopy;
        [class replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, class.length)];
        if (!class.length || [class isEqual:@"?"]) {
            [class setString:@"id"];
        } else {
            [class appendString:@" *"];
        }
        return class;
    }
    
    // C Types
#define TRANSLATE(ctype) \
if (strcmp(encodingCString, @encode(ctype)) == 0) { \
return (NSString *)CFSTR(#ctype); \
}
    
    // Order matters here since some of the cocoa types are typedefed to c types.
    // We can't recover the exact mapping, but we choose to prefer the cocoa types.
    // This is not an exhaustive list, but it covers the most common types
#ifdef CGGEOMETRY_H_
    TRANSLATE(CGRect);
    TRANSLATE(CGPoint);
    TRANSLATE(CGSize);
#else
    TRANSLATE(NSRect);
    TRANSLATE(NSPoint);
    TRANSLATE(NSSize);
#endif
#ifdef CGAFFINETRANSFORM_H_
    TRANSLATE(CGAffineTransform);
#endif
#ifdef CATRANSFORM_H
    TRANSLATE(CATransform3D);
#endif
#ifdef CGCOLOR_H_
    TRANSLATE(CGColorRef);
#endif
#ifdef CGPATH_H_
    TRANSLATE(CGPathRef);
#endif
#ifdef CGCONTEXT_H_
    TRANSLATE(CGContextRef);
#endif
#if __has_include(<UIKit/UIGeometry.h>)
    TRANSLATE(UIEdgeInsets);
    TRANSLATE(UIOffset);
#else
    TRANSLATE(NSEdgeInsets);
#endif
    TRANSLATE(NSInteger);
    TRANSLATE(NSUInteger);
    TRANSLATE(NSRange);
    TRANSLATE(CGFloat);
    
    TRANSLATE(BOOL);
    TRANSLATE(int);
    TRANSLATE(short);
    TRANSLATE(long);
    TRANSLATE(long long);
    TRANSLATE(unsigned char);
    TRANSLATE(unsigned int);
    TRANSLATE(unsigned short);
    TRANSLATE(unsigned long);
    TRANSLATE(unsigned long long);
    TRANSLATE(float);
    TRANSLATE(double);
    TRANSLATE(long double);
    TRANSLATE(char *);
    TRANSLATE(Class);
    TRANSLATE(objc_property_t);
    TRANSLATE(Ivar);
    TRANSLATE(Method);
    TRANSLATE(Category);
    TRANSLATE(NSZone *);
    TRANSLATE(SEL);
    TRANSLATE(void);
    
#undef TRANSLATE
    
    // Qualifier Prefixes
    // Do this after the checks above since some of the direct translations (i.e. Method) contain a prefix.
#define RECURSIVE_TRANSLATE(prefix, formatString) \
if (encodingCString[0] == prefix) { \
NSString *recursiveType = [self readableTypeForEncoding:[encodingString substringFromIndex:1]]; \
return [NSString stringWithFormat:formatString, recursiveType]; \
}
    
    // If there's a qualifier prefix on the encoding, translate it and then
    // recursively call this method with the rest of the encoding string.
    RECURSIVE_TRANSLATE('^', @"%@ *");
    RECURSIVE_TRANSLATE('r', @"const %@");
    RECURSIVE_TRANSLATE('n', @"in %@");
    RECURSIVE_TRANSLATE('N', @"inout %@");
    RECURSIVE_TRANSLATE('o', @"out %@");
    RECURSIVE_TRANSLATE('O', @"bycopy %@");
    RECURSIVE_TRANSLATE('R', @"byref %@");
    RECURSIVE_TRANSLATE('V', @"oneway %@");
    RECURSIVE_TRANSLATE('b', @"bitfield(%@)");
    
#undef RECURSIVE_TRANSLATE
    
    // If we couldn't translate, just return the original encoding string
    return encodingString;
}

- (void)examine {
    _implementation    = method_getImplementation(_objc_method);
    _selector          = method_getName(_objc_method);
    _numberOfArguments = method_getNumberOfArguments(_objc_method);
    _selectorString    = NSStringFromSelector(_selector);
    _typeEncoding      = [_signatureString stringByReplacingOccurrencesOfString:@"[0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, _signatureString.length)];
    _returnType        = (MKTypeEncoding)[_signatureString characterAtIndex:0];
    _fullName          = [self debugNameGivenClassName:NSStringFromClass(_targetClass)];
}

#pragma mark Setters

- (void)setImplementation:(IMP)implementation {
    NSParameterAssert(implementation);
    method_setImplementation(self.objc_method, implementation);
    [self examine];
}

#pragma mark Misc

- (BOOL)isImplementedInClass:(Class)cls {
    if (self.isInstanceMethod) {
        return self.objc_method == class_getInstanceMethod([cls class], self.selector);
    } else {
        return self.objc_method == class_getClassMethod([cls class], self.selector);
    }
}

- (void)swapImplementations:(MKMethod *)method {
    method_exchangeImplementations(self.objc_method, method.objc_method);
    [self examine];
    [method examine];
}

// Some code borrowed from MAObjcRuntime, by Mike Ash.
- (id)sendMessage:(id)target, ... {
    id ret = nil;
    va_list args;
    va_start(args, target);
    
    switch (self.returnType) {
        case MKTypeEncodingUnknown: {
            [self getReturnValue:NULL forMessageSend:target arguments:args];
            break;
        }
        case MKTypeEncodingChar: {
            char val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingInt: {
            int val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingShort: {
            short val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingLong: {
            long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingLongLong: {
            long long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingUnsignedChar: {
            unsigned char val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingUnsignedInt: {
            unsigned int val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingUnsignedShort: {
            unsigned short val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingUnsignedLong: {
            unsigned long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingUnsignedLongLong: {
            unsigned long long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingFloat: {
            float val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingDouble: {
            double val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingCBool: {
            bool val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingVoid: {
            [self getReturnValue:NULL forMessageSend:target arguments:args];
            return nil;
            break;
        }
        case MKTypeEncodingCString: {
            char * val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case MKTypeEncodingObjcObject: {
            id val = nil;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = val;
            break;
        }
        case MKTypeEncodingObjcClass: {
            Class val = Nil;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = val;
            break;
        }
        case MKTypeEncodingSelector: {
            SEL val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = NSStringFromSelector(val);
            break;
        }
        case MKTypeEncodingArray: {
            void * val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = [NSValue valueWithBytes:val objCType:self.signature.methodReturnType];
            break;
        }
        case MKTypeEncodingUnion:
        case MKTypeEncodingStruct: {
            void * val = malloc(self.signature.methodReturnLength);
            [self getReturnValue:val forMessageSend:target arguments:args];
            ret = [NSValue valueWithBytes:val objCType:self.signature.methodReturnType];
            break;
        }
        case MKTypeEncodingBitField: {
            [self getReturnValue:NULL forMessageSend:target arguments:args];
            break;
        }
        case MKTypeEncodingPointer: {
            void * val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = [NSValue valueWithPointer:val];
            break;
        }
    }
    
    va_end(args);
    return ret;
}

// Code borrowed from MAObjcRuntime, by Mike Ash.
- (void)getReturnValue:(void *)retPtr forMessageSend:(id)target, ... {
    va_list args;
    va_start(args, target);
    [self getReturnValue:retPtr forMessageSend:target arguments:args];
    va_end(args);
}

// Code borrowed from MAObjcRuntime, by Mike Ash.
- (void)getReturnValue:(void *)retPtr forMessageSend:(id)target arguments:(va_list)args {
    NSMethodSignature *signature = self.signature;

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger argumentCount = signature.numberOfArguments;
    
    invocation.target = target;
    
    for (NSUInteger i = 2; i < argumentCount; i++) {
        int cookie = va_arg(args, int);
        if (cookie != MKMagicNumber) {
            NSLog(@"%s: incorrect magic cookie %08x; make sure you didn\'t forget any arguments and that all arguments are wrapped in MKArg().", __func__, cookie);
            abort();
        }
        const char *typeString = va_arg(args, char *);
        void *argPointer       = va_arg(args, void *);
        
        NSUInteger inSize, sigSize;
        NSGetSizeAndAlignment(typeString, &inSize, NULL);
        NSGetSizeAndAlignment([signature getArgumentTypeAtIndex:i], &sigSize, NULL);
        
        if (inSize != sigSize) {
            NSLog(@"%s:size mismatch between passed-in argument and required argument; in type:%s (%lu) requested:%s (%lu)",
                  __func__, typeString, (long)inSize, [signature getArgumentTypeAtIndex:i], (long)sigSize);
            abort();
        }
        
        [invocation setArgument:argPointer atIndex:i];
    }
    
    // Hack to make NSInvocation invoke the desired implementation
    void (*invokeWithIMP)(id, SEL, IMP) = (void *)[invocation methodForSelector:NSSelectorFromString(@"invokeUsingIMP:")];
    invokeWithIMP(invocation, 0, _implementation);
    
    if (signature.methodReturnLength && retPtr)
        [invocation getReturnValue:retPtr];
}

@end


@implementation MKMethod (Comparison)

- (NSComparisonResult)compare:(MKMethod *)method {
    return [self.selectorString compare:method.selectorString];
}

@end
