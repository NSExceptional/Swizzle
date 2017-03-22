//
//  TBTweakListViewController.m
//  TBTweakListViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweakListViewController.h"
#import "TBBundlePickerViewController.h"
#import "TBConfigureTweakViewController.h"
#import "Categories.h"

#import "TBTweakManager.h"
#import "TBTweakCell.h"
#import "TBTweak.h"


@interface TBTweakListViewController ()
@property (nonatomic, readonly) BOOL loadTweaksAtLaunch;
@property (nonatomic, readonly) BOOL isSystemTab;
@end

@implementation TBTweakListViewController

+ (instancetype)appTweaks {
    TBTweakListViewController *me = [self new];
    me.tabBarItem.image = [UIImage appsTabImage];
    me.tabBarItem.title = @"Local Tweaks";
    return me;
}

+ (instancetype)systemTweaks {
    TBTweakListViewController *me = [self new];
    
    me.tabBarItem.image = [UIImage systemTabImage];
    me.tabBarItem.title = @"System Tweaks";
    me->_isSystemTab = YES;
    return me;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Bar buttons
    UITabBarController *tabBarController = self.navigationController.tabBarController;
    id add = [UIBarButtonItem item:UIBBItemAdd target:self action:@selector(addTweak)];
    id done = [UIBarButtonItem item:UIBBItemDone target:tabBarController action:@selector(dismissAnimated)];

    self.navigationItem.leftBarButtonItem  = done;
    self.navigationItem.rightBarButtonItem = add;
    
    // Table view stuff
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)addTweak {
    [TBTweakManager sharedManager].nextTweakIsSystemTweak = self.isSystemTab;
    [self presentViewController:[TBBundlePickerViewController new].inNavController animated:YES completion:nil];
}

@end
