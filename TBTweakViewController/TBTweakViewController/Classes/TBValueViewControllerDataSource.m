//
//  TBValueViewControllerDataSource.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueViewControllerDataSource.h"
#import "TBValueViewController.h"
#import "TBValueCells.h"

#define dequeue dequeueReusableCellWithIdentifier

@interface TBValueViewControllerDataSource () <TBValueCellDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) TBValueViewController *viewController;
@property (nonatomic, readonly) NSMutableArray<NSString*> *allowedValueTypeNames;
@property (nonatomic, readonly) NSMutableArray<NSNumber*> *allowedValueTypes;

@property (nonatomic) NSMutableArray<TBValue*> *collectionValues;
@property (nonatomic) NSMutableArray<TBValue*> *collectionKeys;

@property (nonatomic) TBValueType valueType;
@end

@implementation TBValueViewControllerDataSource

+ (instancetype)dataSourceForViewController:(TBValueViewController *)vc valueType:(MKTypeEncoding)type {
    return [[self alloc] initWithViewController:vc valueType:type];
}

- (id)initWithViewController:(TBValueViewController *)vc valueType:(MKTypeEncoding)type {
    self = [super init];
    if (self) {
        self.viewController = vc;
        [self computeAllowedValueTypes:type];
    }
    
    return self;
}

- (void)setViewController:(TBValueViewController *)viewController {
    _viewController = viewController;
    viewController.tableView.delegate   = self;
    viewController.tableView.dataSource = self;
}

- (void)computeAllowedValueTypes:(MKTypeEncoding)type {
    _allowedValueTypes = [NSMutableArray array];
    _allowedValueTypeNames = [NSMutableArray array];
    
    [self.allowedValueTypes addObject:@(TBValueTypeUnmodified)];
    [self.allowedValueTypes addObject:@(TBValueTypeChirpValue)];
    
    switch (type) {
        case MKTypeEncodingUnknown: {
            break;
        }
        case MKTypeEncodingChar:
        case MKTypeEncodingInt:
        case MKTypeEncodingShort:
        case MKTypeEncodingLong:
        case MKTypeEncodingLongLong:
        case MKTypeEncodingUnsignedChar:
        case MKTypeEncodingUnsignedInt:
        case MKTypeEncodingUnsignedShort:
        case MKTypeEncodingUnsignedLong:
        case MKTypeEncodingUnsignedLongLong:
        case MKTypeEncodingFloat:
        case MKTypeEncodingDouble:
        case MKTypeEncodingCBool: {
            [self.allowedValueTypes addObject:@(TBValueTypeNumber)];
            break;
        }
        case MKTypeEncodingVoid: {
            break;
        }
        case MKTypeEncodingSelector:
        case MKTypeEncodingCString: {
            [self.allowedValueTypes addObject:@(TBValueTypeNilValue)];
            [self.allowedValueTypes addObject:@(TBValueTypeString)];
            break;
        }
        case MKTypeEncodingObjcObject: {
            [self.allowedValueTypes addObject:@(TBValueTypeNilValue)];
            [self.allowedValueTypes addObject:@(TBValueTypeChirpValue)];
            [self.allowedValueTypes addObject:@(TBValueTypeClass)];
            [self.allowedValueTypes addObject:@(TBValueTypeDate)];
            [self.allowedValueTypes addObject:@(TBValueTypeNumber)];
            [self.allowedValueTypes addObject:@(TBValueTypeString)];
            [self.allowedValueTypes addObject:@(TBValueTypeArray)];
            [self.allowedValueTypes addObject:@(TBValueTypeDictionary)];
            [self.allowedValueTypes addObject:@(TBValueTypeSet)];
            [self.allowedValueTypes addObject:@(TBValueTypeMutableString)];
            [self.allowedValueTypes addObject:@(TBValueTypeMutableArray)];
            [self.allowedValueTypes addObject:@(TBValueTypeMutableDictionary)];
            [self.allowedValueTypes addObject:@(TBValueTypeMutableSet)];
            break;
        }
        case MKTypeEncodingObjcClass: {
            [self.allowedValueTypes addObject:@(TBValueTypeClass)];
            [self.allowedValueTypes addObject:@(TBValueTypeNilValue)];
            break;
        }
        case MKTypeEncodingArray:
        case MKTypeEncodingStruct:
        case MKTypeEncodingUnion:
        case MKTypeEncodingBitField:
        case MKTypeEncodingPointer: {
            break;
        }
    }
    
    // Names
    for (NSNumber *type in self.allowedValueTypes) {
        [self.allowedValueTypeNames addObject:TBStringFromValueType(type.integerValue)];
    }
}

- (void)trySetInitialValue:(TBValue *)value {
    self.valueType = value.type;
    
    id initial = value.value;
    switch (value.type) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue: {
            break;
        }
        case TBValueTypeChirpValue: {
            break;
        }
        case TBValueTypeClass: {
            self.string = NSStringFromClass(initial);
            break;
        }
        case TBValueTypeSelector: {
            self.string = [NSString stringWithUTF8String:[initial pointerValue]];
            break;
        }
        case TBValueTypeNumber: {
            self.number = initial;
            break;
        }
        case TBValueTypeString:
        case TBValueTypeMutableString: {
            self.string = initial;
            break;
        }
        case TBValueTypeDate: {
            self.date = initial;
            break;
        }
        case TBValueTypeColor: {
            self.color = initial;
            break;
        }
        case TBValueTypeArray:
        case TBValueTypeMutableArray: {
            self.collectionValues = [initial mutableCopy];
            break;
        }
        case TBValueTypeSet:
        case TBValueTypeMutableSet: {
            self.collectionValues = [initial allObjects].mutableCopy;
            break;
        }
        case TBValueTypeDictionary:
        case TBValueTypeMutableDictionary: {
            self.collectionKeys = [initial allKeys].mutableCopy;
            self.collectionValues = [initial allValues].mutableCopy;
            break;
        }
    }
}

- (void)getValueIfEditing {
    [self.currentResponder resignFirstResponder];
}

- (TBValue *)value {
    switch (self.valueType) {
        case TBValueTypeUnmodified: {
            return [TBValue orig];
        }
        case TBValueTypeNilValue: {
            return [TBValue null];
        }
        case TBValueTypeChirpValue: {
            return nil;
        }
        case TBValueTypeClass: {
            return [TBValue value:NSClassFromString(self.string) type:self.valueType];
        }
        case TBValueTypeSelector: {
            return [TBValue value:[NSValue valueWithPointer:self.string.UTF8String] type:self.valueType];
        }
        case TBValueTypeNumber: {
            return [TBValue value:self.number type:self.valueType];
        }
        case TBValueTypeString: {
            return [TBValue value:self.string type:self.valueType];
        }
        case TBValueTypeMutableString: {
            return [TBValue value:self.string.mutableCopy type:self.valueType];
        }
        case TBValueTypeDate: {
            return [TBValue value:self.date type:self.valueType];
        }
        case TBValueTypeColor: {
            return [TBValue value:self.color type:self.valueType];
        }
        case TBValueTypeArray: {
            return [TBValue value:self.collectionValues.copy type:self.valueType];
        }
        case TBValueTypeSet: {
            return [TBValue value:[NSSet setWithArray:self.collectionValues] type:self.valueType];
        }
        case TBValueTypeMutableArray: {
            return [TBValue value:self.collectionValues.mutableCopy type:self.valueType];
        }
        case TBValueTypeMutableSet: {
            return [TBValue value:[NSMutableSet setWithArray:self.collectionValues] type:self.valueType];
        }
        case TBValueTypeDictionary: {
            id dict = [NSDictionary dictionaryWithObjects:self.collectionValues forKeys:self.collectionKeys];
            return [TBValue value:dict type:self.valueType];
        }
        case TBValueTypeMutableDictionary: {
            id dict = [NSMutableDictionary dictionaryWithObjects:self.collectionValues forKeys:self.collectionKeys];
            return [TBValue value:dict type:self.valueType];
        }
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeue:kTypeCellReuse forIndexPath:indexPath];
            cell.textLabel.text = self.allowedValueTypeNames[indexPath.row];
            
            if (self.valueType == self.allowedValueTypes[indexPath.row].integerValue) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return cell;
        }
        case 1: {
            switch (self.valueType) {
                case TBValueTypeUnmodified:
                case TBValueTypeNilValue: {
                    return nil;
                }
                case TBValueTypeChirpValue: {
                    TBChirpCell *cell = [tableView dequeue:kChirpCellReuse forIndexPath:indexPath];
                    cell.delegate = self;
                    cell.text = self.chirpString;
                    return cell;
                }
                case TBValueTypeNumber: {
                    TBNumberCell *cell = [tableView dequeue:kNumberCellReuse forIndexPath:indexPath];
                    cell.delegate = self;
                    cell.text = self.number.description;
                    return cell;
                }
                case TBValueTypeClass:
                case TBValueTypeSelector:
                case TBValueTypeString:
                case TBValueTypeMutableString: {
                    TBStringCell *cell = [tableView dequeue:kStringClassSELCellReuse forIndexPath:indexPath];
                    cell.delegate = self;
                    cell.text = self.string;
                    return cell;
                }
                case TBValueTypeDate: {
                    TBDateCell *cell = [tableView dequeue:kDateCellReuse forIndexPath:indexPath];
                    cell.delegate = self;
                    cell.date = self.date;
                    return cell;
                }
                case TBValueTypeColor: {
                    // TODO color
                }
                case TBValueTypeDictionary:
                case TBValueTypeMutableDictionary: {
                    if (indexPath.row == self.collectionKeys.count) {
                        return [tableView dequeue:kAddValueCellReuse forIndexPath:indexPath];
                    }
                    UITableViewCell *cell = [tableView dequeue:kValueCellReuse forIndexPath:indexPath];
                    cell.textLabel.text   = self.collectionKeys[indexPath.row].description;
                    cell.accessoryType    = UITableViewCellAccessoryCheckmark;
                    return cell;
                }
                case TBValueTypeArray:
                case TBValueTypeSet:
                case TBValueTypeMutableArray:
                case TBValueTypeMutableSet: {
                    if (indexPath.row == self.collectionValues.count) {
                        return [tableView dequeue:kAddValueCellReuse forIndexPath:indexPath];
                    }
                    UITableViewCell *cell = [tableView dequeue:kValueCellReuse forIndexPath:indexPath];
                    cell.textLabel.text   = self.collectionValues[indexPath.row].description;
                    cell.accessoryType    = UITableViewCellAccessoryCheckmark;
                    return cell;
                }
            }
        }
        case 2: {
            if (indexPath.row == self.collectionValues.count) {
                return [tableView dequeue:kAddValueCellReuse forIndexPath:indexPath];
            }
            UITableViewCell *cell = [tableView dequeue:kValueCellReuse forIndexPath:indexPath];
            cell.textLabel.text   = self.collectionValues[indexPath.row].description;
            cell.accessoryType    = UITableViewCellAccessoryCheckmark;
            return cell;
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return self.allowedValueTypes.count;
        }
        case 1: {
            switch (self.valueType) {
                case TBValueTypeUnmodified:
                case TBValueTypeNilValue: {
                    return 0;
                }
                case TBValueTypeChirpValue:
                case TBValueTypeClass:
                case TBValueTypeSelector:
                case TBValueTypeNumber:
                case TBValueTypeString:
                case TBValueTypeMutableString:
                case TBValueTypeDate:
                case TBValueTypeColor: {
                    return 1;
                }
                case TBValueTypeDictionary:
                case TBValueTypeMutableDictionary: {
                    return self.collectionKeys.count + 1;
                }
                case TBValueTypeArray:
                case TBValueTypeSet:
                case TBValueTypeMutableArray:
                case TBValueTypeMutableSet: {
                    return self.collectionValues.count + 1;
                }
            }
        }
        case 2: {
            return self.collectionValues.count + 1;
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    TBValueType type = self.valueType;
    switch (type) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue:
            return 1;
        case TBValueTypeDictionary:
        case TBValueTypeMutableDictionary:
            return 3;
        default:
            return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return @"Value type";
        }
        case 1: {
            switch (self.valueType) {
                case TBValueTypeUnmodified:
                case TBValueTypeNilValue: {
                    return nil;
                }
                case TBValueTypeChirpValue:
                case TBValueTypeClass:
                case TBValueTypeSelector:
                case TBValueTypeNumber:
                case TBValueTypeString:
                case TBValueTypeMutableString:
                case TBValueTypeDate:
                case TBValueTypeColor: {
                    return @"Value";
                }
                case TBValueTypeDictionary:
                case TBValueTypeMutableDictionary: {
                    return @"Dictionary keys";
                }
                case TBValueTypeArray:
                case TBValueTypeSet:
                case TBValueTypeMutableArray:
                case TBValueTypeMutableSet: {
                    return @"Collection values";
                }
            }
        }
        case 2: {
            return @"Dictionary values";
        }
    }
    
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            [self didChangeValueTypeBySelectingRow:indexPath inTableView:tableView];
            break;
        }
        case 1: {
            // Value type content
            switch (self.valueType) {
                case TBValueTypeUnmodified:
                case TBValueTypeNilValue:
                case TBValueTypeChirpValue:
                case TBValueTypeClass:
                case TBValueTypeSelector:
                case TBValueTypeNumber:
                case TBValueTypeString:
                case TBValueTypeMutableString:
                case TBValueTypeDate:
                case TBValueTypeColor: {
                    // Cannot select these rows
                    break;
                }
                case TBValueTypeDictionary:
                case TBValueTypeMutableDictionary: {
                    // Insert new key or edit existing key
                    if (indexPath.row == self.collectionKeys.count) {
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        [self addNewCollectionKey];
                    } else {
                        [self modifyCollectionKeyAtIndex:indexPath.row];
                    }
                    break;
                }
                case TBValueTypeArray:
                case TBValueTypeSet:
                case TBValueTypeMutableArray:
                case TBValueTypeMutableSet: {
                    // Insert new value or edit existing value
                    if (indexPath.row == self.collectionValues.count) {
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        [self addNewCollectionValue];
                    } else {
                        [self modifyCollectionValueAtIndex:indexPath.row];
                    }
                    break;
                }
            }
            break;
        }
        case 2: {
            // Insert new value or edit existing value
            if (indexPath.row == self.collectionValues.count) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self addNewCollectionValue];
            } else {
                [self modifyCollectionValueAtIndex:indexPath.row];
            }
            break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return YES;
        }
        case 1: {
            switch (self.valueType) {
                case TBValueTypeUnmodified:
                case TBValueTypeNilValue:
                case TBValueTypeChirpValue:
                case TBValueTypeClass:
                case TBValueTypeSelector:
                case TBValueTypeNumber:
                case TBValueTypeString:
                case TBValueTypeMutableString:
                case TBValueTypeDate:
                case TBValueTypeColor: {
                    return NO;
                }
                case TBValueTypeArray:
                case TBValueTypeSet:
                case TBValueTypeMutableArray:
                case TBValueTypeMutableSet:
                case TBValueTypeDictionary:
                case TBValueTypeMutableDictionary: {
                    // Modifying or adding values
                    return YES;
                }
            }
        }
        case 2: {
            // Modifying or adding dictionary values
            return YES;
        }
    }
    
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && self.valueType == TBValueTypeChirpValue) {
        return 150.f;
    }
    
    return 44.f;
}

- (void)didChangeValueTypeBySelectingRow:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TBValueType oldtype = self.valueType;
    TBValueType newType = self.allowedValueTypes[indexPath.row].integerValue;
    
    if (oldtype == newType) return;
    
    NSInteger previouslySelectedRow = ({
        NSInteger i = 0;
        for (NSNumber *value in self.allowedValueTypes) {
            if (value.integerValue == oldtype)
                break;
            i++;
        }
        i;
    });
    self.valueType = newType;
    
    // Initialize tweak values
    switch (self.valueType) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue: {
            break;
        }
        case TBValueTypeClass:
        case TBValueTypeSelector:
        case TBValueTypeString:
        case TBValueTypeMutableString: {
            if (!self.string) {
                self.string = @"";
            }
            break;
        }
        case TBValueTypeNumber: {
            if (!self.number) {
                self.number = @0;
            }
            break;
        }
        case TBValueTypeDate: {
            if (!self.date) {
                self.date = [NSDate date];
            }
            break;
        }
        case TBValueTypeColor: {
            if (!self.color) {
                self.color = [UIColor clearColor];
            }
            break;
        }
        case TBValueTypeArray:
        case TBValueTypeDictionary:
        case TBValueTypeSet:
        case TBValueTypeMutableArray:
        case TBValueTypeMutableSet:
        case TBValueTypeMutableDictionary: {
            if (!self.collectionKeys) {
                self.collectionValues = [NSMutableArray array];
                self.collectionKeys   = [NSMutableArray array];
            }
            break;
        }
        case TBValueTypeChirpValue: {
            if (!self.chirpString) {
                self.chirpString = @"";
            }
            break;
        }
    }
    
    // Uncheck old row
    NSIndexPath *ip = [NSIndexPath indexPathForRow:previouslySelectedRow inSection:0];
    UITableViewCell *selected = [tableView cellForRowAtIndexPath:ip];
    selected.accessoryType = UITableViewCellAccessoryNone;
    // Check new row
    ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    selected = [tableView cellForRowAtIndexPath:ip];
    selected.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // Update table
    NSIndexSet *section = [NSIndexSet indexSetWithIndex:1];
    if (oldtype) {
        if (newType) {
            [tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView deleteSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if (newType) {
        [tableView insertSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark Collection stuff

- (void)addNewCollectionKey {
    NSArray *ips = @[[NSIndexPath indexPathForRow:self.collectionKeys.count inSection:1]];
    [self.collectionKeys addObject:[TBValue null]];
    [self.viewController.tableView insertRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)addNewCollectionValue {
    TBValueType type  = self.valueType;
    NSInteger section = 1;
    // Special case for dictionaries
    if (type == TBValueTypeDictionary || type == TBValueTypeMutableDictionary) {
        section = 2;
    }
    
    NSArray *ips = @[[NSIndexPath indexPathForRow:self.collectionKeys.count-1 inSection:section]];
    [self.collectionValues addObject:[TBValue null]];
    [self.viewController.tableView insertRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)modifyCollectionKeyAtIndex:(NSInteger)idx {
    NSString *title  = @"Edit Key";
    TBValue *initial = self.collectionKeys[idx];
    
    TBValueViewController *vvc = [TBValueViewController withSaveAction:^(TBValue *value) {
        NSParameterAssert(value);
        self.collectionKeys[idx] = value;
        [self.viewController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } title:title initialValue:initial isPartOfOverride:NO type:MKTypeEncodingObjcObject];
    
    [self.viewController.navigationController pushViewController:vvc animated:YES];
}

- (void)modifyCollectionValueAtIndex:(NSInteger)idx {
    NSString *title  = @"Edit Value";
    TBValue *initial = self.collectionValues[idx];
    
    TBValueViewController *vvc = [TBValueViewController withSaveAction:^(TBValue *value) {
        NSParameterAssert(value);
        self.collectionValues[idx] = value;
        [self.viewController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } title:title initialValue:initial isPartOfOverride:NO type:MKTypeEncodingObjcObject];
    
    [self.viewController.navigationController pushViewController:vvc animated:YES];
}

#pragma mark TBValueCellDelegate

- (void)textViewDidChange:(UITextView *)textView cell:(UITableViewCell *)cell {
    CGSize size = textView.bounds.size;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
    
    // Update cell size only when cell's size is changed
    if (size.height != newSize.height) {
        [UIView setAnimationsEnabled:NO];
        [self.viewController.tableView beginUpdates];
        [self.viewController.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        NSIndexPath *ip = [self.viewController.tableView indexPathForCell:cell];
        [self.viewController.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
