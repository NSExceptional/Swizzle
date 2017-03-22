//
//  TBConfigureTweakViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureTweakViewController.h"
#import "TBConfigureTweakViewController+Protocols.h"
#import "TBTypePickerViewController.h"
#import "TBValueCells.h"

#import "SectionControllers.h"
#import "Categories.h"


@implementation TBConfigureTweakViewController

+ (instancetype)forTweak:(TBTweak *)tweak saveAction:(void(^)())saveAction {
    TBConfigureTweakViewController *config =
    [self title:@"Configure Tweak" configuration:^(UINavigationItem *item, id vc) {
        item.rightBarButtonItem = [UIBarButtonItem item:UIBBItemSave target:vc action:@selector(save)];
        item.rightBarButtonItem.enabled = NO;
    }];
    config->_tweak = tweak;
    config->_saveAction = saveAction;
    return config;
}

- (id)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    @throw NSInternalInconsistencyException; return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Section controllers
    _tweakTypeSectionController = [TBTweakTypeSectionController delegate:self];
    _dynamicSectionControllers = [NSMutableArray arrayWithObject:_tweakTypeSectionController];

    // Register cells, row height
    [self configureTableViewForCellReuseAndAutomaticRowHeight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)save {
    // Finalize hook //

    self.tweak.hook.chirpString       = nil;
    self.tweak.hook.hookedArguments   = nil;
    self.tweak.hook.hookedReturnValue = nil;

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
    
    // Then save
    self.saveAction();
}

- (void)setTweakType:(TBTweakType)tweakType {
    if (_tweakType == tweakType) return;
    _tweakType = tweakType;
    
    // Make sure save button should be enabled
    self.navigationItem.rightBarButtonItem.enabled = tweakType != TBTweakTypeUnspecified;
    // Lazily initialize chirp string or hook values as necessary
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
                    NSUInteger count = self.tweak.hook.method.numberOfArguments;
                    self.hookedArguments = [NSArray of:[TBValue orig] count:count].mutableCopy;
                }
            }
        }
    }
}

- (TBReturnValueHookSectionController *)returnValueHookSectionController {
    if (!(self.tweakType & TBTweakTypeHookReturnValue)) return nil;

    Class cls = [TBReturnValueHookSectionController class];
    for (id controller in self.dynamicSectionControllers) {
        if ([controller isKindOfClass:cls]) {
            return controller;
        }
    }

    // Should be unreachable
    @throw NSInternalInconsistencyException;
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.dynamicSectionControllers[indexPath.section] didSelectRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicSectionControllers[indexPath.section] shouldHighlightRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

@end
