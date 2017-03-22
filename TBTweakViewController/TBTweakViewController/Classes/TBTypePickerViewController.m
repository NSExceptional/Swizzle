//
//  TBTypePickerViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTypePickerViewController.h"
#import "TBTypePickerViewControllerDataSource.h"
#import "TBConfigureTweakViewController+Protocols.h"
#import "TBValueCells.h"
#import "UITableView+Convenience.h"
#import "EnumSet.h"

#define dequeue dequeueReusableCellWithIdentifier


@interface TBTypePickerViewController ()
@property (nonatomic, copy) void (^completion)(TBValueType newType);

@property (nonatomic, readonly) NSMutableArray<NSString*> *allowedValueTypeNames;
@property (nonatomic, readonly) EnumSet *allowedTypes;

@property (nonatomic          ) NSUInteger selectedRow;
@property (nonatomic          ) TBValueType type;
@end

@implementation TBTypePickerViewController

+ (instancetype)withCompletion:(void(^)(TBValueType newType))completion
                         title:(NSString *)title
                          type:(MKTypeEncoding)type {
    
    TBTypePickerViewController *valuevc = [self new];
    valuevc.completion = completion;
    valuevc.title      = title;

    valuevc.tableView.rowHeight = UITableViewAutomaticDimension;
    [valuevc.tableView registerCell:[TBTableViewCell class]];
    return valuevc;
}

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)done {
    self.completion(self.type);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)computeAllowedValueTypes:(MKTypeEncoding)encoding currentType:(TBValueType)current {
    _allowedTypes = TBAllowedTypesForEncoding(encoding);
    _allowedValueTypeNames = [NSMutableArray array];

    for (NSUInteger i = 0; i < _allowedTypes.count; i++) {
        TBValueType type = _allowedTypes[i].integerValue;
        // We will never show the type picker for structs so struct names don't matter
        [self.allowedValueTypeNames addObject:TBStringFromValueOrStructType(type, TBStructTypeNotStruct)];

        if (type == current) {
            self.selectedRow = i;
        }
    }
}

- (void)setSelectedRow:(NSUInteger)selectedRow {
    if (_selectedRow == selectedRow) return;

    // Uncheck old row
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
    UITableViewCell *selected = [self.tableView cellForRowAtIndexPath:ip];
    selected.accessoryType = UITableViewCellAccessoryNone;
    // Check new row
    ip = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    selected = [self.tableView cellForRowAtIndexPath:ip];
    selected.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTableViewCell *cell = [tableView dequeue:TBTableViewCell.reuseID forIndexPath:indexPath];
    cell.textLabel.text = self.allowedValueTypeNames[indexPath.row];

    if (self.type == self.allowedTypes[indexPath.row].integerValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allowedTypes.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didChangeValueTypeBySelectingRow:indexPath inTableView:tableView];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)didChangeValueTypeBySelectingRow:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TBValueType oldtype = self.type;
    TBValueType newType = self.allowedTypes[indexPath.row].integerValue;

    if (oldtype == newType) return;

    self.type = newType;
    self.selectedRow = indexPath.row;

    // Pop back to where we were
    tableView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self done];
    });
}

@end
