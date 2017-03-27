//
//  MKMirror+Reflection.m
//  Pods
//
//  Created by Tanner on 3/26/17.
//
//

#import "MKMirror+Reflection.h"
#import "MKLazyMethod.h"

@implementation MKMirror (Reflection)

+ (NSMutableArray<MKMethod*> *)allMethodsOf:(id)thing {
    NSMutableArray *all = [self instanceMethodsOf:thing];
    [all addObjectsFromArray:[self classMethodsOf:thing]];
    return all;
}

+ (NSMutableArray<MKMethod*> *)instanceMethodsOf:(id)thing {
    if (object_isClass(thing)) {
        return [self _methodsOf:thing targetClass:thing instance:YES];
    } else {
        Class cls = object_getClass(thing);
        return [self _methodsOf:cls targetClass:cls instance:YES];
    }
}

+ (NSMutableArray<MKMethod*> *)classMethodsOf:(id)thing {
    if (object_isClass(thing)) {
        Class metaclass = object_getClass(thing);
        return [self _methodsOf:metaclass targetClass:thing instance:NO];
    } else {
        Class cls = object_getClass(thing);
        Class metaclass = object_getClass(cls);
        return [self _methodsOf:metaclass targetClass:cls instance:NO];
    }
}

+ (NSMutableArray<MKMethod*> *)_methodsOf:(Class)cls targetClass:(Class)target instance:(BOOL)instance {
    unsigned int mcount = 0;
    Method *objcmethods = class_copyMethodList(cls, &mcount);

    NSMutableArray *methods = [NSMutableArray array];
    for (int i = 0; i < mcount; i++) {
        MKMethod *m = [MKLazyMethod method:objcmethods[i] class:target isInstanceMethod:instance];
        if (m) {
            [methods addObject:m];
        }
    }

    free(objcmethods);
    return methods;
}

@end
