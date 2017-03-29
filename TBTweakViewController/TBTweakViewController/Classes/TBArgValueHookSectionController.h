//
//  TBArgValueHookSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 10/7/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueSectionController.h"


@interface TBArgValueHookSectionController : TBValueSectionController

+ (instancetype)delegate:(id<TBValueSectionDelegate>)delegate
               signature:(NSMethodSignature *)signature
           argumentIndex:(NSUInteger)idx;

@end
