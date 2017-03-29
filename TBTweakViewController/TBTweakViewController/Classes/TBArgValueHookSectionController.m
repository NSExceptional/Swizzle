//
//  TBArgValueHookSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 10/7/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBArgValueHookSectionController.h"
#import "TBSwitchCell.h"
#import "TBValue+ValueHelpers.h"
#import "TBValueCells.h"
#import "TBSettings.h"

#define dequeue dequeueReusableCellWithIdentifier
#define format(...) [NSString stringWithFormat:__VA_ARGS__]

@interface TBArgValueHookSectionController ()
@property (nonatomic, readonly) NSUInteger argIdx;
@end

@implementation TBArgValueHookSectionController

+ (instancetype)delegate:(id<TBValueSectionDelegate>)delegate
               signature:(NSMethodSignature *)signature
           argumentIndex:(NSUInteger)idx {
    const char *type = [signature getArgumentTypeAtIndex:idx];
    TBArgValueHookSectionController *controller = [super delegate:delegate type:type];
    controller->_typeEncoding = type;
    controller->_argIdx       = idx;
    controller.valueType      = TBValueTypeFromTypeEncoding(controller->_typeEncoding);
    controller->_container    = [TBValue orig];
    return controller;
}

#pragma mark Overrides

- (NSString *)typePickerTitle {
    return @"Change argument type";
}

- (NSUInteger)sectionRowCount {
    // Hide last row if null
    if (self.container.overriden) {
        return self.container == [TBValue null] ? 2 : 3;
    }

    // Hide last two rows until overridden
    return 1;
}

- (BOOL)shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self shouldHighlightRow:indexPath.row];
}

- (TBSwitchCell *)toggleForParameterAtIndexPath:(NSIndexPath *)ip {
    TBSwitchCell *cell = [super toggleForParameterAtIndexPath:ip];

    unsigned long userVisibleArgIdx = TBSettings.expertMode ? self.argIdx : self.argIdx - 2;

    cell.textLabel.text = format(@"Override arg%lu", userVisibleArgIdx);
    cell.switchToggleAction = ^(BOOL on) {
        [self didToggleArgSwitch:on];
    };

    return cell;
}

- (void)didToggleArgSwitch:(BOOL)on {
    /// Toggle value between default and original value for the argument's type signature
    if (self.container.notOverridden) {
        _container = [TBValue defaultValueForTypeEncoding:self.typeEncoding];
    } else {
        _container = [TBValue orig];
    }
    [self.delegate setArgumentHookValue:self.container atIndex:self.argIdx];
}

@end
