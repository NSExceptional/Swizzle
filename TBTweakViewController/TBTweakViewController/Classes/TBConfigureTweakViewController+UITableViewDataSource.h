//
//  TBConfigureTweakViewController+UITableViewDataSource.h
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureTweakViewController.h"
#import "TBSwitchCell.h"
#import "TBValueCells.h"


#pragma mark String constants
extern NSString * const kTweakTypeCellReuse;

extern NSString * const kTypeCellReuse;
extern NSString * const kValueCellReuse;
extern NSString * const kAddValueCellReuse;
extern NSString * const kChirpCellReuse;
extern NSString * const kDateCellReuse;
extern NSString * const kColorCellReuse;
extern NSString * const kNumberCellReuse;
extern NSString * const kStringClassSELCellReuse;

#pragma mark TBConfigureTweakViewController (UITableViewDataSource)
@interface TBConfigureTweakViewController (UITableViewDataSource)

- (void)configureTableViewForCellReuseAndAutomaticRowHeight;

- (TBSwitchCell *)tweakOptionsSwitchCellForRow:(NSUInteger)row;
- (UITableViewCell *)valueDescriptionCellForSection:(NSUInteger)section;
- (TBBaseValueCell *)valueCellForSection:(NSUInteger)section;

@end
