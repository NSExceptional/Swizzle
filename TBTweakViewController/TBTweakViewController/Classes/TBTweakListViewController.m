//
//  TBTweakListViewController.m
//  TBTweakListViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweakListViewController.h"
#import "TBKeyPathViewController.h"
#import "TBConfigureHookViewController.h"
#import "Categories.h"
#import "TBAlertController/TBAlertController.h"

#import "TBTweakManager.h"
#import "TBTweakHookCell.h"
#import "TBTweak.h"


@interface TBTweakListViewController ()
@property (nonatomic, readonly) BOOL loadTweaksAtLaunch;
@property (nonatomic, readonly) BOOL isSystemTab;
@end

@implementation TBTweakListViewController

+ (instancetype)title:(NSString *)title image:(UIImage *)image {
    TBTweakListViewController *controller = [self title:title configuration:^(UINavigationItem *item, id vc) {
        item.rightBarButtonItem = [UIBarButtonItem item:UIBBItemAdd target:vc action:@selector(addTweak)];
    }];
    controller.tabBarItem.image = [UIImage appsTabImage];
    return controller;
}

+ (instancetype)appTweaks {
    return [self title:@"Local Tweaks" image:[UIImage appsTabImage]];
}

+ (instancetype)systemTweaks {
    return [self title:@"System Tweaks" image:[UIImage systemTabImage]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Done button
    UITabBarController *tabBarController = self.navigationController.tabBarController;
    id done = [UIBarButtonItem item:UIBBItemDone target:tabBarController action:@selector(dismissAnimated)];
    self.navigationItem.leftBarButtonItem  = done;

    // Table view stuff
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectSelectedRow];
}

- (void)addTweak {
    TBAlertController *askForName = [TBAlertController alertViewWithTitle:@"Name Your Tweak" message:nil];
    askForName.alertViewStyle = UIAlertViewStylePlainTextInput;
    [askForName setCancelButtonWithTitle:@"Cancel"];
    [askForName addOtherButtonWithTitle:@"Done" buttonAction:^(NSArray *textFieldStrings) {
        NSString *title = textFieldStrings.firstObject;
        TBTweak *tweak = [TBTweak tweakWithTitle:title];

        // This takes care of the UI for us
        if (self.isSystemTab) {
            [[TBTweakManager sharedManager] addSystemTweak:tweak];
        } else {
            [[TBTweakManager sharedManager] addAppTweak:tweak];
        }
    }];

    [askForName showFromViewController:self];
}

@end
