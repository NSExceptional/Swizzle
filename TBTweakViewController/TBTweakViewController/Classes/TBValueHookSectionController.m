//
//  TBValueHookSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueHookSectionController.h"
#import "TBValue+ValueHelpers.h"
#import "TBSwitchCell.h"
#import "TBTypePickerViewController.h"
#import "Categories.h"


#define dequeue dequeueReusableCellWithIdentifier
#define format(...) [NSString stringWithFormat:__VA_ARGS__]

@interface TBValueHookSectionController ()
@property (nonatomic) TBValue *hookedValue;
@end

@implementation TBValueHookSectionController
@dynamic delegate, typePickerTitle;

+ (instancetype)delegate:(id<TBValueHookSectionDelegate>)delegate signature:(NSMethodSignature *)signature {
    TBValueHookSectionController *controller = [super delegate:delegate];
    controller->_hookedValue = [TBValue orig];
    controller->_signature   = signature;
    return controller;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    @throw NSGenericException;
}

#pragma mark Public

- (BOOL)shouldHighlightRow:(TBHookRow)row {
    switch (row) {
        case TBHookRowToggle:
            return NO;
        case TBHookRowTypePicker:
            return TBCanChangeType(self.typeEncoding[0]);
        case TBHookRowValueHolder:
            switch (self.hookedValue.type) {
                case TBValueTypeArray:
                case TBValueTypeDictionary:
                case TBValueTypeSet:
                case TBValueTypeMutableArray:
                case TBValueTypeMutableSet:
                case TBValueTypeMutableDictionary:
                case TBValueTypeStruct:
                    return YES;
                default:
                    return NO;
            }
    }

    @throw NSGenericException;
    return NO;
}

#pragma mark Overrides

- (TBTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case TBHookRowToggle:
            return [self toggleForParameterAtIndexPath:indexPath];
            break;
        case TBHookRowTypePicker:
            return [self valueTypePickerCellForIndexPath:indexPath];
            break;
        case TBHookRowValueHolder:
            return [self valueCellForIndexPath:indexPath];
            break;
    }

    @throw NSGenericException;
    return nil;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case TBHookRowToggle:
            @throw NSInternalInconsistencyException;
        case TBHookRowTypePicker:
            [self didSelectTypePickerCell:indexPath.section];
            break;
        case TBHookRowValueHolder:
            [self didSelectValueHolderCell];
            break;

        default:
            @throw NSInternalInconsistencyException;
    }
}

#pragma mark Internal

- (TBSwitchCell *)toggleForParameterAtIndexPath:(NSIndexPath *)indexPath {
    TBSwitchCell *cell = [self.delegate.tableView dequeue:TBSwitchCell.reuseID forIndexPath:indexPath];

    cell.textLabel.text = @"Override";
    cell.switchToggleAction = nil;

    return cell;
}

#pragma mark Private

- (TBDetailDisclosureCell *)valueTypePickerCellForIndexPath:(NSIndexPath *)ip {
    TBDetailDisclosureCell *cell = [self.delegate.tableView dequeue:TBDetailDisclosureCell.reuseID forIndexPath:ip];
    cell.detailTextLabel.text = TBStringFromValueType(self.hookedValue.type);
    cell.textLabel.text = @"Value Kind";

    if (TBCanChangeType(self.typeEncoding[0])) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (TBTableViewCell *)valueCellForIndexPath:(NSIndexPath *)ip {
    TBValue *value        = self.hookedValue;
    NSString *reuse       = [TBTableViewCell reuseIdentifierForValueType:value.type];
    TBTableViewCell *cell = (id)[self.delegate.tableView dequeue:reuse forIndexPath:ip];

    if ([cell isKindOfClass:[TBBaseValueCell class]]) {
        TBBaseValueCell *celll = (id)cell;
        celll.delegate = self;
        [celll describeValue:value];
    }

    return cell;
}

- (void)didSelectTypePickerCell:(NSUInteger)section {
    TBTypePickerViewController *vvc = [TBTypePickerViewController withCompletion:^(TBValueType newType) {
        self.valueType = newType;
        self.hookedValue = [TBValue defaultForValueType:newType];
        [self.delegate.tableView reloadSection:section];
    } title:self.typePickerTitle type:self.typeEncoding[0] current:self.hookedValue.type];

    [self.delegate.navigationController pushViewController:vvc animated:YES];
}

- (void)didSelectValueHolderCell {
    // TODO switch on value type and present an editor
    // throw exception if type doesn't need a presentor
}

#pragma mark TBValueCellDelegate

- (void)textViewDidChange:(UITextView *)textView cell:(UITableViewCell *)cell {
    // Delegate to our own delegate
    [self.delegate textViewDidChange:textView cell:cell];
}

- (NSDate *)date {
    if (self.hookedValue.type == TBValueTypeDate) {
        return (id)self.hookedValue.value;
    }

    return nil;
}

- (void)setDate:(NSDate *)newValue {
    _hookedValue = [TBValue value:newValue type:TBValueTypeDate];
}

- (NSString *)string {
    if (self.hookedValue.type == TBValueTypeString) {
        return (id)self.hookedValue.value;
    }

    return nil;
}

- (void)setString:(NSString *)newValue {
    _hookedValue = [TBValue value:newValue type:TBValueTypeString];
}

- (NSNumber *)number {
    TBValueType type = self.hookedValue.type;
    if (type == TBValueTypeInteger ||
        type == TBValueTypeFloat ||
        type == TBValueTypeDouble) {
        return (id)self.hookedValue.value;
    }

    return nil;
}

- (void)setNumber:(NSNumber *)number {
    switch (self.valueType) {
        case TBValueTypeInteger:
            self.integer = number;
            break;
        case TBValueTypeFloat:
            self.singleFloat = number;
            break;
        case TBValueTypeDouble:
            self.doubleFloat = number;
            break;
            
        default:
            @throw NSInternalInconsistencyException;
    }
}

- (NSNumber *)integer {
    if (self.hookedValue.type == TBValueTypeInteger) {
        return (id)self.hookedValue.value;
    }

    return nil;
}

- (void)setInteger:(NSNumber *)newValue {
    _hookedValue = [TBValue value:newValue type:TBValueTypeInteger];
}

- (NSNumber *)singleFloat {
    if (self.hookedValue.type == TBValueTypeFloat) {
        return (id)self.hookedValue.value;
    }

    return nil;
}

- (void)setSingleFloat:(NSNumber *)newValue {
    _hookedValue = [TBValue value:newValue type:TBValueTypeFloat];
}

- (NSNumber *)doubleFloat {
    if (self.hookedValue.type == TBValueTypeDouble) {
        return (id)self.hookedValue.value;
    }

    return nil;
}

- (void)setDoublefloat:(NSNumber *)newValue {
    _hookedValue = [TBValue value:newValue type:TBValueTypeDouble];
}

- (NSString *)chirpString {
    if (self.hookedValue.type == TBValueTypeChirpValue) {
        return (id)self.hookedValue.value;
    }

    return nil;
}

- (void)setChirpString:(NSString *)newValue {
    _hookedValue = [TBValue value:newValue type:TBValueTypeChirpValue];
}

@end
