//
//  SwizzleInit.h
//  TBTweakViewController
//
//  Created by Tanner on 3/27/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMethodStore.h"
#import "TBTweakManager.h"

/// Must be called on the main thread before using any part of Swizzle
static inline void SwizzleInit() {
    assert([NSThread isMainThread]);

    TBMethodStoreInit();
    [NSClassFromString(@"_UICompatibilityTextView") new];
    [TBTweakManager sharedManager];
}
