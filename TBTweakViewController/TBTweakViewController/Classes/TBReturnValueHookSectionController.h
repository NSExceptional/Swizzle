//
//  TBReturnValueHookSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 10/9/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueSectionController.h"


@interface TBReturnValueHookSectionController : TBValueSectionController

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate
                    type:(const char *)typeEncoding
            initialValue:(TBValue *)initialvalue;

@end
