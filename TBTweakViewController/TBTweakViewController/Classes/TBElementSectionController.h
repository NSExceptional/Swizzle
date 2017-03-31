//
//  TBElementSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueSectionController.h"


@interface TBElementSectionController : TBValueSectionController

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate;
+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate object:(id)value;

@end
