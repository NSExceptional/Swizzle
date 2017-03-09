//
//  TBMethodHook+IMP.h
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook.h"

@interface TBMethodHook (IMP)

- (IMP)IMPForHookedReturnType;
- (IMP)IMPForHookedArguments;

@end
