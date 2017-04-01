//
//  TBHookTypeSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 10/9/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBHookTypeSectionController.h"
#import "TBSettings.h"
#import "Categories.h"


@interface TBHookTypeSectionController ()
@property (nonatomic, weak, readonly) id<TBHookTypeSectionDelegate> delegate;

@property (nonatomic) TBSwitchCell *overrideReturnValueCell;
@property (nonatomic) TBSwitchCell *overrideArgumentValuesCell;
@property (nonatomic) TBSwitchCell *overrideWithChirpCell;
@end

@implementation TBHookTypeSectionController
@dynamic delegate;

+ (instancetype)delegate:(id<TBHookTypeSectionDelegate>)delegate {
    return [super delegate:delegate];
}

- (NSUInteger)sectionRowCount {
    NSUInteger i = 0;
    i += (bool)self.delegate.canOverrideReturnValue;
    i += (bool)self.delegate.canOverrideAllArgumentValues;
    i += (bool)TBSettings.chirpEnabled;
    return i;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row + (TBSettings.chirpEnabled ? 0 : 1);
    
    // Check row cache
    switch (row) {
        case 0:
            if (self.overrideWithChirpCell) {
                return self.overrideWithChirpCell;
            }
        case 1:
            if (self.delegate.canOverrideReturnValue && self.overrideReturnValueCell) {
                return self.overrideReturnValueCell;
            }
        case 2:
            if (self.overrideArgumentValuesCell) {
                return self.overrideArgumentValuesCell;
            }
    }
    
    TBSwitchCell *cell = [TBSwitchCell new];
    
    // Update cell on/off switch state according to tweak type
    //
    // +1 because rows start at 0 and types start at 1
    if (row + 1 & self.delegate.hookType) {
        cell.switchh.on = YES;
    } else {
        // TODO what was this for?
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    typedef void (^BoolBlock)(BOOL);
    void (^configureCell)(NSString *, TBHookType, BoolBlock) = ^(NSString *title, TBHookType type, BoolBlock action) {
        cell.textLabel.text = title;
        cell.imageView.image    = [UIImage iconForHookType:type];
        cell.switchh.on         = self.delegate.hookType & type;
        cell.switchToggleAction = action;
    };

    // Cell label and icon, switch action and state
    switch (row) {
        case 0: {
            self.overrideWithChirpCell = cell;
            configureCell(@"Implement with Chirp", TBHookTypeChirpCode, ^(BOOL on) {
                [self didToggleChirpCellState:on];
            });
            return cell;
        }
        case 1: {
            if (self.delegate.canOverrideReturnValue) {
                self.overrideReturnValueCell = cell;
                configureCell(@"Override Return Value", TBHookTypeReturnValue, ^(BOOL on) {
                    [self didToggleHookReturnValueCellState:on];
                });
                return cell;
            }
            // Fallthrough to arguments if cannot override return value
        }
        case 2: {
            self.overrideArgumentValuesCell = cell;
            configureCell(@"Override Parameter Values", TBHookTypeArguments, ^(BOOL on) {
                [self didToggleHookArgumentValuesCellState:on];
            });
            return cell;
        }
    }
    
    return nil;
}

- (BOOL)shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark Switch actions

- (void)didToggleHookReturnValueCellState:(BOOL)on {
    TBHookType type = self.delegate.hookType;
    type = on ? (type | TBHookTypeReturnValue) : (type & ~TBHookTypeReturnValue);

    // Update the tweak type and the states of the other switches
    // based on whether expert mode is on. Chirp can't be on with
    // any other switches for obvious reasons.
    [self.overrideWithChirpCell.switchh setOn:NO animated:YES];
    if (!TBSettings.expertMode) {
        // Disable args hook
        type &= ~TBHookTypeArguments;
        [self.overrideArgumentValuesCell.switchh setOn:NO animated:YES];
    }

    self.delegate.hookType = type;
    [self.delegate reloadSectionControllers];
}

- (void)didToggleHookArgumentValuesCellState:(BOOL)on {
    TBHookType type = self.delegate.hookType;
    type = on ? (type | TBHookTypeArguments) : (type & ~TBHookTypeArguments);

    // Update the tweak type and the states of the other switches
    // based on whether expert mode is on. Chirp can't be on with
    // any other switches for obvious reasons.
    [self.overrideWithChirpCell.switchh setOn:NO animated:YES];
    if (!TBSettings.expertMode) {
        // Disable return hook
        type &= ~TBHookTypeReturnValue;
        [self.overrideReturnValueCell.switchh setOn:NO animated:YES];
    }
    
    self.delegate.hookType = type;
    [self.delegate reloadSectionControllers];
}

- (void)didToggleChirpCellState:(BOOL)on {
    // The other switches should be off no matter what.
    // This must be done after the above line or the above
    // line will result in an incorrect difference.
    [self.overrideReturnValueCell.switchh setOn:NO animated:YES];
    [self.overrideArgumentValuesCell.switchh setOn:NO animated:YES];

    self.delegate.hookType = on ? TBHookTypeChirpCode : TBHookTypeUnspecified;
    [self.delegate reloadSectionControllers];
}

#pragma mark Public

- (BOOL)overrideReturnValue {
    return self.overrideReturnValueCell.switchh.isOn;
}

- (BOOL)overrideArguments {
    return self.overrideArgumentValuesCell.switchh.isOn;
}

- (BOOL)overrideWithChirp {
    return self.overrideWithChirpCell.switchh.isOn;
}

@end
