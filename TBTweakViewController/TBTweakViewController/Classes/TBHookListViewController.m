//
//  TBHookListViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 4/2/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBHookListViewController.h"
#import "Categories.h"
#import "TBDetailDisclosureCell.h"
#import "TBConfigureHookViewController.h"
#import "TBKeyPathViewController.h"
#import "TBTweakManager.h"
#import "TBTweakHookCell.h"


@interface TBHookListViewController ()
@property (nonatomic, readonly) TBTweak *tweak;
@property (nonatomic, readonly) BOOL isLocal;
@end

@implementation TBHookListViewController

+ (instancetype)listForTweak:(TBTweak *)tweak isLocal:(BOOL)local {
    TBHookListViewController *controller = [self title:tweak.title configuration:^(UINavigationItem *item, id vc) {
        item.rightBarButtonItem = [UIBarButtonItem item:UIBBItemAdd target:vc action:@selector(addHook)];
    }];
    controller->_tweak   = tweak;
    controller->_isLocal = local;
    return controller;
}

- (id)init {
    return [super initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style {
    @throw NSInternalInconsistencyException; return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerCell:TBTweakHookCell.class];
}

- (void)addHook {
    [self.navigationController presentViewController:[TBKeyPathViewController forTweak:self.tweak callback:^{
        [self.tableView reloadData];
        [self synchronize];
    }].inNavController animated:YES completion:nil];
}

- (void)synchronize {
    if (self.isLocal) {
        [[TBTweakManager sharedManager] saveAppTweaks];
    } else {
        [[TBTweakManager sharedManager] saveSystemTweaks];
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTweakHookCell *cell = [TBTweakHookCell dequeue:tableView indexPath:indexPath];
    TBMethodHook *hook    = self.tweak.hooks[indexPath.row];
    cell.textLabel.text   = hook.method.fullName;
    cell.hookType         = hook.type;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweak.hooks.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)action
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(action == UITableViewCellEditingStyleDelete);

    [self.tweak removeHook:self.tweak.hooks[indexPath.row]];
    [self synchronize];
    [self.tableView deleteRow:indexPath];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMethodHook *hook = self.tweak.hooks[indexPath.row];

    [self.navigationController presentViewController:[TBConfigureHookViewController forHook:hook saveAction:^{
        [self synchronize];
    }].inNavController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

@end
