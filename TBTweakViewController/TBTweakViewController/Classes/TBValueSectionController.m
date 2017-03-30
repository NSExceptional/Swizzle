//
//  TBValueSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueSectionController.h"
#import "TBValue+ValueHelpers.h"
#import "TBSwitchCell.h"
#import "TBTypePickerViewController.h"
#import "Categories.h"


#define dequeue dequeueReusableCellWithIdentifier
#define format(...) [NSString stringWithFormat:__VA_ARGS__]

@interface TBValueSectionController ()
@property (nonatomic) TBValue *container;
@end

@implementation TBValueSectionController
@dynamic delegate, typePickerTitle;

+ (instancetype)delegate:(id<TBValueSectionDelegate>)delegate type:(const char *)typeEncoding {
    TBValueSectionController *controller = [super delegate:delegate];
    controller.valueType                 = TBValueTypeFromTypeEncoding(controller->_typeEncoding);
    controller->_typeEncoding            = typeEncoding;
    controller->_container               = [TBValue defaultValueForTypeEncoding:controller->_typeEncoding];
    return controller;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    @throw NSGenericException;
}

#pragma mark Public

- (BOOL)shouldHighlightRow:(TBValueRow)row {
    switch (row) {
        case TBValueRowTypePicker:
            return TBCanChangeType(self.typeEncoding[0]);
            switch (self.container.type) {
        case TBValueRowValueHolder:
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
        case TBValueRowTypePicker:
            return [self valueTypePickerCellForIndexPath:indexPath];
            break;
        case TBValueRowValueHolder:
            return [self valueCellForIndexPath:indexPath];
            break;
    }

    @throw NSGenericException;
    return nil;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case TBValueRowTypePicker:
            [self didSelectTypePickerCell:indexPath.section];
            break;
        case TBValueRowValueHolder:
            [self didSelectValueHolderCell];
            break;

        default:
            @throw NSInternalInconsistencyException;
    }
}

#pragma mark Private

- (TBDetailDisclosureCell *)valueTypePickerCellForIndexPath:(NSIndexPath *)ip {
    TBDetailDisclosureCell *cell = [self.delegate.tableView dequeue:TBDetailDisclosureCell.reuseID forIndexPath:ip];
    cell.detailTextLabel.text = TBStringFromValueType(self.container.type);
    cell.textLabel.text = @"Value Kind";

    if (TBCanChangeType(self.typeEncoding[0])) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (TBTableViewCell *)valueCellForIndexPath:(NSIndexPath *)ip {
    TBValue *value        = self.container;
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
        self.container = [TBValue defaultForValueType:newType];
        [self.delegate.tableView reloadSection:section];
    } title:self.typePickerTitle type:self.typeEncoding[0] current:self.container.type];

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
    if (self.container.type == TBValueTypeDate) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setDate:(NSDate *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeDate];
}

- (UIColor *)color {
    if (self.container.type == TBValueTypeColor) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setColor:(UIColor *)color {
    _container = [TBValue value:color type:TBValueTypeColor];
}

- (NSString *)string {
    if (self.container.type == TBValueTypeString) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setString:(NSString *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeString];
}

- (NSNumber *)number {
    TBValueType type = self.container.type;
    if (type == TBValueTypeInteger ||
        type == TBValueTypeFloat ||
        type == TBValueTypeDouble) {
        return (id)self.container.value;
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
    if (self.container.type == TBValueTypeInteger) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setInteger:(NSNumber *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeInteger];
}

- (NSNumber *)singleFloat {
    if (self.container.type == TBValueTypeFloat) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setSingleFloat:(NSNumber *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeFloat];
}

- (NSNumber *)doubleFloat {
    if (self.container.type == TBValueTypeDouble) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setDoublefloat:(NSNumber *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeDouble];
}

- (NSString *)chirpString {
    if (self.container.type == TBValueTypeChirpValue) {
        return (id)self.container.value;
    }

    return nil;
}

- (void)setChirpString:(NSString *)newValue {
    _container = [TBValue value:newValue type:TBValueTypeChirpValue];
}

@end
