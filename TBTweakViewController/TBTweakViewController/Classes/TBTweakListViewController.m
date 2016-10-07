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
    me.tabBarItem.image = [self appsTabImage];
    me.tabBarItem.title = @"Local Tweaks";
    return me;
}

+ (instancetype)systemTweaks {
    TBTweakListViewController *me = [self new];
    
    me.tabBarItem.image = [self systemTabImage];
    me.tabBarItem.title = @"System Tweaks";
    me->_isSystemTab = YES;
    return me;
}

#define THEOS 0
+ (NSBundle *)bundleForImages {
    return [NSBundle bundleForClass:[self class]];
}

+ (UIImage *)appsTabImage {
#if THEOS
    NSString *imagePath = [[self bundleForImages] pathForResource:@"tab_app" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
#else
    return [UIImage imageNamed:@"tab_app"];
#endif
}

+ (UIImage *)systemTabImage {
#if THEOS
    NSString *imagePath = [[self bundleForImages] pathForResource:@"tab_system" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
#else
    return [UIImage imageNamed:@"tab_system"];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Bar buttons
    id add  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTweak)];
    id done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                            target:self.navigationController.tabBarController
                                                            action:@selector(dismissViewControllerAnimated:completion:)];
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
    id nav = [[UINavigationController alloc] initWithRootViewController:[TBBundlePickerViewController new]];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
