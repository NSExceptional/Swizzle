//
//  TBConfigureHookViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureHookViewController.h"
#import "TBConfigureHookViewController+Protocols.h"
#import "TBTypePickerViewController.h"
#import "TBValueCells.h"
#import "TBInfoView.h"

#import "SectionControllers.h"
#import "Categories.h"
#import <Masonry.h>


@interface TBConfigureHookViewController ()
@property (nonatomic, readonly) TBInfoView *infoView;
@end

@implementation TBConfigureHookViewController

#pragma mark Setup / initialization

+ (instancetype)forHook:(TBMethodHook *)hook saveAction:(void(^)())saveAction {
    TBConfigureHookViewController *config =
    [self title:@"Configure Tweak" configuration:^(UINavigationItem *item, id vc) {
        id nav = [vc navigationController];
        item.leftBarButtonItem  = [UIBarButtonItem item:UIBBItemCancel target:nav action:@selector(dismissAnimated)];
        item.rightBarButtonItem = [UIBarButtonItem item:UIBBItemSave target:vc action:@selector(save)];
        item.rightBarButtonItem.enabled = NO;
    }];

    config->_saveAction = saveAction;

    // Section controllers
    config->_hookTypeSectionController = [TBHookTypeSectionController delegate:config];
    config->_dynamicSectionControllers = [NSMutableArray arrayWithObject:config->_hookTypeSectionController];

    // Initialize model and sections
    config.hook = hook;
    [config initializeSectionControllers];

    return config;
}

- (id)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    @throw NSInternalInconsistencyException; return [super initWithStyle:style];
}

- (void)loadView {
    [super loadView];

    // Hide cancel if not being presented by itself
    if (self.navigationController.viewControllers.firstObject != self) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    // Header view
    _infoView = [TBInfoView text:self.hook.about];
    _infoView.hairline.hidden = YES;
    self.tableView.fuckingHeaderView = _infoView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register cells, row height
    [self configureTableViewForCellReuseAndAutomaticRowHeight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark Private

- (void)setHook:(TBMethodHook *)hook {
    _hook = hook;
    _hookType = hook.type;

    switch (_hookType) {
        case TBHookTypeUnspecified: {
            break;
        }
        case TBHookTypeChirpCode: {
            self.chirpString = hook.chirpString;
            break;
        }
        case TBHookTypeReturnValue: {
            self.hookedReturnValue = hook.hookedReturnValue;
            break;
        }
        case TBHookTypeArguments: {
            self.hookedArguments = hook.hookedArguments.mutableCopy;
            break;
        }
    }
}

- (void)save {
    // Finalize hook //

    self.hook.chirpString       = nil;
    self.hook.hookedArguments   = nil;
    self.hook.hookedReturnValue = nil;

    switch (self.hookType) {
        case TBHookTypeUnspecified: {
            break;
        }
        case TBHookTypeChirpCode: {
            self.hook.chirpString = self.chirpString;
            break;
        }
        default: {
            if (self.hookType & TBHookTypeReturnValue) {
                self.hook.hookedReturnValue = self.hookedReturnValue;
            }
            if (self.hookType & TBHookTypeArguments) {
                self.hook.hookedArguments = self.hookedArguments;
            }
        }
    }
    
    // Then save
    self.saveAction();
    [self.navigationController dismissAnimated];
}

- (void)setHookType:(TBHookType)hookType {
    if (_hookType == hookType) return;
    _hookType = hookType;
    
    // Make sure save button should be enabled
    self.navigationItem.rightBarButtonItem.enabled = hookType != TBHookTypeUnspecified;
    // Lazily initialize chirp string or hook values as necessary
    [self initializeHookType:hookType];
}

- (void)initializeHookType:(TBHookType)hookType {
    switch (hookType) {
        case TBHookTypeUnspecified: {
            break;
        }
        case TBHookTypeChirpCode: {
            if (!self.chirpString) {
                self.chirpString = @"";
            }
            break;
        }
        default: {
            if (hookType & TBHookTypeReturnValue) {
                if (!self.hookedReturnValue) {
                    self.hookedReturnValue = [TBValue orig];
                }
            }
            if (hookType & TBHookTypeArguments) {
                // Set up unmodified arguments
                if (!self.hookedArguments.count) {
                    NSUInteger count = self.hook.method.numberOfArguments;
                    self.hookedArguments = [NSArray of:[TBValue orig] count:count].mutableCopy;
                }
            }
        }
    }
}

- (TBReturnValueHookSectionController *)returnValueHookSectionController {
    if (!(self.hookType & TBHookTypeReturnValue)) return nil;

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (TBSectionController *section in self.dynamicSectionControllers) {
        [section.currentResponder resignFirstResponder];
    }
}

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
