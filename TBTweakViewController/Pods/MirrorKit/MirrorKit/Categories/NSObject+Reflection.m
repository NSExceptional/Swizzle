//
//  NSObject+Reflection.m
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSObject+Reflection.h"
#import "MKMirror.h"
#import "MKProperty.h"
#import "MKLazyMethod.h"
#import "MKIVar.h"
#import "MKPropertyAttributes.h"
#import "MKPrivate.h"
#import "MKMirror+Reflection.h"


NSString * MKTypeEncodingString(const char *returnType, NSUInteger count, ...) {
    if (returnType == NULL) return nil;
    
    NSMutableString *encoding = [NSMutableString string];
    [encoding appendFormat:@"%s%s%s", returnType, @encode(id), @encode(SEL)];
    
    va_list args;
    va_start(args, count);
    char *type = va_arg(args, char *);
    for (NSUInteger i = 0; i < count; i++, type = va_arg(args, char *)) {
        [encoding appendFormat:@"%s", type];
    }
    va_end(args);
    
    return encoding.copy;
}

#pragma mark - Reflection -

@implementation NSObject (Reflection)

+ (MKMirror *)reflection {
    return [MKMirror reflect:self];
}

- (MKMirror *)reflection {
    return [MKMirror reflect:self];
}

/** Code borrowed from MAObjCRuntime by Mike Ash. */
+ (NSArray *)allSubclasses {
    Class *buffer = NULL;
    
    int count, size;
    do {
        count  = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size   = objc_getClassList(buffer, count);
    } while(size != count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < count; i++) {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while(superclass) {
            if(superclass == self) {
                Class cls = buffer[i];
                if (MKClassIsSafe(cls)) {
                    [array addObject:candidate];
                }

                break;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    
    free(buffer);
    [array removeObject:self.class];
    return array;
}

- (Class)setClass:(Class)cls {
    return object_setClass(self, cls);
}

+ (Class)metaclass {
    return objc_getMetaClass(NSStringFromClass(self.class).UTF8String);
}

+ (size_t)instanceSize {
    return class_getInstanceSize(self.class);
}

#ifdef __clang__
#pragma clang diagnostic push
#endif
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (Class)setSuperclass:(Class)superclass {
    return class_setSuperclass(self, superclass);
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif

@end


#pragma mark - Methods -

@implementation NSObject (Methods)

+ (NSArray *)allMethods {
    [MKMirror allMethodsOf:self];
}

+ (MKMethod *)methodNamed:(NSString *)name {
    return [MKLazyMethod instanceMethod:NSSelectorFromString(name) class:self];
}

+ (MKMethod *)classMethodNamed:(NSString *)name {
    return [MKLazyMethod classMethod:NSSelectorFromString(name) class:self];
}

+ (BOOL)addMethod:(SEL)selector typeEncoding:(NSString *)typeEncoding implementation:(IMP)implementaiton toInstances:(BOOL)instance {
    return class_addMethod(instance ? self.class : self.metaclass, selector, implementaiton, typeEncoding.UTF8String);
}

+ (IMP)replaceImplementationOfMethod:(MKSimpleMethod *)method with:(IMP)implementation useInstance:(BOOL)instance {
    return class_replaceMethod(instance ? self.class : self.metaclass, method.selector, implementation, method.typeEncoding.UTF8String);
}

+ (void)swizzle:(MKSimpleMethod *)original with:(MKSimpleMethod *)other onInstance:(BOOL)instance {
    [self swizzleBySelector:original.selector with:other.selector onInstance:instance];
}

+ (BOOL)swizzleByName:(NSString *)original with:(NSString *)other onInstance:(BOOL)instance {
    SEL originalMethod = NSSelectorFromString(original);
    SEL newMethod      = NSSelectorFromString(other);
    if (originalMethod == 0 || newMethod == 0)
        return NO;
    
    [self swizzleBySelector:originalMethod with:newMethod onInstance:instance];
    return YES;
}

+ (void)swizzleBySelector:(SEL)original with:(SEL)other onInstance:(BOOL)instance {
    Class cls = instance ? self.class : self.metaclass;
    Method originalMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, other);
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, other, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end


#pragma mark - IVars -

@implementation NSObject (IVars)

+ (NSArray *)allIVars {
    unsigned int ivcount;
    Ivar *objcivars = class_copyIvarList(self.class, &ivcount);
    
    NSMutableArray *ivars = [NSMutableArray array];
    for (int i = 0; i < ivcount; i++)
        [ivars addObject:[MKIVar ivar:objcivars[i]]];
    
    free(objcivars);
    return ivars;
}

+ (MKIVar *)IVarNamed:(NSString *)name {
    Ivar i = class_getInstanceVariable(self.class, name.UTF8String);
    if (i == NULL)
        return nil;
    return [MKIVar ivar:i];
}

#pragma mark Get address
- (void *)getIVarAddress:(MKIVar *)ivar {
    return (uint8_t *)(__bridge void *)self + ivar.offset;
}

- (void *)getObjcIVarAddress:(Ivar)ivar {
    return (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar);
}

- (void *)getIVarAddressByName:(NSString *)name {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return 0;
    
    return (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar);
}

#pragma mark Set ivar object
- (void)setIvar:(MKIVar *)ivar object:(id)value {
    object_setIvar(self, ivar.objc_ivar, value);
}

- (BOOL)setIVarByName:(NSString *)name object:(id)value {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return NO;
    
    object_setIvar(self, ivar, value);
    return YES;
}

- (void)setObjcIVar:(Ivar)ivar object:(id)value {
    object_setIvar(self, ivar, value);
}

#pragma mark Set ivar value
- (void)setIVar:(MKIVar *)ivar value:(void *)value size:(size_t)size {
    void *address = [self getIVarAddress:ivar];
    memcpy(address, value, size);
}

- (BOOL)setIVarByName:(NSString *)name value:(void *)value size:(size_t)size {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return NO;
    
    [self setObjcIVar:ivar value:value size:size];
    return YES;
}

- (void)setObjcIVar:(Ivar)ivar value:(void *)value size:(size_t)size {
    void *address = [self getObjcIVarAddress:ivar];
    memcpy(address, value, size);
}

@end


#pragma mark - Properties -

@implementation NSObject (Properties)

+ (NSArray *)allProperties {
    unsigned int pcount;
    objc_property_t *objcproperties = class_copyPropertyList(self.class, &pcount);
    
    NSMutableArray *properties = [NSMutableArray array];
    for (int i = 0; i < pcount; i++)
        [properties addObject:[MKProperty property:objcproperties[i]]];
    
    free(objcproperties);
    return properties;
}

+ (MKProperty *)propertyNamed:(NSString *)name {
    objc_property_t p = class_getProperty(self.class, name.UTF8String);
    if (p == NULL)
        return nil;
    return [MKProperty property:p];
}

+ (void)replaceProperty:(MKProperty *)property {
    [self replaceProperty:property.name attributes:property.attributes];
}

+ (void)replaceProperty:(NSString *)name attributes:(MKPropertyAttributes *)attributes {
    unsigned int count;
    objc_property_attribute_t *objc_attributes = [attributes copyAttributesList:&count];
    class_replaceProperty(self.class, name.UTF8String, objc_attributes, count);
    free(objc_attributes);
}

@end


