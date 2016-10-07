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
/// For the top three switches
extern NSString * const kTweakTypeCellReuse;

/// For choosing a hook type, or editing collections
extern NSString * const kDisclosureIndicatorCellReuse;
extern NSString * const kAddValueCellReuse;
extern NSString * const kChirpCellReuse;
extern NSString * const kDateCellReuse;
extern NSString * const kColorCellReuse;
extern NSString * const kNumberCellReuse;
extern NSString * const kStringClassSELCellReuse;

#pragma mark - TBConfigureTweakViewController (UITableViewDataSource)
@interface TBConfigureTweakViewController (UITableViewDataSource)

- (void)configureTableViewForCellReuseAndAutomaticRowHeight;

#pragma mark Section 0
/// Switch cells (return value, parameters, chirp)
- (TBSwitchCell *)tweakOptionsSwitchCellForRow:(NSUInteger)row;

#pragma mark Other sections
/// Value Kind ___ >
- (UITableViewCell *)valueTypePickerCellForValueType:(TBValueType)type forIndexPath:(NSIndexPath *)ip;
/// Cells that actually hold the value
- (TBBaseValueCell *)valueCellForValue:(TBValue *)value forIndexPath:(NSIndexPath *)ip;

@end
