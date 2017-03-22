//
//  TBMethodStore.h
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ObjectiveC;

@class TBMethodHook;


typedef struct _TBMethodStore {
    __unsafe_unretained NSHashTable *lookup; /* <Method> */
    __unsafe_unretained NSMapTable *storage; /* <Method, TBMethodHook*> */
    /// Full type encodings to in-memory layouts, for HFA checking
    __unsafe_unretained NSMutableDictionary<NSString*, NSString*> *typeEncodings;
} TBMethodStore;

/// Singleton instance
extern TBMethodStore methodStore;
extern NSCharacterSet *HFACharacters;

/// Initializes singleton
extern void TBMethodStoreInit();

/// Methods are used as keys
static inline Method TBMethodStoreGetKey(id obj, SEL sel) {
    Class cls = [obj class];
    BOOL instance = cls != obj;
    return instance ? class_getInstanceMethod(cls, sel) : class_getClassMethod(cls, sel);
}

static inline TBMethodHook * TBMethodStoreGet(Method method) {
    return [methodStore.storage objectForKey:(__bridge id)method];
}

void TBMethodStorePut(Method key, TBMethodHook *value);
void TBMethodStoreRemove(Method key);
