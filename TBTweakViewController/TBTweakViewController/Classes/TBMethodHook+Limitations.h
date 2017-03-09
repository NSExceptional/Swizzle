//
//  TBMethodHook+Limitations.h
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook.h"

@interface TBMethodHook (Limitations)

+ (BOOL)canHookValueOfType:(const char *)fullTypeEncoding;
+ (BOOL)canHookReturnTypeOf:(MKMethod *)method;
+ (BOOL)canHookAllArgumentTypesOf:(MKMethod *)method;

@end
