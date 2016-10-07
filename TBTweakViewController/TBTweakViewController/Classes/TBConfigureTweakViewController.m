//
//  TBConfigureTweakViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureTweakViewController.h"
#import "TBConfigureTweakViewController+UITableViewDataSource.h"
#import "TBValueViewController.h"
#import "TBValueCells.h"

#define dequeue dequeueReusableCellWithIdentifier


@interface TBConfigureTweakViewController ()

@end

@implementation TBConfigureTweakViewController

+ (instancetype)forTweak:(TBTweak *)tweak saveAction:(void(^)())saveAction {
    TBConfigureTweakViewController *config = [self new];
    config->_tweak = tweak;
    config->_saveAction = saveAction;
    return config;
}

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Configure Tweak";
    
    // Save button
    id save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = save;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self configureTableViewForCellReuseAndAutomaticRowHeight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)save {
    // Finalize hook
    {
        self.tweak.hook.hookedArguments   = nil;
        self.tweak.hook.hookedReturnValue = nil;
        self.tweak.hook.chirpString       = nil;
        
        switch (self.tweakType) {
            case TBTweakTypeUnspecified: {
                break;
            }
            case TBTweakTypeChirpCode: {
                self.tweak.hook.chirpString = self.chirpString;
                break;
            }
            default: {
                if (self.tweakType & TBTweakTypeHookReturnValue) {
                    self.tweak.hook.hookedReturnValue = self.hookedReturnValue;
                }
                if (self.tweakType & TBTweakTypeHookArguments) {
                    self.tweak.hook.hookedArguments = self.hookedArguments;
                }
            }
        }
    }
    
    self.saveAction();
}

- (BOOL)expertMode {
    return NO;
}

- (void)setTweakType:(TBTweakType)tweakType {
    if (_tweakType == tweakType) return;
    _tweakType = tweakType;
    
    // Make sure save button should be enabled
    self.navigationItem.rightBarButtonItem.enabled = tweakType != TBTweakTypeUnspecified;
    [self initializeTweakType:tweakType];
}

- (void)initializeTweakType:(TBTweakType)tweakType {
    switch (tweakType) {
        case TBTweakTypeUnspecified: {
            break;
        }
        case TBTweakTypeChirpCode: {
            if (!self.chirpString) {
                self.chirpString = @"";
            }
            break;
        }
        default: {
            if (tweakType & TBTweakTypeHookReturnValue) {
                if (!self.hookedReturnValue) {
                    self.hookedReturnValue = [TBValue orig];
                }
            }
            if (tweakType & TBTweakTypeHookArguments) {
                // Set up unmodified arguments
                if (!self.hookedArguments.count) {
                    self.hookedArguments = [NSMutableArray array];
                    for (int i = 0; i < self.tweak.hook.method.numberOfArguments; i++) {
                        [self.hookedArguments addObject:[TBValue orig]];
                    }
                }
            }
        }
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return [self tweakOptionsSwitchCellForRow:indexPath.row];
        }
        case 1: {
            switch (self.tweakType) {
                case TBTweakTypeUnspecified: {
                    return nil;
                }
                case TBTweakTypeChirpCode: {
                    return [self.tableView dequeue:kChirpCellReuse forIndexPath:indexPath];
                }
                default: {
                    // If we have return hook on, it will be this section
                    if (self.tweakType & TBTweakTypeHookReturnValue) {
                        TBValue *hookValue    = self.hookedReturnValue;
                        UITableViewCell *cell = [self.tableView dequeue:kValueCellReuse forIndexPath:indexPath];
                        cell.textLabel.text   = hookValue.description;
                        cell.accessoryType    = UITableViewCellAccessoryDisclosureIndicator;
                        
                        return cell;
                    }
                    
                }
                case TBTweakTypeHookArguments: {
                    TBValue *hookValue    = self.hookedArguments[indexPath.row];
                    UITableViewCell *cell = [self.tableView dequeue:kValueCellReuse forIndexPath:indexPath];
                    cell.textLabel.text   = hookValue.description;
                    cell.accessoryType    = UITableViewCellAccessoryDisclosureIndicator;
                    
                    return cell;
                }
            }
        }
        default: {
            // Argument cells
            if (self.tweakType & TBTweakTypeHookArguments) {
                TBValue *hookValue    = self.hookedArguments[indexPath.row];
                UITableViewCell *cell = [self.tableView dequeue:kValueCellReuse forIndexPath:indexPath];
                cell.textLabel.text   = hookValue.description;
                cell.accessoryType    = UITableViewCellAccessoryDisclosureIndicator;
                
                return cell;
            } else {
                [NSException raise:NSInternalInconsistencyException format:@"What is going on"];
            }
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            NSInteger rows = 1;
            rows += self.tweak.hook.canOverrideReturnValue;
            rows += self.tweak.hook.canOverrideAllArgumentValues;
            return rows;
        }
        case 1: {
            switch (self.tweakType) {
                case TBTweakTypeUnspecified: {
                    return 0;
                }
                case TBTweakTypeChirpCode: {
                    return 1;
                }
                case TBTweakTypeHookReturnValue: {
                    return 1;
                }
                case TBTweakTypeHookArguments: {
                    return self.hookedArguments.count;
                }
            }
        }
    };
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tweakType == 0 ? 1 : 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return @"Tweak type";
        }
        case 1: {
            switch (self.tweakType) {
                case TBTweakTypeChirpCode: {
                    return @"Tweak format string";
                }
                case TBTweakTypeHookReturnValue: {
                    return @"Return value";
                }
                case TBTweakTypeHookArguments: {
                    return @"Argument values";
                }
                case TBTweakTypeUnspecified: {
                    return nil;
                }
            }
        }
    }
    
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            // Select or unselect proper row,
            // update second section
            if (self.tweakType-1 == indexPath.row) {
                self.tweakType = TBTweakTypeUnspecified;
            } else {
                // +1 because we don't have an "unspecified" cell
                self.tweakType = indexPath.row+1;
            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        case 1: {
            switch (self.tweakType) {
                case TBTweakTypeUnspecified:
                case TBTweakTypeChirpCode: {
                    break;
                }
                case TBTweakTypeHookReturnValue: {
                    [self editReturnValueHook];
                    break;
                }
                case TBTweakTypeHookArguments: {
                    [self editArgumentValueHookAtIndex:indexPath.row];
                    break;
                }
            }
        }
    };
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return YES;
        }
        case 1: {
            switch (self.tweakType) {
                case TBTweakTypeUnspecified:
                case TBTweakTypeChirpCode: {
                    return NO;
                }
                case TBTweakTypeHookReturnValue:
                case TBTweakTypeHookArguments: {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && self.tweakType == TBTweakTypeChirpCode) {
        return 150.f;
    }
    
    return 44.f;
}

#pragma mark Model

- (void)editReturnValueHook {
    NSString *title                  = @"Edit Return Value";
    TBValue *initial                 = self.hookedReturnValue;
    MKTypeEncoding valueTypeEncoding = self.tweak.hook.method.returnType;
    
    TBValueViewController *vvc = [TBValueViewController withSaveAction:^(TBValue *value) {
        NSParameterAssert(value);
        self.hookedReturnValue = value;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } title:title initialValue:initial isPartOfOverride:YES type:valueTypeEncoding];
    
    [self.navigationController pushViewController:vvc animated:YES];
}

- (void)editArgumentValueHookAtIndex:(NSInteger)idx {
    NSString *title                  = @"Edit Argument Value";
    TBValue *initial                 = self.hookedArguments[idx];
    MKTypeEncoding valueTypeEncoding = [self.tweak.hook.method.signature getArgumentTypeAtIndex:idx][0];
    
    TBValueViewController *vvc = [TBValueViewController withSaveAction:^(TBValue *value) {
        NSParameterAssert(value);
        self.hookedArguments[idx] = value;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } title:title initialValue:initial isPartOfOverride:YES type:valueTypeEncoding];
    
    [self.navigationController pushViewController:vvc animated:YES];
}

#pragma mark TBTextViewCellResizing

- (void)textViewDidChange:(UITextView *)textView cell:(UITableViewCell *)cell {
    CGSize size = textView.bounds.size;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
    
    // Update cell size only when cell's size is changed
    if (size.height != newSize.height) {
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        NSIndexPath *ip = [self.tableView indexPathForCell:cell];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
