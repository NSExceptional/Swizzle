//
//  TBConfigureTweakViewController+UITableViewDataSource.m
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureTweakViewController+UITableViewDataSource.h"
#import "TBSettings.h"
#import "TBValue+ValueHelpers.h"


#define dequeue dequeueReusableCellWithIdentifier
#define format(...) [NSString stringWithFormat:__VA_ARGS__]
#define THEOS 0

NSString * const kTweakTypeCellReuse = @"kTweakTypeCellReuse";

NSString * const kDisclosureIndicatorCellReuse = @"kDisclosureIndicatorCellReuse";
NSString * const kAddValueCellReuse            = @"kAddValueCellReuse";
NSString * const kChirpCellReuse               = @"kChirpCellReuse";
NSString * const kDateCellReuse                = @"kDateCellReuse";
NSString * const kColorCellReuse               = @"kColorCellReuse";
NSString * const kNumberCellReuse              = @"kNumberCellReuse";
NSString * const kStringClassSELCellReuse      = @"kStringClassSELCellReuse";


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
    [self.tableView registerClass:[TBSwitchCell class] forCellReuseIdentifier:kTweakTypeCellReuse];
    [self.tableView registerClass:[TBDetailDisclosureCell class] forCellReuseIdentifier:kDisclosureIndicatorCellReuse];
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

- (UITableViewCell *)valueDescriptionCellForIndexPath:(NSIndexPath *)ip {
    BOOL hookingReturnValue = self.tweakType & TBTweakTypeHookReturnValue;
    
    if (ip.section == 1 && hookingReturnValue) {
        return [self valueTypePickerCellForValueType:self.hookedReturnValue.type forIndexPath:ip];
    } else {
        // Offset from first section and return value section if present
        NSInteger offset = (NSInteger)hookingReturnValue + 1;
        TBValueType type = self.hookedArguments[ip.row - offset].type;
        return [self valueTypePickerCellForValueType:type forIndexPath:ip];
    }
}

- (TBDetailDisclosureCell *)valueTypePickerCellForValueType:(TBValueType)type forIndexPath:(NSIndexPath *)ip {
    TBDetailDisclosureCell *cell = [self.tableView dequeue:kDisclosureIndicatorCellReuse forIndexPath:ip];
    cell.detailTextLabel.text = TBStringFromValueType(type);
    cell.textLabel.text = @"Value Kind";
    
    return cell;
}

- (UITableViewCell *)valueCellForValue:(TBValue *)value forIndexPath:(NSIndexPath *)ip {
    NSString *reuse = [self cellReuseIdentifierForValueCellForValueType:value.type];
    UITableViewCell *cell = [self.tableView dequeue:reuse forIndexPath:ip];
    
    switch (value.type) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue: {
            break;
        }
        case TBValueTypeChirpValue: {
            TBChirpCell *celll = (id)cell;
            celll.text = value.chirpValue;
            break;
        }
        case TBValueTypeClass: {
            TBStringCell *celll = (id)cell;
            celll.text = value.classNameValue;
            break;
        }
        case TBValueTypeSelector: {
            TBStringCell *celll = (id)cell;
            celll.text = value.selectorValue;
            break;
        }
        case TBValueTypeNumber: {
            TBNumberCell *celll = (id)cell;
            celll.text = value.numberValue.description;
            break;
        }
        case TBValueTypeString: {
            TBStringCell *celll = (id)cell;
            celll.text = value.stringValue;
            break;
        }
        case TBValueTypeMutableString: {
            TBStringCell *celll = (id)cell;
            celll.text = value.mutableStringValue;
            break;
        }
        case TBValueTypeDate: {
            TBDateCell *celll = (id)cell;
            celll.date = value.dateValue;
            break;
        }
        case TBValueTypeColor: {
            TBColorCell *celll = (id)cell;
            celll.color = value.colorValue;
            break;
        }
        case TBValueTypeArray:
        case TBValueTypeSet:
        case TBValueTypeMutableArray:
        case TBValueTypeMutableSet: {
            TBDetailDisclosureCell *celll = (id)cell;
            celll.textLabel.text = @"Edit";
            celll.detailTextLabel.text = format(@"%lu element(s)", ((NSArray*)value.value).count);
            break;
        }
        case TBValueTypeDictionary:
        case TBValueTypeMutableDictionary: {
            TBDetailDisclosureCell *celll = (id)cell;
            celll.textLabel.text = @"Edit";
            celll.detailTextLabel.text = format(@"%lu key-value pair(s)", ((NSArray*)value.value).count);
            break;
        }
    }
    
    return cell;
}

- (NSString *)cellReuseIdentifierForValueCellForValueType:(TBValueType)type {
    switch (type) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue:
            return nil;
        case TBValueTypeChirpValue:
            return kChirpCellReuse;
        case TBValueTypeClass:
            return kStringClassSELCellReuse;
        case TBValueTypeSelector:
            return kStringClassSELCellReuse;
        case TBValueTypeNumber:
            return kNumberCellReuse;
        case TBValueTypeString:
            return kStringClassSELCellReuse;
        case TBValueTypeMutableString:
            return kStringClassSELCellReuse;
        case TBValueTypeDate:
            return kDateCellReuse;
        case TBValueTypeColor:
            return kColorCellReuse;
        case TBValueTypeArray:
        case TBValueTypeDictionary:
        case TBValueTypeSet:
        case TBValueTypeMutableArray:
        case TBValueTypeMutableSet:
        case TBValueTypeMutableDictionary:
            return kDisclosureIndicatorCellReuse;
    }
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
    if (TBSettings.expertMode && self.overrideArgumentValuesCell.switchh.isOn) {
        desired += self.tweak.hook.method.numberOfArguments;
    }
    NSInteger sectionDifference = self.totalNumberOfSections - desired;
    
    TBTweakType newType = TBTweakTypeHookReturnValue;
    self.overrideWithChirpCell.switchh.on = NO;
    if (!TBSettings.expertMode) {
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
    if (TBSettings.expertMode && self.overrideReturnValueCell.switchh.isOn) {
        desired += 1;
    }
    NSInteger sectionDifference = self.totalNumberOfSections - desired;
    
    TBTweakType newType = TBTweakTypeHookArguments;
    self.overrideWithChirpCell.switchh.on = NO;
    if (!TBSettings.expertMode) {
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
    }
    else if (sectionDifference == 0) {
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, total-1)];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, labs(sectionDifference))];
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
