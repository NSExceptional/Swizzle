//
//  TBConfigureTweakViewController+UITableViewDataSource.m
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureTweakViewController+UITableViewDataSource.h"


#define dequeue dequeueReusableCellWithIdentifier
#define THEOS 0

NSString * const kTweakTypeCellReuse = @"kTweakTypeCellReuse";

NSString * const kTypeCellReuse     = @"kTypeCellReuse";
NSString * const kValueCellReuse    = @"kValueCellReuse";
NSString * const kAddValueCellReuse = @"kAddValueCellReuse";
NSString * const kChirpCellReuse    = @"kChirpCellReuse";
NSString * const kDateCellReuse     = @"kDateCellReuse";
NSString * const kColorCellReuse    = @"kColorCellReuse";
NSString * const kNumberCellReuse   = @"kNumberCellReuse";
NSString * const kStringClassSELCellReuse = @"kStringClassSELCellReuse";


@interface TBConfigureTweakViewController ()
@property (nonatomic, readonly) NSUInteger totalNumberOfSections;
@end

@implementation TBConfigureTweakViewController (UITableViewDataSource)

#pragma mark Helper

- (NSUInteger)totalNumberOfSections {
    NSUInteger i = 1;
    if (self.overrideReturnValueCell.switchh.isOn)
        i++;
    if (self.overrideArgumentValuesCell.switchh.isOn)
        i += self.tweak.hook.method.numberOfArguments;
    
    return i;
}

- (void)configureTableViewForCellReuseAndAutomaticRowHeight {
    // Cell classes
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTweakTypeCellReuse];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kValueCellReuse];
    [self.tableView registerClass:[TBChirpCell class] forCellReuseIdentifier:kChirpCellReuse];
    
    // Row height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark Type icons

- (NSBundle *)bundleForImages {
    return [NSBundle bundleForClass:self.class];
}

- (UIImage *)chirpIcon {
#if THEOS
    NSString *imagePath = [[self bundleForImages] pathForResource:@"chirp_icon" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
#else
    return [UIImage imageNamed:@"chirp_icon"];
#endif
}

- (UIImage *)overrideReturnIcon {
#if THEOS
    NSString *imagePath = [[self bundleForImages] pathForResource:@"override_return_icon" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
#else
    return [UIImage imageNamed:@"override_return_icon"];
#endif
}

- (UIImage *)overrideParamsIcon {
#if THEOS
    NSString *imagePath = [[self bundleForImages] pathForResource:@"override_params_icon" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
#else
    return [UIImage imageNamed:@"override_params_icon"];
#endif
}

#pragma mark Section 0

/// TWeak option cells (chirp, return type, arguments) are not dequeued.
- (TBSwitchCell *)tweakOptionsSwitchCellForRow:(NSUInteger)row {
    // Check row cache
    switch (row) {
        case 0:
            if (self.overrideWithChirpCell) {
                return self.overrideWithChirpCell;
            }
        case 1:
            if (self.tweak.hook.canOverrideReturnValue &&
                self.overrideReturnValueCell) {
                return self.overrideReturnValueCell;
            }
        case 2:
            if (self.overrideArgumentValuesCell) {
                return self.overrideArgumentValuesCell;
            }
    }
    
    TBSwitchCell *cell = [[TBSwitchCell alloc] initWithStyle:0 reuseIdentifier:kTweakTypeCellReuse];
    
    // Update cell on/off switch state accordint to tweak type
    if (row+1 == self.tweakType) {
        cell.switchh.on = YES;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Cell label and icon
    switch (row) {
        case 0: {
            self.overrideWithChirpCell = cell;
            cell.textLabel.text     = @"Implement with Chirp";
            cell.imageView.image    = [self chirpIcon];
            cell.switchToggleAction = ^(BOOL on) {
                [self didToggleChirpCellState:on];
            };
            return cell;
        }
        case 1: {
            if (self.tweak.hook.canOverrideReturnValue) {
                self.overrideReturnValueCell = cell;
                cell.textLabel.text     = @"Override Return Value";
                cell.imageView.image    = [self overrideReturnIcon];
                cell.switchToggleAction = ^(BOOL on) {
                    [self didToggleHookReturnValueCellState:on];
                };
                return cell;
            }
            // Fallthrough to arguments
        }
        case 2: {
            self.overrideArgumentValuesCell = cell;
            cell.textLabel.text     = @"Override Parameter Values";
            cell.imageView.image    = [self overrideParamsIcon];
            cell.switchToggleAction = ^(BOOL on) {
                [self didToggleHookArgumentValuesCellState:on];
            };
            return cell;
        }
    }
    
    return nil;
}

#pragma mark Other sections

- (UITableViewCell *)valueDescriptionCellForSection:(NSUInteger)section {
    if (section == 1 && self.tweakType & TBTweakTypeHookReturnValue) {
        
    } else {
        NSInteger offset = self.tweakType & TBTweakTypeHookReturnValue ? 1 : 0;
    }
}

- (TBBaseValueCell *)valueCellForSection:(NSUInteger)section {
    
}

#pragma mark Toggling sections

- (void)didToggleChirpCellState:(BOOL)on {
    NSInteger desired = on ? 2 : 1;
    NSInteger sectionDifference = self.totalNumberOfSections - desired;
    self.overrideReturnValueCell.switchh.on = NO;
    self.overrideArgumentValuesCell.switchh.on = NO;
    
    self.tweakType = TBTweakTypeChirpCode;
    [self updateTableViewWithSectionDifference:sectionDifference desiredNumberOfSections:desired];
}

- (void)didToggleHookReturnValueCellState:(BOOL)on {
    NSInteger desired = on ? 2 : 1;
    if (self.expertMode && self.overrideArgumentValuesCell.switchh.isOn) {
        desired += self.tweak.hook.method.numberOfArguments;
    }
    NSInteger sectionDifference = self.totalNumberOfSections - desired;
    
    TBTweakType newType = TBTweakTypeHookReturnValue;
    self.overrideWithChirpCell.switchh.on = NO;
    if (!self.expertMode) {
        self.overrideArgumentValuesCell.switchh.on = NO;
    }
    else if (self.overrideArgumentValuesCell.switchh.isOn) {
        newType |= TBTweakTypeHookArguments;
    }
    
    self.tweakType = newType;
    [self updateTableViewWithSectionDifference:sectionDifference desiredNumberOfSections:desired];
}

- (void)didToggleHookArgumentValuesCellState:(BOOL)on {
    NSInteger desired = on ? 1 + self.tweak.hook.method.numberOfArguments : 1;
    if (self.expertMode && self.overrideReturnValueCell.switchh.isOn) {
        desired += 1;
    }
    NSInteger sectionDifference = self.totalNumberOfSections - desired;
    
    TBTweakType newType = TBTweakTypeHookArguments;
    self.overrideWithChirpCell.switchh.on = NO;
    if (!self.expertMode) {
        self.overrideReturnValueCell.switchh.on = NO;
    }
    else if (self.overrideReturnValueCell.switchh.isOn) {
        newType |= TBTweakTypeHookReturnValue;
    }
    
    self.tweakType = newType;
    [self updateTableViewWithSectionDifference:sectionDifference desiredNumberOfSections:desired];
}

- (void)updateTableViewWithSectionDifference:(NSInteger)sectionDifference desiredNumberOfSections:(NSUInteger)total {
    if (sectionDifference > 0) {
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(total, sectionDifference)];
        [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (sectionDifference == 0) {
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, total-1)];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, labs(sectionDifference))];
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
