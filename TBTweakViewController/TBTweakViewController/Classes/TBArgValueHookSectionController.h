//
//  TBArgValueHookSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 10/7/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueHookSectionController.h"


@interface TBArgValueHookSectionController : TBValueHookSectionController

+ (instancetype)delegate:(id<TBValueHookSectionDelegate>)delegate
               signature:(NSMethodSignature *)signature
           argumentIndex:(NSUInteger)idx;

@end
