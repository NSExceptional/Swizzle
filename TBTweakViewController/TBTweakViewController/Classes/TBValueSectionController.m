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

@implementation TBValueSectionController
@dynamic delegate, typePickerTitle;

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate type:(const char *)typeEncoding {
    TBValueType type = TBValueTypeFromTypeEncoding(typeEncoding);

    TBValueSectionController *controller = [super delegate:delegate];
    controller->_coordinator             = [TBValueCoordinator coordinateType:type];
    controller->_typeEncoding            = typeEncoding;
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
        case TBValueRowValueHolder:
            switch (self.coordinator.container.type) {
                #warning TODO types all need external editor, make function
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
    cell.detailTextLabel.text = TBStringFromValueType(self.coordinator.container.type);
    cell.textLabel.text = @"Value Kind";

    if (TBCanChangeType(self.typeEncoding[0])) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (TBTableViewCell *)valueCellForIndexPath:(NSIndexPath *)ip {
    TBValue *value        = self.coordinator.container;
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
    #warning TODO this can be cleaned up to use a delegate of some sort
    TBTypePickerViewController *vvc = [TBTypePickerViewController withCompletion:^(TBValueType newType) {
        self.coordinator.valueType = newType;
        self.coordinator.container = [TBValue defaultForValueType:newType];
        [self.delegate.tableView reloadSection:section];
    } title:self.typePickerTitle type:self.typeEncoding[0] current:self.coordinator.container.type];

    [self.delegate.navigationController pushViewController:vvc animated:YES];
}

- (void)didSelectValueHolderCell {
    // TODO switch on value type and present an editor
    // throw exception if type doesn't need a presentor
}

#pragma mark TBValueCellDelegate

- (UITableView *)tableView {
    return self.delegate.tableView;
}

@end
