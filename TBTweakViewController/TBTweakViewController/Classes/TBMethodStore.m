//
//  TBMethodStore.m
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBMethodStore.h"


#pragma mark Variables

TBMethodStore methodStore;
NSCharacterSet *HFACharacters;

#pragma mark Initialization

void TBMethodStoreInit() {
    #define TBRetain(value) (__bridge id)(__bridge_retained CFTypeRef)value;

    HFACharacters = [NSCharacterSet characterSetWithCharactersInString:@"df"];
    methodStore.typeEncodings = TBRetain([NSMutableDictionary dictionary]);
    methodStore.lookup = TBRetain([NSHashTable hashTableWithOptions:NSPointerFunctionsOpaqueMemory]);
    methodStore.storage = TBRetain([NSMapTable mapTableWithKeyOptions:NSPointerFunctionsOpaqueMemory
                                                valueOptions:NSPointerFunctionsObjectPersonality]);
}

#pragma mark Queries

void TBMethodStorePut(Method key, TBMethodHook *value) {
    [methodStore.lookup addObject:(__bridge id)key];
    [methodStore.storage setObject:value forKey:(__bridge id)key];
}

//inline TBMethodInfo * TBMethodStoreGet(Method method) {
//    // Check cache
//    if (TBMethodStoreContains(method)) {
//        _TBMethodStoreGetMethodInfo(method);
//    }
//
//    // Get method signature, cache
//    const char *types = method_getTypeEncoding(method);
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:types];
//    TBMethodStoreInsert(method, signature);
//
//    return signature;
//}


