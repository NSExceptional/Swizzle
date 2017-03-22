//
//  TBConfigureTweakViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTweak.h"
@class TBSectionController, TBTweakTypeSectionController;
@class TBReturnValueHookSectionController, TBSwitchCell;


/// Used to edit the configuration of a tweak, existing or new.
@interface TBConfigureTweakViewController : UITableViewController

+ (instancetype)forTweak:(TBTweak *)tweak saveAction:(void(^)())saveAction;


// Internal

@property (nonatomic, readonly) TBTweak *tweak;
@property (nonatomic          ) TBTweakType tweakType;
@property (nonatomic, copy    ) void (^saveAction)();

@property (nonatomic) TBValue *hookedReturnValue;
@property (nonatomic) NSMutableArray<TBValue*> *hookedArguments;
@property (nonatomic) NSString *chirpString;

@property (nonatomic, readonly) TBTweakTypeSectionController *tweakTypeSectionController;
@property (nonatomic, readonly) TBReturnValueHookSectionController *returnValueHookSectionController;
@property (nonatomic, readonly) NSMutableArray<TBSectionController*> *dynamicSectionControllers;

@end
