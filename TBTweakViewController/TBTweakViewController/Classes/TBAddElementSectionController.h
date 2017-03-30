//
//  TBAddElementSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBSectionController.h"


@interface TBAddElementSectionController : TBSectionController

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate onTap:(void(^)())tapAction;

@end
