//
//  TBTweakRootViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweakRootViewController.h"
#import "TBTweakListViewController.h"
#import "TBTweakManager.h"

#import "UIViewController+Convenience.h"
#import "UIBarButtonItem+Convenience.h"


@interface TBTweakRootViewController ()
@property (nonatomic) void (^dismissAction)();
@property (nonatomic) UIBarButtonItem *done;
@end

@implementation TBTweakRootViewController

+ (instancetype)dismissAction:(void(^)())dismissAction {
    return [[self alloc] initWithDismissAction:dismissAction];
}


- (id)init {
    return [self initWithDismissAction:^{
        [self dismissAnimated];
    }];
}

- (id)initWithDismissAction:(void(^)())dismissAction {
    self = [super init];
    if (self) {
        self.dismissAction = dismissAction;
        self.done = [UIBarButtonItem item:UIBBItemDone target:self action:@selector(__dismiss)];

        TBTweakManager *manager = [TBTweakManager sharedManager];
        self.viewControllers = @[[TBTweakListViewController appTweaks].inNavController,
                                 [TBTweakListViewController systemTweaks].inNavController];
        manager.appTweaksTableViewController = [self.viewControllers[0] viewControllers][0];
        manager.systemTweaksTableViewController = [self.viewControllers[1] viewControllers][0];

        for (UINavigationController *nav in self.viewControllers) {
            nav.viewControllers.firstObject.navigationItem.leftBarButtonItem = self.done;
        }
    }

    return self;
}

- (void)__dismiss {
    self.dismissAction();
}

- (void)dealloc {
    [[TBTweakManager sharedManager] rootViewDidDismiss];
}

@end
