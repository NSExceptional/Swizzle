//
//  TBMethodStore.h
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class TBMethodHook;


typedef struct _TBMethodStore {
    __unsafe_unretained NSHashTable *lookup; /* <Method> */
    __unsafe_unretained NSMapTable *storage; /* <Method, TBMethodHook*> */
    /// Full type encodings to in-memory layouts, for HFA checking
    __unsafe_unretained NSMutableDictionary<NSString*, NSString*> *typeEncodings;
} TBMethodStore;

#if defined __cplusplus
extern "C" {
#endif

/// Singleton instance
extern TBMethodStore methodStore;
extern NSCharacterSet *HFACharacters;

/// Initializes singleton
extern void TBMethodStoreInit();

static inline TBMethodHook * TBMethodStoreGet(IMP method) {
    return [methodStore.storage objectForKey:(__bridge id)(void *)method];
}

void TBMethodStorePut(IMP key, TBMethodHook *value);
void TBMethodStoreRemove(IMP key);

#if defined __cplusplus
};
#endif 
